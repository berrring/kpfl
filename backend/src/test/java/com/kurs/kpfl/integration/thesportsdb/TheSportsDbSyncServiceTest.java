package com.kurs.kpfl.integration.thesportsdb;

import com.kurs.kpfl.config.TheSportsDbProperties;
import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.integration.thesportsdb.client.TheSportsDbClient;
import com.kurs.kpfl.integration.thesportsdb.dto.TheSportsDbEventDto;
import com.kurs.kpfl.integration.thesportsdb.dto.TheSportsDbLeagueDto;
import com.kurs.kpfl.model.MatchStatus;
import com.kurs.kpfl.repository.ClubRepository;
import com.kurs.kpfl.repository.MatchRepository;
import com.kurs.kpfl.repository.SeasonRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TheSportsDbSyncServiceTest {

    @Mock
    private TheSportsDbClient theSportsDbClient;
    @Mock
    private ClubRepository clubRepository;
    @Mock
    private MatchRepository matchRepository;
    @Mock
    private SeasonRepository seasonRepository;

    private TheSportsDbSyncService syncService;

    @BeforeEach
    void setUp() {
        TheSportsDbProperties properties = new TheSportsDbProperties();
        properties.setTimezone("UTC");
        syncService = new TheSportsDbSyncService(
                theSportsDbClient,
                clubRepository,
                matchRepository,
                seasonRepository,
                properties,
                new TheSportsDbClubMatcher(new ClubNameNormalizer())
        );
    }

    @Test
    void sync_shouldImportOnlyOnceWhenEventAppearsInPastAndNextFeeds() {
        Club home = Club.builder().id(1L).name("FK Dordoi Bishkek").abbr("DOR").city("Bishkek").build();
        Club away = Club.builder().id(2L).name("Alga Bishkek").abbr("ALG").city("Bishkek").build();
        Season season = Season.builder().id(1L).year(2026).name("KPFL 2026").build();

        TheSportsDbEventDto duplicateEvent = scheduledEvent("900001");
        TheSportsDbLeagueDto league = league("2026");

        when(theSportsDbClient.fetchSeasonEvents("2026")).thenReturn(List.of(duplicateEvent));
        when(theSportsDbClient.fetchPastLeagueEvents()).thenReturn(List.of(duplicateEvent));
        when(theSportsDbClient.fetchNextLeagueEvents()).thenReturn(List.of(duplicateEvent));
        when(theSportsDbClient.fetchLeague()).thenReturn(Optional.of(league));

        when(clubRepository.findAll()).thenReturn(List.of(home, away));
        when(seasonRepository.findByYear(2026)).thenReturn(Optional.of(season));

        when(matchRepository.findByExternalSourceAndExternalId("THESPORTSDB", "900001")).thenReturn(Optional.empty());
        when(matchRepository.save(any(Match.class))).thenAnswer(invocation -> {
            Match saved = invocation.getArgument(0);
            saved.setId(100L);
            return saved;
        });

        TheSportsDbSyncSummary summary = syncService.sync();

        assertThat(summary.imported()).isEqualTo(1);
        assertThat(summary.updated()).isZero();
        assertThat(summary.skipped()).isZero();
        assertThat(summary.errors()).isZero();

        verify(matchRepository, times(1)).save(any(Match.class));
    }

    @Test
    void sync_shouldUpdateExistingMatchUsingExternalSourceAndId() {
        Club home = Club.builder().id(1L).name("FK Dordoi Bishkek").abbr("DOR").city("Bishkek").build();
        Club away = Club.builder().id(2L).name("Alga Bishkek").abbr("ALG").city("Bishkek").build();
        Season season = Season.builder().id(1L).year(2026).name("KPFL 2026").build();

        Match existing = Match.builder()
                .id(77L)
                .externalSource("THESPORTSDB")
                .externalId("900002")
                .dateTime(LocalDateTime.parse("2026-03-12T18:00:00"))
                .round(2)
                .season(season)
                .homeClub(home)
                .awayClub(away)
                .status(MatchStatus.SCHEDULED)
                .createdAt(LocalDateTime.now().minusDays(1))
                .build();

        TheSportsDbEventDto event = finishedEvent("900002");
        TheSportsDbLeagueDto league = league("2026");

        when(theSportsDbClient.fetchSeasonEvents("2026")).thenReturn(List.of(event));
        when(theSportsDbClient.fetchPastLeagueEvents()).thenReturn(List.of(event));
        when(theSportsDbClient.fetchNextLeagueEvents()).thenReturn(List.of());
        when(theSportsDbClient.fetchLeague()).thenReturn(Optional.of(league));

        when(clubRepository.findAll()).thenReturn(List.of(home, away));
        when(seasonRepository.findByYear(2026)).thenReturn(Optional.of(season));
        when(matchRepository.findByExternalSourceAndExternalId(eq("THESPORTSDB"), eq("900002")))
                .thenReturn(Optional.of(existing));
        when(matchRepository.save(any(Match.class))).thenAnswer(invocation -> invocation.getArgument(0));

        TheSportsDbSyncSummary summary = syncService.sync();

        assertThat(summary.imported()).isZero();
        assertThat(summary.updated()).isEqualTo(1);
        assertThat(summary.skipped()).isZero();
        assertThat(summary.errors()).isZero();

        ArgumentCaptor<Match> captor = ArgumentCaptor.forClass(Match.class);
        verify(matchRepository).save(captor.capture());
        Match saved = captor.getValue();

        assertThat(saved.getId()).isEqualTo(77L);
        assertThat(saved.getExternalSource()).isEqualTo("THESPORTSDB");
        assertThat(saved.getExternalId()).isEqualTo("900002");
        assertThat(saved.getStatus()).isEqualTo(MatchStatus.FINISHED);
        assertThat(saved.getHomeScore()).isEqualTo(2);
        assertThat(saved.getAwayScore()).isEqualTo(1);
        assertThat(saved.getRound()).isEqualTo(3);
        assertThat(saved.getDateTime()).isEqualTo(LocalDateTime.parse("2026-03-12T21:00:00"));
    }

    private TheSportsDbEventDto scheduledEvent(String idEvent) {
        TheSportsDbEventDto event = new TheSportsDbEventDto();
        event.setIdEvent(idEvent);
        event.setDateEvent("2026-03-12");
        event.setDateEventLocal("2026-03-12");
        event.setStrTime("18:00:00");
        event.setStrTimeLocal("21:00:00");
        event.setStrTimestamp("2026-03-12T18:00:00");
        event.setStrHomeTeam("Dordoi Bishkek");
        event.setStrAwayTeam("Alga Bishkek");
        event.setStrVenue("Dolen Omurzakov");
        event.setIntRound(3);
        return event;
    }

    private TheSportsDbEventDto finishedEvent(String idEvent) {
        TheSportsDbEventDto event = scheduledEvent(idEvent);
        event.setIntHomeScore(2);
        event.setIntAwayScore(1);
        return event;
    }

    private TheSportsDbLeagueDto league(String currentSeason) {
        TheSportsDbLeagueDto league = new TheSportsDbLeagueDto();
        league.setIdLeague("4969");
        league.setStrLeague("Kyrgyz Premier League");
        league.setStrCurrentSeason(currentSeason);
        return league;
    }
}
