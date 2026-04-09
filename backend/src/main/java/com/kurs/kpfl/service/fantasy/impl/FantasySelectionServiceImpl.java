package com.kurs.kpfl.service.fantasy.impl;

import com.kurs.kpfl.dto.fantasy.FantasyLineupPlayerDto;
import com.kurs.kpfl.dto.fantasy.FantasyLineupUpdateRequest;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.fantasy.FantasyLineupEntry;
import com.kurs.kpfl.entity.fantasy.FantasyTeam;
import com.kurs.kpfl.entity.fantasy.FantasyTeamPlayer;
import com.kurs.kpfl.entity.fantasy.FantasyTeamRoundSelection;
import com.kurs.kpfl.model.PlayerPosition;
import com.kurs.kpfl.repository.fantasy.FantasyTeamPlayerRepository;
import com.kurs.kpfl.repository.fantasy.FantasyTeamRoundSelectionRepository;
import com.kurs.kpfl.service.fantasy.FantasyRoundService;
import com.kurs.kpfl.service.fantasy.FantasyRules;
import com.kurs.kpfl.service.fantasy.FantasySelectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Transactional
public class FantasySelectionServiceImpl implements FantasySelectionService {

    private static final Comparator<Player> PLAYER_ORDER = Comparator
            .comparing(Player::getPosition)
            .thenComparing(Player::getLastName)
            .thenComparing(Player::getFirstName)
            .thenComparing(Player::getId);

    private final FantasyTeamRoundSelectionRepository selectionRepository;
    private final FantasyTeamPlayerRepository fantasyTeamPlayerRepository;
    private final FantasyRoundService fantasyRoundService;

    @Override
    public FantasyTeamRoundSelection getOrCreateSelection(FantasyTeam fantasyTeam, Season season, Integer roundNumber) {
        return selectionRepository.findByFantasyTeamIdAndSeasonIdAndRoundNumber(fantasyTeam.getId(), season.getId(), roundNumber)
                .orElseGet(() -> rebuildDefaultSelection(fantasyTeam, season, roundNumber, loadActivePlayers(fantasyTeam)));
    }

    @Override
    public FantasyTeamRoundSelection rebuildDefaultSelection(FantasyTeam fantasyTeam, Season season, Integer roundNumber, List<Player> squadPlayers) {
        validateSquadSize(squadPlayers);
        List<Player> sorted = squadPlayers.stream().sorted(PLAYER_ORDER).toList();

        Player startingGoalkeeper = firstByPosition(sorted, PlayerPosition.GK, null);
        List<Player> starters = new ArrayList<>();
        starters.add(startingGoalkeeper);
        starters.addAll(firstNByPosition(sorted, PlayerPosition.DF, 3, Set.of(startingGoalkeeper.getId())));
        starters.addAll(firstNByPosition(sorted, PlayerPosition.MF, 4, starters.stream().map(Player::getId).collect(java.util.stream.Collectors.toSet())));
        starters.addAll(firstNByPosition(sorted, PlayerPosition.FW, 3, starters.stream().map(Player::getId).collect(java.util.stream.Collectors.toSet())));

        Set<Long> starterIds = starters.stream().map(Player::getId).collect(java.util.stream.Collectors.toCollection(LinkedHashSet::new));
        List<Player> bench = new ArrayList<>();
        bench.add(firstByPosition(sorted, PlayerPosition.GK, starterIds));
        bench.addAll(sorted.stream()
                .filter(player -> !starterIds.contains(player.getId()))
                .filter(player -> player.getPosition() != PlayerPosition.GK)
                .sorted(PLAYER_ORDER)
                .toList());
        if (bench.size() != FantasyRules.BENCH_COUNT) {
            throw new IllegalArgumentException("Default bench could not be created from the current squad.");
        }

        Player captain = starters.stream()
                .filter(player -> player.getPosition() != PlayerPosition.GK)
                .findFirst()
                .orElse(starters.get(0));
        Player viceCaptain = starters.stream()
                .filter(player -> !player.getId().equals(captain.getId()))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Vice-captain could not be resolved."));

        return persistSelection(fantasyTeam, season, roundNumber, starters, bench, captain, viceCaptain);
    }

