package com.kurs.kpfl.service.fantasy.impl;

import com.kurs.kpfl.dto.fantasy.*;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.User;
import com.kurs.kpfl.entity.fantasy.*;
import com.kurs.kpfl.exception.ConflictException;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.model.PlayerPosition;
import com.kurs.kpfl.repository.PlayerRepository;
import com.kurs.kpfl.repository.fantasy.*;
import com.kurs.kpfl.service.fantasy.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class FantasyTeamServiceImpl implements FantasyTeamService {

    private static final Comparator<FantasyTeamPlayer> TEAM_PLAYER_ORDER = Comparator
            .comparing((FantasyTeamPlayer entry) -> entry.getPlayer().getPosition())
            .thenComparing(entry -> entry.getPlayer().getLastName())
            .thenComparing(entry -> entry.getPlayer().getFirstName())
            .thenComparing(FantasyTeamPlayer::getId);

    private final FantasyTeamRepository fantasyTeamRepository;
    private final FantasyTeamPlayerRepository fantasyTeamPlayerRepository;
    private final FantasyTransferRepository fantasyTransferRepository;
    private final FantasyTeamRoundSelectionRepository fantasyTeamRoundSelectionRepository;
    private final FantasyPlayerRoundPointsRepository fantasyPlayerRoundPointsRepository;
    private final FantasyTeamRoundScoreRepository fantasyTeamRoundScoreRepository;
    private final PlayerRepository playerRepository;
    private final FantasyPricingService fantasyPricingService;
    private final FantasyRoundService fantasyRoundService;
    private final FantasySelectionService fantasySelectionService;

    @Override
    public FantasyTeamOverviewDto createTeam(User user, FantasyTeamCreateRequest request) {
        Season season = fantasyRoundService.getCurrentSeason();
        ensureNoExistingTeam(user, season);

        int upcomingRound = fantasyRoundService.getUpcomingRoundNumber(season);

        ValidatedSquad squad = validateSquad(request.getPlayerIds(), season);
        FantasyTeam fantasyTeam = fantasyTeamRepository.save(FantasyTeam.builder()
                .user(user)
                .season(season)
                .name(request.getName())
                .totalPoints(0)
                .currentBudget(normalizeMoney(FantasyRules.TOTAL_BUDGET.subtract(squad.totalCost())))
                .active(Boolean.TRUE)
                .createdAt(LocalDateTime.now())
                .build());

        saveTeamPlayers(fantasyTeam, squad.players(), squad.priceMap(), upcomingRound);
        if (!fantasyRoundService.isRoundLocked(season, upcomingRound)) {
            fantasySelectionService.rebuildDefaultSelection(fantasyTeam, season, upcomingRound, squad.players());
        }
        return mapOverview(fantasyTeam);
    }

    @Override
    @Transactional(readOnly = true)
    public FantasyTeamOverviewDto getTeamOverview(User user) {
        return mapOverview(resolveTeam(user, null));
    }

    @Override
    @Transactional(readOnly = true)
    public FantasyTeamSquadDto getTeamSquad(User user) {
        FantasyTeam fantasyTeam = resolveTeam(user, null);
        return mapSquad(fantasyTeam, getActiveTeamPlayers(fantasyTeam));
    }

    @Override
    public FantasyTeamSquadDto updateSquad(User user, FantasySquadUpdateRequest request) {
        FantasyTeam fantasyTeam = resolveTeam(user, null);
        Season season = fantasyTeam.getSeason();
        int firstRound = fantasyRoundService.getFirstRoundNumber(season);
        if (fantasyRoundService.isRoundLocked(season, firstRound)) {
            throw new IllegalArgumentException("Full squad replacement is only available before the first round lock.");
        }

        ValidatedSquad squad = validateSquad(request.getPlayerIds(), season);
        fantasyTeamRoundSelectionRepository.deleteByFantasyTeamIdAndSeasonId(fantasyTeam.getId(), season.getId());
        fantasyTransferRepository.deleteByFantasyTeamIdAndSeasonId(fantasyTeam.getId(), season.getId());
        fantasyTeamPlayerRepository.deleteByFantasyTeamId(fantasyTeam.getId());

        saveTeamPlayers(fantasyTeam, squad.players(), squad.priceMap(), firstRound);
        fantasyTeam.setCurrentBudget(normalizeMoney(FantasyRules.TOTAL_BUDGET.subtract(squad.totalCost())));
        fantasyTeam.setTotalPoints(0);
        fantasyTeamRepository.save(fantasyTeam);

        fantasySelectionService.rebuildDefaultSelection(fantasyTeam, season, firstRound, squad.players());
        return mapSquad(fantasyTeam, getActiveTeamPlayers(fantasyTeam));
    }

    @Override
    public FantasyTeamRoundDto saveLineup(User user, FantasyLineupUpdateRequest request) {
        FantasyTeam fantasyTeam = resolveTeam(user, request.getSeasonYear());
        Season season = fantasyTeam.getSeason();
        ensureRoundOpen(season, request.getRoundNumber());

        Map<Long, Player> activePlayers = getActiveTeamPlayers(fantasyTeam).stream()
                .map(FantasyTeamPlayer::getPlayer)
                .collect(Collectors.toMap(Player::getId, player -> player));

        FantasyTeamRoundSelection selection = fantasySelectionService.saveSelection(fantasyTeam, season, request, activePlayers);
        return buildRoundDto(fantasyTeam, season, selection);
    }

    @Override
    public FantasyTransferResultDto performTransfers(User user, FantasyTransferRequest request) {
        FantasyTeam fantasyTeam = resolveTeam(user, request.getSeasonYear());
        Season season = fantasyTeam.getSeason();

        int upcomingRound = fantasyRoundService.getUpcomingRoundNumber(season);
        if (!Objects.equals(upcomingRound, request.getRoundNumber())) {
            throw new IllegalArgumentException("Transfers are only allowed for the next unlocked round.");
        }
        ensureRoundOpen(season, request.getRoundNumber());

        List<FantasyTeamPlayer> activeEntries = getActiveTeamPlayers(fantasyTeam);
        Map<Long, FantasyTeamPlayer> activeByPlayerId = activeEntries.stream()
                .collect(Collectors.toMap(entry -> entry.getPlayer().getId(), entry -> entry));
        Map<Long, Player> currentPlayersById = activeEntries.stream()
                .map(FantasyTeamPlayer::getPlayer)
                .collect(Collectors.toMap(Player::getId, player -> player));

        validateTransferItems(request.getTransfers(), currentPlayersById);
        List<Player> incomingPlayers = playerRepository.findAllById(request.getTransfers().stream()
                .map(FantasyTransferItemRequest::getPlayerInId)
                .toList());
        if (incomingPlayers.size() != request.getTransfers().size()) {
            throw new NotFoundException("One or more incoming players were not found.");
        }
        Map<Long, Player> incomingByPlayerId = incomingPlayers.stream()
                .collect(Collectors.toMap(Player::getId, player -> player));

        Set<Player> pricePlayers = new LinkedHashSet<>(currentPlayersById.values());
        pricePlayers.addAll(incomingPlayers);
        Map<Long, FantasyPlayerPrice> priceMap = fantasyPricingService.getOrCreatePrices(pricePlayers, season);

        LinkedHashSet<Player> finalPlayers = new LinkedHashSet<>(currentPlayersById.values());
        for (FantasyTransferItemRequest item : request.getTransfers()) {
            finalPlayers.remove(currentPlayersById.get(item.getPlayerOutId()));
            finalPlayers.add(incomingByPlayerId.get(item.getPlayerInId()));
        }
        validateSquadComposition(new ArrayList<>(finalPlayers));

        BigDecimal totalSold = request.getTransfers().stream()
                .map(FantasyTransferItemRequest::getPlayerOutId)
                .map(playerId -> priceMap.get(playerId).getCurrentPrice())
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal totalBought = request.getTransfers().stream()
                .map(FantasyTransferItemRequest::getPlayerInId)
                .map(playerId -> priceMap.get(playerId).getCurrentPrice())
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal updatedBudget = normalizeMoney(fantasyTeam.getCurrentBudget().add(totalSold).subtract(totalBought));
        if (updatedBudget.signum() < 0) {
            throw new IllegalArgumentException("Transfers exceed the remaining fantasy budget.");
        }

        long existingTransfers = fantasyTransferRepository.countByFantasyTeamIdAndSeasonIdAndRoundNumber(
                fantasyTeam.getId(),
                season.getId(),
                request.getRoundNumber()
        );
        LocalDateTime now = LocalDateTime.now();
        int requestPenalty = 0;

        for (int i = 0; i < request.getTransfers().size(); i++) {
            FantasyTransferItemRequest item = request.getTransfers().get(i);
            FantasyTeamPlayer outgoing = activeByPlayerId.get(item.getPlayerOutId());
            outgoing.setActive(Boolean.FALSE);
            outgoing.setSoldRound(request.getRoundNumber());
            fantasyTeamPlayerRepository.save(outgoing);

            int transferNumber = (int) existingTransfers + i + 1;
            int costPoints = transferNumber > FantasyRules.FREE_TRANSFERS_PER_ROUND ? -FantasyRules.EXTRA_TRANSFER_PENALTY : 0;
            requestPenalty += Math.max(0, -costPoints);

            fantasyTransferRepository.save(FantasyTransfer.builder()
                    .fantasyTeam(fantasyTeam)
                    .season(season)
                    .roundNumber(request.getRoundNumber())
                    .playerOut(outgoing.getPlayer())
                    .playerIn(incomingByPlayerId.get(item.getPlayerInId()))
                    .costPoints(costPoints)
                    .createdAt(now)
                    .build());

            fantasyTeamPlayerRepository.save(FantasyTeamPlayer.builder()
                    .fantasyTeam(fantasyTeam)
                    .player(incomingByPlayerId.get(item.getPlayerInId()))
                    .acquiredPrice(priceMap.get(item.getPlayerInId()).getCurrentPrice())
                    .acquiredRound(request.getRoundNumber())
                    .soldRound(null)
                    .active(Boolean.TRUE)
                    .createdAt(now)
                    .build());
        }

        fantasyTeam.setCurrentBudget(updatedBudget);
        fantasyTeamRepository.save(fantasyTeam);

        List<Player> updatedPlayers = getActiveTeamPlayers(fantasyTeam).stream()
                .map(FantasyTeamPlayer::getPlayer)
                .toList();
        fantasySelectionService.rebuildDefaultSelection(fantasyTeam, season, request.getRoundNumber(), updatedPlayers);

        int totalTransfersAfter = (int) existingTransfers + request.getTransfers().size();
        int freeTransfersUsed = Math.max(
                0,
                Math.min(FantasyRules.FREE_TRANSFERS_PER_ROUND, totalTransfersAfter)
                        - Math.min(FantasyRules.FREE_TRANSFERS_PER_ROUND, (int) existingTransfers)
        );

        return new FantasyTransferResultDto(
                fantasyTeam.getId(),
                season.getYear(),
                request.getRoundNumber(),
                request.getTransfers().size(),
                freeTransfersUsed,
                requestPenalty,
                fantasyTeam.getCurrentBudget(),
                true,
                mapSquadPlayers(getActiveTeamPlayers(fantasyTeam), fantasyPricingService.getOrCreatePrices(updatedPlayers, season))
        );
    }

    @Override
    public FantasyTeamRoundDto getRoundDetails(User user, Integer seasonYear, Integer roundNumber) {
        FantasyTeam fantasyTeam = resolveTeam(user, seasonYear);
        Season season = fantasyTeam.getSeason();
        FantasyTeamRoundSelection selection = fantasySelectionService.getOrCreateSelection(fantasyTeam, season, roundNumber);
        return buildRoundDto(fantasyTeam, season, selection);
    }

    @Override
    @Transactional(readOnly = true)
    public List<FantasyHistoryItemDto> getHistory(User user, Integer seasonYear) {
        FantasyTeam fantasyTeam = resolveTeam(user, seasonYear);
        List<FantasyTeamRoundScore> scores = fantasyTeamRoundScoreRepository.findByFantasyTeamIdAndSeasonIdOrderByRoundNumberAsc(
                fantasyTeam.getId(),
                fantasyTeam.getSeason().getId()
        );

        int cumulative = 0;
        List<FantasyHistoryItemDto> history = new ArrayList<>();
        for (FantasyTeamRoundScore score : scores) {
            cumulative += score.getFinalPoints();
            history.add(new FantasyHistoryItemDto(
                    fantasyTeam.getSeason().getYear(),
                    score.getRoundNumber(),
                    score.getPoints(),
                    score.getTransferPenalty(),
                    score.getFinalPoints(),
                    cumulative,
                    score.getRankSnapshot()
            ));
        }
        return history;
    }

    @Override
    @Transactional(readOnly = true)
    public List<FantasyLeaderboardEntryDto> getGlobalLeaderboard(Integer seasonYear) {
        Season season = fantasyRoundService.resolveSeason(seasonYear);
        AtomicInteger rank = new AtomicInteger(1);
        return fantasyTeamRepository.findBySeasonIdAndActiveTrue(season.getId()).stream()
                .sorted(Comparator.comparing(FantasyTeam::getTotalPoints).reversed()
                        .thenComparing(FantasyTeam::getName))
                .map(team -> new FantasyLeaderboardEntryDto(
                        rank.getAndIncrement(),
                        team.getId(),
                        team.getName(),
                        ownerDisplayName(team.getUser()),
                        team.getTotalPoints()
                ))
                .toList();
    }

    private FantasyTeam resolveTeam(User user, Integer seasonYear) {
        Season season = fantasyRoundService.resolveSeason(seasonYear);
        return fantasyTeamRepository.findByUserIdAndSeasonId(user.getId(), season.getId())
                .orElseThrow(() -> new NotFoundException("Fantasy team not found for the current user."));
    }

    private void ensureNoExistingTeam(User user, Season season) {
        if (fantasyTeamRepository.findByUserIdAndSeasonId(user.getId(), season.getId()).isPresent()) {
            throw new ConflictException("Current user already has a fantasy team for this season.");
        }
    }

    private void ensureRoundOpen(Season season, int roundNumber) {
        if (fantasyRoundService.isRoundLocked(season, roundNumber)) {
            throw new IllegalArgumentException("Round " + roundNumber + " is already locked.");
        }
    }

    private ValidatedSquad validateSquad(List<Long> playerIds, Season season) {
        if (new HashSet<>(playerIds).size() != playerIds.size()) {
            throw new IllegalArgumentException("Fantasy squad cannot contain duplicate players.");
        }

        List<Player> players = playerRepository.findAllById(playerIds);
        if (players.size() != playerIds.size()) {
            throw new NotFoundException("One or more selected players were not found.");
        }

        validateSquadComposition(players);
        Map<Long, FantasyPlayerPrice> priceMap = fantasyPricingService.getOrCreatePrices(players, season);
        BigDecimal totalCost = players.stream()
                .map(player -> priceMap.get(player.getId()).getCurrentPrice())
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        if (totalCost.compareTo(FantasyRules.TOTAL_BUDGET) > 0) {
            throw new IllegalArgumentException("Selected squad exceeds the fantasy budget of 100.0.");
        }

        return new ValidatedSquad(players.stream().sorted(Comparator
                .comparing(Player::getPosition)
                .thenComparing(Player::getLastName)
                .thenComparing(Player::getFirstName)
                .thenComparing(Player::getId)).toList(), priceMap, normalizeMoney(totalCost));
    }

    private void validateSquadComposition(List<Player> players) {
        if (players.size() != FantasyRules.SQUAD_SIZE) {
            throw new IllegalArgumentException("Fantasy squad must contain exactly 15 players.");
        }

        Map<PlayerPosition, Long> counts = players.stream()
                .collect(Collectors.groupingBy(Player::getPosition, Collectors.counting()));
        for (Map.Entry<PlayerPosition, Integer> entry : FantasyRules.SQUAD_LIMITS.entrySet()) {
            if (!Objects.equals(counts.getOrDefault(entry.getKey(), 0L), Long.valueOf(entry.getValue()))) {
                throw new IllegalArgumentException("Fantasy squad must contain " + entry.getValue() + " " + entry.getKey() + " players.");
            }
        }

        Map<Long, Long> clubCounts = players.stream()
                .collect(Collectors.groupingBy(player -> player.getClub().getId(), Collectors.counting()));
        if (clubCounts.values().stream().anyMatch(count -> count > FantasyRules.MAX_PLAYERS_PER_CLUB)) {
            throw new IllegalArgumentException("Fantasy squad cannot contain more than 3 players from the same club.");
        }
    }

    private void validateTransferItems(List<FantasyTransferItemRequest> transfers, Map<Long, Player> currentPlayersById) {
        Set<Long> outgoing = new HashSet<>();
        Set<Long> incoming = new HashSet<>();
        for (FantasyTransferItemRequest transfer : transfers) {
            if (!outgoing.add(transfer.getPlayerOutId())) {
                throw new IllegalArgumentException("Transfer list contains duplicate outgoing players.");
            }
            if (!incoming.add(transfer.getPlayerInId())) {
                throw new IllegalArgumentException("Transfer list contains duplicate incoming players.");
            }
            if (Objects.equals(transfer.getPlayerOutId(), transfer.getPlayerInId())) {
                throw new IllegalArgumentException("Transfer in and transfer out players must be different.");
            }
            if (!currentPlayersById.containsKey(transfer.getPlayerOutId())) {
                throw new IllegalArgumentException("Player " + transfer.getPlayerOutId() + " is not owned by the fantasy team.");
            }
            if (currentPlayersById.containsKey(transfer.getPlayerInId())) {
                throw new IllegalArgumentException("Player " + transfer.getPlayerInId() + " is already owned by the fantasy team.");
            }
        }
    }

    private void saveTeamPlayers(FantasyTeam fantasyTeam, List<Player> players, Map<Long, FantasyPlayerPrice> priceMap, int acquiredRound) {
        LocalDateTime now = LocalDateTime.now();
        fantasyTeamPlayerRepository.saveAll(players.stream()
                .map(player -> FantasyTeamPlayer.builder()
                        .fantasyTeam(fantasyTeam)
                        .player(player)
                        .acquiredPrice(priceMap.get(player.getId()).getCurrentPrice())
                        .acquiredRound(acquiredRound)
                        .soldRound(null)
                        .active(Boolean.TRUE)
                        .createdAt(now)
                        .build())
                .toList());
    }

    private List<FantasyTeamPlayer> getActiveTeamPlayers(FantasyTeam fantasyTeam) {
        return fantasyTeamPlayerRepository.findByFantasyTeamIdAndActiveTrue(fantasyTeam.getId()).stream()
                .sorted(TEAM_PLAYER_ORDER)
                .toList();
    }

    private FantasyTeamOverviewDto mapOverview(FantasyTeam fantasyTeam) {
        int nextRound = fantasyRoundService.getUpcomingRoundNumber(fantasyTeam.getSeason());
        return new FantasyTeamOverviewDto(
                fantasyTeam.getId(),
                fantasyTeam.getName(),
                fantasyTeam.getSeason().getYear(),
                fantasyTeam.getTotalPoints(),
                fantasyTeam.getCurrentBudget(),
                nextRound,
                fantasyRoundService.getRoundLock(fantasyTeam.getSeason(), nextRound),
                fantasyTeam.getActive()
        );
    }

    private FantasyTeamSquadDto mapSquad(FantasyTeam fantasyTeam, List<FantasyTeamPlayer> entries) {
        List<Player> players = entries.stream().map(FantasyTeamPlayer::getPlayer).toList();
        Map<Long, FantasyPlayerPrice> prices = fantasyPricingService.getOrCreatePrices(players, fantasyTeam.getSeason());
        BigDecimal squadValue = prices.values().stream()
                .map(FantasyPlayerPrice::getCurrentPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return new FantasyTeamSquadDto(
                fantasyTeam.getId(),
                fantasyTeam.getName(),
                fantasyTeam.getSeason().getYear(),
                fantasyTeam.getTotalPoints(),
                fantasyTeam.getCurrentBudget(),
                normalizeMoney(squadValue),
                mapSquadPlayers(entries, prices)
        );
    }

    private List<FantasySquadPlayerDto> mapSquadPlayers(List<FantasyTeamPlayer> entries, Map<Long, FantasyPlayerPrice> prices) {
        return entries.stream()
                .sorted(TEAM_PLAYER_ORDER)
                .map(entry -> new FantasySquadPlayerDto(
                        entry.getPlayer().getId(),
                        entry.getPlayer().getFirstName(),
                        entry.getPlayer().getLastName(),
                        entry.getPlayer().getPosition().name(),
                        entry.getPlayer().getClub().getId(),
                        entry.getPlayer().getClub().getName(),
                        entry.getPlayer().getClub().getAbbr(),
                        prices.get(entry.getPlayer().getId()).getCurrentPrice(),
                        entry.getAcquiredPrice()
                ))
                .toList();
    }

    private FantasyTeamRoundDto buildRoundDto(FantasyTeam fantasyTeam, Season season, FantasyTeamRoundSelection selection) {
        FantasyTeamRoundScore score = fantasyTeamRoundScoreRepository.findByFantasyTeamIdAndSeasonIdAndRoundNumber(
                fantasyTeam.getId(),
                season.getId(),
                selection.getRoundNumber()
        ).orElse(null);

        List<FantasyPlayerRoundPointsDto> playerPoints = fantasyPlayerRoundPointsRepository.findByFantasyTeamIdAndSeasonIdAndRoundNumber(
                        fantasyTeam.getId(),
                        season.getId(),
                        selection.getRoundNumber()
                ).stream()
                .sorted(Comparator.comparing(FantasyPlayerRoundPoints::getAppliedPoints).reversed()
                        .thenComparing(points -> points.getPlayer().getLastName())
                        .thenComparing(points -> points.getPlayer().getFirstName()))
                .map(points -> new FantasyPlayerRoundPointsDto(
                        points.getPlayer().getId(),
                        points.getPlayer().getFirstName(),
                        points.getPlayer().getLastName(),
                        points.getPlayer().getPosition().name(),
                        points.getPlayer().getClub().getName(),
                        points.getRawPoints(),
                        points.getAppliedPoints(),
                        points.getStarter(),
                        points.getCaptainApplied(),
                        points.getViceCaptainApplied(),
                        points.getAutoSubApplied(),
                        points.getExplanation()
                ))
                .toList();

        return new FantasyTeamRoundDto(
                season.getYear(),
                selection.getRoundNumber(),
                selection.getLockedAt(),
                selection.getFinalized(),
                selection.getCaptainPlayer().getId(),
                selection.getViceCaptainPlayer().getId(),
                score == null ? null : score.getPoints(),
                score == null ? null : score.getTransferPenalty(),
                score == null ? null : score.getFinalPoints(),
                score == null ? null : score.getRankSnapshot(),
                fantasySelectionService.mapLineup(selection),
                playerPoints
        );
    }

    private BigDecimal normalizeMoney(BigDecimal value) {
        return value.setScale(1, RoundingMode.HALF_UP);
    }

    private String ownerDisplayName(User user) {
        return user.getDisplayName() == null || user.getDisplayName().isBlank()
                ? user.getEmail()
                : user.getDisplayName();
    }

    private record ValidatedSquad(
            List<Player> players,
            Map<Long, FantasyPlayerPrice> priceMap,
            BigDecimal totalCost
    ) {
    }
}
