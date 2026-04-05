package com.kurs.kpfl.service.fantasy.impl;

import com.kurs.kpfl.dto.fantasy.FantasyRoundRecalculationDto;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.fantasy.*;
import com.kurs.kpfl.model.PlayerPosition;
import com.kurs.kpfl.repository.SeasonRepository;
import com.kurs.kpfl.repository.fantasy.*;
import com.kurs.kpfl.service.fantasy.FantasyRoundService;
import com.kurs.kpfl.service.fantasy.FantasyRules;
import com.kurs.kpfl.service.fantasy.FantasyScoringService;
import com.kurs.kpfl.service.fantasy.FantasySelectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class FantasyScoringServiceImpl implements FantasyScoringService {

    private final SeasonRepository seasonRepository;
    private final FantasyTeamRepository fantasyTeamRepository;
    private final FantasyTeamRoundSelectionRepository fantasyTeamRoundSelectionRepository;
    private final FantasyTransferRepository fantasyTransferRepository;
    private final FantasyPlayerMatchStatRepository fantasyPlayerMatchStatRepository;
    private final FantasyPlayerRoundPointsRepository fantasyPlayerRoundPointsRepository;
    private final FantasyTeamRoundScoreRepository fantasyTeamRoundScoreRepository;
    private final FantasySelectionService fantasySelectionService;
    private final FantasyRoundService fantasyRoundService;

    @Override
    public FantasyRoundRecalculationDto recalculateRound(Long seasonId, Integer roundNumber) {
        Season season = seasonRepository.findById(seasonId)
                .orElseThrow(() -> new IllegalArgumentException("Season not found with id " + seasonId));
        LocalDateTime scoredAt = LocalDateTime.now();
        fantasyRoundService.getRoundLock(season, roundNumber);

        fantasyPlayerRoundPointsRepository.deleteBySeasonIdAndRoundNumber(seasonId, roundNumber);
        fantasyTeamRoundScoreRepository.deleteBySeasonIdAndRoundNumber(seasonId, roundNumber);

        Map<Long, RoundPlayerAggregate> statsByPlayerId = aggregateStats(
                fantasyPlayerMatchStatRepository.findBySeasonAndRound(seasonId, roundNumber)
        );

        List<FantasyTeam> teams = fantasyTeamRepository.findBySeasonIdAndActiveTrue(seasonId);
        List<FantasyTeamRoundScore> savedScores = new ArrayList<>();
        int playerPointRows = 0;

        for (FantasyTeam team : teams) {
            FantasyTeamRoundSelection selection = fantasySelectionService.getOrCreateSelection(team, season, roundNumber);
            RoundCalculation roundCalculation = calculateRound(team, season, selection, statsByPlayerId, scoredAt);
            fantasyPlayerRoundPointsRepository.saveAll(roundCalculation.playerPoints());
            fantasyTeamRoundScoreRepository.save(roundCalculation.roundScore());

            selection.setFinalized(Boolean.TRUE);
            selection.setLockedAt(fantasyRoundService.getRoundLock(season, roundNumber));
            selection.setUpdatedAt(scoredAt);
            fantasyTeamRoundSelectionRepository.save(selection);

            savedScores.add(roundCalculation.roundScore());
            playerPointRows += roundCalculation.playerPoints().size();
        }

        refreshTeamTotalsAndRanks(season, roundNumber, savedScores);
        return new FantasyRoundRecalculationDto(season.getYear(), roundNumber, teams.size(), playerPointRows, scoredAt);
    }

    private RoundCalculation calculateRound(
            FantasyTeam team,
            Season season,
            FantasyTeamRoundSelection selection,
            Map<Long, RoundPlayerAggregate> statsByPlayerId,
            LocalDateTime scoredAt
    ) {
        List<FantasyLineupEntry> starters = selection.getLineupEntries().stream()
                .filter(FantasyLineupEntry::getStarter)
                .sorted(Comparator.comparing(FantasyLineupEntry::getStarterOrder))
                .toList();
        List<FantasyLineupEntry> bench = selection.getLineupEntries().stream()
                .filter(entry -> !entry.getStarter())
                .sorted(Comparator.comparing(FantasyLineupEntry::getBenchOrder))
                .toList();

        LineupResolution lineup = resolveLineup(starters, bench, statsByPlayerId);
        Long captainId = selection.getCaptainPlayer().getId();
        Long viceCaptainId = selection.getViceCaptainPlayer().getId();
        boolean captainEligible = lineup.finalStarterIds().contains(captainId) && playedMinutes(statsByPlayerId, captainId) > 0;
        boolean viceCaptainEligible = !captainEligible
                && lineup.finalStarterIds().contains(viceCaptainId)
                && playedMinutes(statsByPlayerId, viceCaptainId) > 0;

        List<FantasyPlayerRoundPoints> roundPoints = new ArrayList<>();
        int totalPoints = 0;

        for (FantasyLineupEntry entry : selection.getLineupEntries()) {
            Long playerId = entry.getPlayer().getId();
            RoundPlayerAggregate aggregate = statsByPlayerId.getOrDefault(playerId, RoundPlayerAggregate.ZERO);
            boolean finalStarter = lineup.finalStarterIds().contains(playerId);
            boolean captainApplied = captainEligible && playerId.equals(captainId);
            boolean viceApplied = viceCaptainEligible && playerId.equals(viceCaptainId);
            int appliedPoints = finalStarter ? aggregate.rawPoints() : 0;
            if (captainApplied || viceApplied) {
                appliedPoints = aggregate.rawPoints() * 2;
            }

            roundPoints.add(FantasyPlayerRoundPoints.builder()
                    .fantasyTeam(team)
                    .season(season)
                    .roundNumber(selection.getRoundNumber())
                    .player(entry.getPlayer())
                    .rawPoints(aggregate.rawPoints())
                    .appliedPoints(appliedPoints)
                    .starter(finalStarter)
                    .captainApplied(captainApplied)
                    .viceCaptainApplied(viceApplied)
                    .autoSubApplied(lineup.autoSubbedInIds().contains(playerId))
                    .explanation(buildExplanation(entry, lineup, aggregate, finalStarter, captainApplied, viceApplied))
                    .build());
            totalPoints += appliedPoints;
        }

        int transferPenalty = fantasyTransferRepository.findByFantasyTeamIdAndSeasonIdAndRoundNumberOrderByCreatedAtAsc(
                        team.getId(),
                        season.getId(),
                        selection.getRoundNumber()
                ).stream()
                .map(FantasyTransfer::getCostPoints)
                .mapToInt(cost -> Math.max(0, -cost))
                .sum();

        FantasyTeamRoundScore roundScore = FantasyTeamRoundScore.builder()
                .fantasyTeam(team)
                .season(season)
                .roundNumber(selection.getRoundNumber())
                .points(totalPoints)
                .transferPenalty(transferPenalty)
                .finalPoints(totalPoints - transferPenalty)
                .rankSnapshot(null)
                .calculatedAt(scoredAt)
                .build();

        return new RoundCalculation(roundPoints, roundScore);
    }

    private LineupResolution resolveLineup(
            List<FantasyLineupEntry> starters,
            List<FantasyLineupEntry> bench,
            Map<Long, RoundPlayerAggregate> statsByPlayerId
    ) {
        Set<Long> finalStarterIds = starters.stream()
                .map(entry -> entry.getPlayer().getId())
                .collect(Collectors.toCollection(LinkedHashSet::new));
        Set<Long> autoSubbedInIds = new HashSet<>();
        Set<Long> replacedOutIds = new HashSet<>();

        FantasyLineupEntry starterGoalkeeper = starters.stream()
                .filter(entry -> entry.getPlayer().getPosition() == PlayerPosition.GK)
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Starting lineup must contain a goalkeeper."));
        FantasyLineupEntry benchGoalkeeper = bench.stream()
                .filter(entry -> entry.getPlayer().getPosition() == PlayerPosition.GK)
                .findFirst()
                .orElse(null);

        if (playedMinutes(statsByPlayerId, starterGoalkeeper.getPlayer().getId()) == 0
                && benchGoalkeeper != null
                && playedMinutes(statsByPlayerId, benchGoalkeeper.getPlayer().getId()) > 0) {
            finalStarterIds.remove(starterGoalkeeper.getPlayer().getId());
            finalStarterIds.add(benchGoalkeeper.getPlayer().getId());
            autoSubbedInIds.add(benchGoalkeeper.getPlayer().getId());
            replacedOutIds.add(starterGoalkeeper.getPlayer().getId());
        }

        List<FantasyLineupEntry> outfieldFinal = starters.stream()
                .filter(entry -> entry.getPlayer().getPosition() != PlayerPosition.GK)
                .collect(Collectors.toCollection(ArrayList::new));
        List<FantasyLineupEntry> missingOutfield = outfieldFinal.stream()
                .filter(entry -> playedMinutes(statsByPlayerId, entry.getPlayer().getId()) == 0)
                .sorted(Comparator.comparing(FantasyLineupEntry::getStarterOrder))
                .collect(Collectors.toCollection(ArrayList::new));

        List<FantasyLineupEntry> benchOutfield = bench.stream()
                .filter(entry -> entry.getPlayer().getPosition() != PlayerPosition.GK)
                .sorted(Comparator.comparing(FantasyLineupEntry::getBenchOrder))
                .toList();

        for (FantasyLineupEntry candidate : benchOutfield) {
            if (playedMinutes(statsByPlayerId, candidate.getPlayer().getId()) == 0) {
                continue;
            }

            FantasyLineupEntry replaceable = missingOutfield.stream()
                    .filter(outfieldFinal::contains)
                    .filter(missing -> keepsValidFormation(outfieldFinal, missing, candidate))
                    .findFirst()
                    .orElse(null);
            if (replaceable == null) {
                continue;
            }

            outfieldFinal.remove(replaceable);
            outfieldFinal.add(candidate);
            missingOutfield.remove(replaceable);

            finalStarterIds.remove(replaceable.getPlayer().getId());
            finalStarterIds.add(candidate.getPlayer().getId());
            replacedOutIds.add(replaceable.getPlayer().getId());
            autoSubbedInIds.add(candidate.getPlayer().getId());
        }

        return new LineupResolution(finalStarterIds, autoSubbedInIds, replacedOutIds);
    }

    private boolean keepsValidFormation(
            List<FantasyLineupEntry> currentOutfield,
            FantasyLineupEntry removed,
            FantasyLineupEntry candidate
    ) {
        long defenders = currentOutfield.stream().filter(entry -> entry.getPlayer().getPosition() == PlayerPosition.DF).count();
        long midfielders = currentOutfield.stream().filter(entry -> entry.getPlayer().getPosition() == PlayerPosition.MF).count();
        long forwards = currentOutfield.stream().filter(entry -> entry.getPlayer().getPosition() == PlayerPosition.FW).count();

        switch (removed.getPlayer().getPosition()) {
            case DF -> defenders--;
            case MF -> midfielders--;
            case FW -> forwards--;
            case GK -> throw new IllegalArgumentException("Goalkeeper cannot be auto-substituted as outfield.");
        }
        switch (candidate.getPlayer().getPosition()) {
            case DF -> defenders++;
            case MF -> midfielders++;
            case FW -> forwards++;
            case GK -> throw new IllegalArgumentException("Bench goalkeeper cannot replace an outfield player.");
        }

        return FantasyRules.isValidFormation(defenders, midfielders, forwards);
    }

    private Map<Long, RoundPlayerAggregate> aggregateStats(List<FantasyPlayerMatchStat> stats) {
        Map<Long, RoundPlayerAggregate> aggregate = new HashMap<>();
        for (FantasyPlayerMatchStat stat : stats) {
            aggregate.merge(
                    stat.getPlayer().getId(),
                    new RoundPlayerAggregate(calculateRawPoints(stat), stat.getMinutesPlayed()),
                    (left, right) -> new RoundPlayerAggregate(
                            left.rawPoints() + right.rawPoints(),
                            left.minutesPlayed() + right.minutesPlayed()
                    )
            );
        }
        return aggregate;
    }

    private int calculateRawPoints(FantasyPlayerMatchStat stat) {
        int points = 0;
        int minutesPlayed = stat.getMinutesPlayed();
        PlayerPosition position = stat.getPlayer().getPosition();

        if (minutesPlayed > 0 && minutesPlayed < 60) {
            points += 1;
        } else if (minutesPlayed >= 60) {
            points += 2;
        }

        points += stat.getGoals() * FantasyRules.goalPoints(position);
        points += stat.getAssists() * 3;

        if (Boolean.TRUE.equals(stat.getCleanSheet()) && minutesPlayed >= 60) {
            points += FantasyRules.cleanSheetPoints(position);
        }

        if (position == PlayerPosition.GK || position == PlayerPosition.DF) {
            points -= stat.getGoalsConceded() / 2;
        }

        points -= stat.getYellowCards();
        points -= stat.getRedCards() * 3;
        points -= stat.getOwnGoals() * 2;
        points -= stat.getPenaltiesMissed() * 2;

        if (position == PlayerPosition.GK) {
            points += stat.getPenaltiesSaved() * 5;
            points += stat.getSaves() / 3;
        }

        return points;
    }

    private int playedMinutes(Map<Long, RoundPlayerAggregate> statsByPlayerId, Long playerId) {
        return statsByPlayerId.getOrDefault(playerId, RoundPlayerAggregate.ZERO).minutesPlayed();
    }

    private void refreshTeamTotalsAndRanks(Season season, Integer roundNumber, List<FantasyTeamRoundScore> scoresForRound) {
        Map<Long, FantasyTeamRoundScore> byTeamId = scoresForRound.stream()
                .collect(Collectors.toMap(score -> score.getFantasyTeam().getId(), score -> score));

        List<FantasyTeam> seasonTeams = fantasyTeamRepository.findBySeasonIdAndActiveTrue(season.getId());

        for (FantasyTeam team : seasonTeams) {
            int totalPoints = fantasyTeamRoundScoreRepository.findByFantasyTeamIdAndSeasonIdOrderByRoundNumberAsc(team.getId(), season.getId())
                    .stream()
                    .mapToInt(FantasyTeamRoundScore::getFinalPoints)
                    .sum();
            team.setTotalPoints(totalPoints);
            fantasyTeamRepository.save(team);
        }

        AtomicInteger rank = new AtomicInteger(1);
        seasonTeams.stream()
                .sorted(Comparator.comparing(FantasyTeam::getTotalPoints).reversed()
                        .thenComparing(FantasyTeam::getName))
                .forEach(team -> {
                    FantasyTeamRoundScore score = byTeamId.get(team.getId());
                    if (score != null) {
                        score.setRankSnapshot(rank.getAndIncrement());
                        fantasyTeamRoundScoreRepository.save(score);
                    }
                });
    }

    private String buildExplanation(
            FantasyLineupEntry entry,
            LineupResolution lineup,
            RoundPlayerAggregate aggregate,
            boolean finalStarter,
            boolean captainApplied,
            boolean viceCaptainApplied
    ) {
        List<String> parts = new ArrayList<>();

        if (lineup.autoSubbedInIds().contains(entry.getPlayer().getId())) {
            parts.add("Auto-subbed in from bench");
        } else if (lineup.replacedOutIds().contains(entry.getPlayer().getId())) {
            parts.add("Starter replaced after 0 minutes");
        } else if (entry.getStarter() && aggregate.minutesPlayed() == 0) {
            parts.add("Starter kept with 0-minute appearance");
        } else if (finalStarter) {
            parts.add("Counted in final XI");
        } else {
            parts.add("Bench points not applied");
        }

        if (captainApplied) {
            parts.add("Captain points doubled");
        }
        if (viceCaptainApplied) {
            parts.add("Vice-captain points doubled");
        }

        return String.join("; ", parts);
    }

    private record RoundCalculation(
            List<FantasyPlayerRoundPoints> playerPoints,
            FantasyTeamRoundScore roundScore
    ) {
    }

    private record LineupResolution(
            Set<Long> finalStarterIds,
            Set<Long> autoSubbedInIds,
            Set<Long> replacedOutIds
    ) {
    }

    private record RoundPlayerAggregate(int rawPoints, int minutesPlayed) {
        private static final RoundPlayerAggregate ZERO = new RoundPlayerAggregate(0, 0);
    }
}
