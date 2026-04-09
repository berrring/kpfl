package com.kurs.kpfl.service.fantasy;

import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.User;
import com.kurs.kpfl.entity.fantasy.*;
import com.kurs.kpfl.model.PlayerPosition;
import com.kurs.kpfl.model.Role;
import com.kurs.kpfl.repository.SeasonRepository;
import com.kurs.kpfl.repository.fantasy.*;
import com.kurs.kpfl.service.fantasy.impl.FantasyScoringServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FantasyScoringServiceTest {

    @Mock private SeasonRepository seasonRepository;
    @Mock private FantasyTeamRepository fantasyTeamRepository;
    @Mock private FantasyTeamRoundSelectionRepository fantasyTeamRoundSelectionRepository;
    @Mock private FantasyTransferRepository fantasyTransferRepository;
    @Mock private FantasyPlayerMatchStatRepository fantasyPlayerMatchStatRepository;
    @Mock private FantasyPlayerRoundPointsRepository fantasyPlayerRoundPointsRepository;
    @Mock private FantasyTeamRoundScoreRepository fantasyTeamRoundScoreRepository;
    @Mock private FantasySelectionService fantasySelectionService;
    @Mock private FantasyRoundService fantasyRoundService;

    private FantasyScoringServiceImpl fantasyScoringService;
    private Season season;
    private FantasyTeam team;
    private List<FantasyTeamRoundScore> savedScores;

    @BeforeEach
    void setUp() {
        fantasyScoringService = new FantasyScoringServiceImpl(
                seasonRepository,
                fantasyTeamRepository,
                fantasyTeamRoundSelectionRepository,
                fantasyTransferRepository,
                fantasyPlayerMatchStatRepository,
                fantasyPlayerRoundPointsRepository,
                fantasyTeamRoundScoreRepository,
                fantasySelectionService,
                fantasyRoundService
        );

        season = Season.builder().id(1L).year(2026).name("KPFL 2026").build();
        team = FantasyTeam.builder()
                .id(100L)
                .season(season)
                .user(User.builder()
                        .id(10L)
                        .email("user@kpfl.local")
                        .displayName("Fantasy User")
                        .role(Role.USER)
                        .createdAt(LocalDateTime.now())
                        .build())
                .name("Test Team")
                .totalPoints(0)
                .currentBudget(new BigDecimal("10.0"))
                .active(true)
                .createdAt(LocalDateTime.now())
                .build();

        savedScores = new ArrayList<>();
        when(seasonRepository.findById(1L)).thenReturn(Optional.of(season));
        when(fantasyTeamRepository.findBySeasonIdAndActiveTrue(1L)).thenReturn(List.of(team));
        when(fantasyRoundService.getRoundLock(season, 3)).thenReturn(LocalDateTime.now().plusDays(1));
        when(fantasyTeamRepository.save(any(FantasyTeam.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(fantasyPlayerRoundPointsRepository.saveAll(any())).thenAnswer(invocation -> invocation.getArgument(0));
        when(fantasyTeamRoundSelectionRepository.save(any(FantasyTeamRoundSelection.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(fantasyTeamRoundScoreRepository.save(any(FantasyTeamRoundScore.class))).thenAnswer(invocation -> {
            FantasyTeamRoundScore score = invocation.getArgument(0);
            savedScores.removeIf(existing -> existing.getFantasyTeam().getId().equals(score.getFantasyTeam().getId())
                    && existing.getRoundNumber().equals(score.getRoundNumber()));
            savedScores.add(score);
            return score;
        });
        when(fantasyTeamRoundScoreRepository.findByFantasyTeamIdAndSeasonIdOrderByRoundNumberAsc(team.getId(), season.getId()))
                .thenAnswer(invocation -> savedScores);
    }

    @Test
    void recalculateRound_shouldApplyCaptainAndAutoSubAndPenalty() {
        TestContext context = buildContext(false);
        when(fantasySelectionService.getOrCreateSelection(team, season, 3)).thenReturn(context.selection());
        when(fantasyPlayerMatchStatRepository.findBySeasonAndRound(1L, 3)).thenReturn(context.stats());
        when(fantasyTransferRepository.findByFantasyTeamIdAndSeasonIdAndRoundNumberOrderByCreatedAtAsc(team.getId(), season.getId(), 3))
                .thenReturn(List.of(FantasyTransfer.builder()
                        .fantasyTeam(team)
                        .season(season)
                        .roundNumber(3)
                        .playerOut(context.replacedDefender())
                        .playerIn(context.autoSubDefender())
                        .costPoints(-4)
                        .createdAt(LocalDateTime.now())
                        .build()));

        var result = fantasyScoringService.recalculateRound(1L, 3);

        assertThat(result.teamsProcessed()).isEqualTo(1);
        assertThat(result.playerPointRows()).isEqualTo(15);
        assertThat(savedScores).hasSize(1);
        assertThat(savedScores.get(0).getPoints()).isEqualTo(63);
        assertThat(savedScores.get(0).getTransferPenalty()).isEqualTo(4);
        assertThat(savedScores.get(0).getFinalPoints()).isEqualTo(59);
        assertThat(savedScores.get(0).getRankSnapshot()).isEqualTo(1);
        assertThat(team.getTotalPoints()).isEqualTo(59);

        ArgumentCaptor<List<FantasyPlayerRoundPoints>> captor = ArgumentCaptor.forClass(List.class);
        verify(fantasyPlayerRoundPointsRepository).saveAll(captor.capture());
        List<FantasyPlayerRoundPoints> savedPoints = captor.getValue();

        FantasyPlayerRoundPoints captainPoints = savedPoints.stream()
                .filter(points -> points.getPlayer().getId().equals(context.captain().getId()))
                .findFirst()
                .orElseThrow();
        assertThat(captainPoints.getCaptainApplied()).isTrue();
        assertThat(captainPoints.getAppliedPoints()).isEqualTo(22);

        FantasyPlayerRoundPoints autoSubPoints = savedPoints.stream()
                .filter(points -> points.getPlayer().getId().equals(context.autoSubDefender().getId()))
                .findFirst()
                .orElseThrow();
        assertThat(autoSubPoints.getAutoSubApplied()).isTrue();
        assertThat(autoSubPoints.getStarter()).isTrue();
        assertThat(autoSubPoints.getAppliedPoints()).isEqualTo(6);

        FantasyPlayerRoundPoints replacedPoints = savedPoints.stream()
                .filter(points -> points.getPlayer().getId().equals(context.replacedDefender().getId()))
                .findFirst()
                .orElseThrow();
        assertThat(replacedPoints.getStarter()).isFalse();
        assertThat(replacedPoints.getAppliedPoints()).isZero();
    }

    @Test
    void recalculateRound_shouldUseViceCaptainWhenCaptainPlaysZeroMinutes() {
        TestContext context = buildContext(true);
        when(fantasySelectionService.getOrCreateSelection(team, season, 3)).thenReturn(context.selection());
        when(fantasyPlayerMatchStatRepository.findBySeasonAndRound(1L, 3)).thenReturn(context.stats());
        when(fantasyTransferRepository.findByFantasyTeamIdAndSeasonIdAndRoundNumberOrderByCreatedAtAsc(team.getId(), season.getId(), 3))
                .thenReturn(List.of());

        fantasyScoringService.recalculateRound(1L, 3);

        ArgumentCaptor<List<FantasyPlayerRoundPoints>> captor = ArgumentCaptor.forClass(List.class);
        verify(fantasyPlayerRoundPointsRepository).saveAll(captor.capture());
        List<FantasyPlayerRoundPoints> savedPoints = captor.getValue();

        FantasyPlayerRoundPoints captainPoints = savedPoints.stream()
                .filter(points -> points.getPlayer().getId().equals(context.captain().getId()))
                .findFirst()
                .orElseThrow();
        FantasyPlayerRoundPoints vicePoints = savedPoints.stream()
                .filter(points -> points.getPlayer().getId().equals(context.viceCaptain().getId()))
                .findFirst()
                .orElseThrow();

        assertThat(captainPoints.getCaptainApplied()).isFalse();
        assertThat(vicePoints.getViceCaptainApplied()).isTrue();
        assertThat(vicePoints.getAppliedPoints()).isEqualTo(12);
    }

    private TestContext buildContext(boolean captainDoesNotPlay) {
        Club clubA = club(1L, "Club A");
        Club clubB = club(2L, "Club B");
        Club clubC = club(3L, "Club C");

        Player gkStarter = player(1L, "Goalie", "Starter", PlayerPosition.GK, clubA);
        Player df1 = player(2L, "Def", "One", PlayerPosition.DF, clubA);
        Player df2 = player(3L, "Def", "Two", PlayerPosition.DF, clubA);
        Player df3 = player(4L, "Def", "Three", PlayerPosition.DF, clubB);
        Player captain = player(5L, "Mid", "Captain", PlayerPosition.MF, clubA);
        Player mf2 = player(6L, "Mid", "Two", PlayerPosition.MF, clubB);
        Player mf3 = player(7L, "Mid", "Three", PlayerPosition.MF, clubB);
        Player mf4 = player(8L, "Mid", "Four", PlayerPosition.MF, clubC);
        Player viceCaptain = player(9L, "For", "Vice", PlayerPosition.FW, clubB);
        Player fw2 = player(10L, "For", "Two", PlayerPosition.FW, clubC);
        Player fw3 = player(11L, "For", "Three", PlayerPosition.FW, clubC);
        Player gkBench = player(12L, "Goalie", "Bench", PlayerPosition.GK, clubB);
        Player dfBench = player(13L, "Def", "Bench", PlayerPosition.DF, clubB);
        Player mfBench = player(14L, "Mid", "Bench", PlayerPosition.MF, clubC);
        Player fwBench = player(15L, "For", "Bench", PlayerPosition.FW, clubC);

        FantasyTeamRoundSelection selection = FantasyTeamRoundSelection.builder()
                .id(200L)
                .fantasyTeam(team)
                .season(season)
                .roundNumber(3)
                .lockedAt(LocalDateTime.now().plusDays(1))
                .finalized(false)
                .captainPlayer(captain)
                .viceCaptainPlayer(viceCaptain)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        selection.setLineupEntries(List.of(
                starter(selection, gkStarter, 1),
                starter(selection, df1, 2),
                starter(selection, df2, 3),
                starter(selection, df3, 4),
                starter(selection, captain, 5),
                starter(selection, mf2, 6),
                starter(selection, mf3, 7),
                starter(selection, mf4, 8),
                starter(selection, viceCaptain, 9),
                starter(selection, fw2, 10),
                starter(selection, fw3, 11),
                bench(selection, gkBench, 1),
                bench(selection, dfBench, 2),
                bench(selection, mfBench, 3),
                bench(selection, fwBench, 4)
        ));

        Match roundMatch = Match.builder().id(300L).season(season).round(3).build();
        List<FantasyPlayerMatchStat> stats = List.of(
                stat(gkStarter, roundMatch, 90, 0, 0, true, 0, 0, 0, 0, 1, 0, 3),
                stat(df1, roundMatch, 90, 0, 0, true, 0, 0, 0, 0, 0, 0, 0),
                stat(df2, roundMatch, 90, 0, 0, true, 0, 0, 0, 0, 0, 0, 0),
                captainDoesNotPlay
                        ? stat(captain, roundMatch, 0, 0, 0, false, 0, 0, 0, 0, 0, 0, 0)
                        : stat(captain, roundMatch, 90, 1, 1, true, 0, 0, 0, 0, 0, 0, 0),
                stat(mf2, roundMatch, 90, 0, 0, false, 0, 0, 0, 0, 0, 0, 0),
                stat(mf3, roundMatch, 90, 0, 0, false, 0, 0, 0, 0, 0, 0, 0),
                stat(mf4, roundMatch, 90, 0, 0, false, 0, 0, 0, 0, 0, 0, 0),
                stat(viceCaptain, roundMatch, 90, 1, 0, false, 0, 0, 0, 0, 0, 0, 0),
                stat(fw2, roundMatch, 90, 0, 0, false, 0, 0, 0, 0, 0, 0, 0),
                stat(fw3, roundMatch, 90, 0, 0, false, 0, 0, 0, 0, 0, 0, 0),
                stat(dfBench, roundMatch, 90, 0, 0, true, 0, 0, 0, 0, 0, 0, 0)
        );

        return new TestContext(selection, stats, captain, viceCaptain, df3, dfBench);
    }

    private FantasyLineupEntry starter(FantasyTeamRoundSelection selection, Player player, int order) {
        return FantasyLineupEntry.builder()
                .roundSelection(selection)
                .player(player)
                .starter(true)
                .starterOrder(order)
                .createdAt(LocalDateTime.now())
                .build();
    }

    private FantasyLineupEntry bench(FantasyTeamRoundSelection selection, Player player, int order) {
        return FantasyLineupEntry.builder()
                .roundSelection(selection)
                .player(player)
                .starter(false)
                .benchOrder(order)
                .createdAt(LocalDateTime.now())
                .build();
    }

    private FantasyPlayerMatchStat stat(
            Player player,
            Match match,
            int minutes,
            int goals,
            int assists,
            boolean cleanSheet,
            int goalsConceded,
            int yellowCards,
            int redCards,
            int ownGoals,
            int penaltiesSaved,
            int penaltiesMissed,
            int saves
    ) {
        return FantasyPlayerMatchStat.builder()
                .player(player)
                .match(match)
                .minutesPlayed(minutes)
                .goals(goals)
                .assists(assists)
                .cleanSheet(cleanSheet)
                .goalsConceded(goalsConceded)
                .yellowCards(yellowCards)
                .redCards(redCards)
                .ownGoals(ownGoals)
                .penaltiesSaved(penaltiesSaved)
                .penaltiesMissed(penaltiesMissed)
                .saves(saves)
                .started(minutes > 0)
                .substitutedIn(false)
                .substitutedOut(false)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
    }

    private Player player(Long id, String firstName, String lastName, PlayerPosition position, Club club) {
        return Player.builder()
                .id(id)
                .firstName(firstName)
                .lastName(lastName)
                .position(position)
                .club(club)
                .build();
    }

    private Club club(Long id, String name) {
        return Club.builder().id(id).name(name).abbr(name.substring(0, 3).toUpperCase()).city("City").build();
    }

    private record TestContext(
            FantasyTeamRoundSelection selection,
            List<FantasyPlayerMatchStat> stats,
            Player captain,
            Player viceCaptain,
            Player replacedDefender,
            Player autoSubDefender
    ) {
    }
}