    @Override
    public FantasyTeamRoundSelection saveSelection(
            FantasyTeam fantasyTeam,
            Season season,
            FantasyLineupUpdateRequest request,
            Map<Long, Player> activePlayers
    ) {
        List<Player> starters = resolvePlayers(request.getStarterPlayerIds(), activePlayers);
        List<Player> bench = resolvePlayers(request.getBenchPlayerIds(), activePlayers);

        validateSelection(activePlayers, starters, bench, request.getCaptainPlayerId(), request.getViceCaptainPlayerId());

        Player captain = activePlayers.get(request.getCaptainPlayerId());
        Player viceCaptain = activePlayers.get(request.getViceCaptainPlayerId());
        return persistSelection(fantasyTeam, season, request.getRoundNumber(), starters, bench, captain, viceCaptain);
    }

    @Override
    public List<FantasyLineupPlayerDto> mapLineup(FantasyTeamRoundSelection selection) {
        return selection.getLineupEntries().stream()
                .sorted(Comparator
                        .comparing(FantasyLineupEntry::getStarter).reversed()
                        .thenComparing(entry -> entry.getStarterOrder() == null ? Integer.MAX_VALUE : entry.getStarterOrder())
                        .thenComparing(entry -> entry.getBenchOrder() == null ? Integer.MAX_VALUE : entry.getBenchOrder()))
                .map(entry -> new FantasyLineupPlayerDto(
                        entry.getPlayer().getId(),
                        entry.getPlayer().getFirstName(),
                        entry.getPlayer().getLastName(),
                        entry.getPlayer().getPosition().name(),
                        entry.getPlayer().getClub().getName(),
                        entry.getStarter(),
                        entry.getStarterOrder(),
                        entry.getBenchOrder(),
                        entry.getPlayer().getId().equals(selection.getCaptainPlayer().getId()),
                        entry.getPlayer().getId().equals(selection.getViceCaptainPlayer().getId())
                ))
                .toList();
    }

    private FantasyTeamRoundSelection persistSelection(
            FantasyTeam fantasyTeam,
            Season season,
            Integer roundNumber,
            List<Player> starters,
            List<Player> bench,
            Player captain,
            Player viceCaptain
    ) {
        LocalDateTime now = LocalDateTime.now();
        FantasyTeamRoundSelection selection = selectionRepository
                .findByFantasyTeamIdAndSeasonIdAndRoundNumber(fantasyTeam.getId(), season.getId(), roundNumber)
                .orElseGet(FantasyTeamRoundSelection::new);

        selection.setFantasyTeam(fantasyTeam);
        selection.setSeason(season);
        selection.setRoundNumber(roundNumber);
        selection.setLockedAt(fantasyRoundService.getRoundLock(season, roundNumber));
        selection.setFinalized(Boolean.FALSE);
        selection.setCaptainPlayer(captain);
        selection.setViceCaptainPlayer(viceCaptain);
        selection.setCreatedAt(selection.getCreatedAt() == null ? now : selection.getCreatedAt());
        selection.setUpdatedAt(now);
        if (selection.getLineupEntries() == null) {
            selection.setLineupEntries(new ArrayList<>());
        } else {
            selection.getLineupEntries().clear();
        }

        for (int i = 0; i < starters.size(); i++) {
            selection.getLineupEntries().add(FantasyLineupEntry.builder()
                    .roundSelection(selection)
                    .player(starters.get(i))
                    .starter(Boolean.TRUE)
                    .starterOrder(i + 1)
                    .benchOrder(null)
                    .createdAt(now)
                    .build());
        }

        for (int i = 0; i < bench.size(); i++) {
            selection.getLineupEntries().add(FantasyLineupEntry.builder()
                    .roundSelection(selection)
                    .player(bench.get(i))
                    .starter(Boolean.FALSE)
                    .starterOrder(null)
                    .benchOrder(i + 1)
                    .createdAt(now)
                    .build());
        }

        return selectionRepository.save(selection);
    }

    private void validateSelection(
            Map<Long, Player> activePlayers,
            List<Player> starters,
            List<Player> bench,
            Long captainPlayerId,
            Long viceCaptainPlayerId
    ) {
        Set<Long> combinedIds = new LinkedHashSet<>();
        starters.forEach(player -> combinedIds.add(player.getId()));
        bench.forEach(player -> combinedIds.add(player.getId()));

        if (combinedIds.size() != FantasyRules.SQUAD_SIZE || combinedIds.size() != activePlayers.size()) {
            throw new IllegalArgumentException("Lineup must include each active squad player exactly once.");
        }

        long starterGkCount = starters.stream().filter(player -> player.getPosition() == PlayerPosition.GK).count();
        if (starterGkCount != 1) {
            throw new IllegalArgumentException("Starting lineup must contain exactly one goalkeeper.");
        }

        long defenders = starters.stream().filter(player -> player.getPosition() == PlayerPosition.DF).count();
        long midfielders = starters.stream().filter(player -> player.getPosition() == PlayerPosition.MF).count();
        long forwards = starters.stream().filter(player -> player.getPosition() == PlayerPosition.FW).count();
        if (!FantasyRules.isValidFormation(defenders, midfielders, forwards)) {
            throw new IllegalArgumentException("Starting lineup does not match an allowed formation.");
        }

        if (!combinedIds.contains(captainPlayerId) || !combinedIds.contains(viceCaptainPlayerId)) {
            throw new IllegalArgumentException("Captain and vice-captain must belong to the active round selection.");
        }
        if (Objects.equals(captainPlayerId, viceCaptainPlayerId)) {
            throw new IllegalArgumentException("Captain and vice-captain must be different players.");
        }
    }

    private List<Player> resolvePlayers(List<Long> playerIds, Map<Long, Player> activePlayers) {
        if (new HashSet<>(playerIds).size() != playerIds.size()) {
            throw new IllegalArgumentException("Duplicate players are not allowed in a lineup.");
        }

        List<Player> players = new ArrayList<>();
        for (Long playerId : playerIds) {
            Player player = activePlayers.get(playerId);
            if (player == null) {
                throw new IllegalArgumentException("Player " + playerId + " is not in the active fantasy squad.");
            }
            players.add(player);
        }
        return players;
    }

    private List<Player> loadActivePlayers(FantasyTeam fantasyTeam) {
        return fantasyTeamPlayerRepository.findByFantasyTeamIdAndActiveTrue(fantasyTeam.getId()).stream()
                .map(FantasyTeamPlayer::getPlayer)
                .sorted(PLAYER_ORDER)
                .toList();
    }

    private void validateSquadSize(List<Player> squadPlayers) {
        if (squadPlayers.size() != FantasyRules.SQUAD_SIZE) {
            throw new IllegalArgumentException("Fantasy team must have 15 active players to build a round selection.");
        }
    }

    private Player firstByPosition(List<Player> players, PlayerPosition position, Set<Long> excludedIds) {
        return players.stream()
                .filter(player -> player.getPosition() == position)
                .filter(player -> excludedIds == null || !excludedIds.contains(player.getId()))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Could not resolve player for position " + position));
    }

    private List<Player> firstNByPosition(List<Player> players, PlayerPosition position, int amount, Set<Long> excludedIds) {
        List<Player> selected = players.stream()
                .filter(player -> player.getPosition() == position)
                .filter(player -> excludedIds == null || !excludedIds.contains(player.getId()))
                .limit(amount)
                .toList();

        if (selected.size() != amount) {
            throw new IllegalArgumentException("Squad does not contain enough " + position + " players.");
        }
        return selected;
    }
}
