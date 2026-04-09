package com.kurs.kpfl.service.impl;

import com.kurs.kpfl.dto.StandingRowDto;
import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.model.MatchStatus;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class StandingsServiceImplTest {

    private final StandingsServiceImpl standingsService = new StandingsServiceImpl(null);

    @Test
    void calculateStandings_sortsByPointsThenGoalDifferenceThenGoalsFor() {
        Club clubA = Club.builder().id(1L).name("Club A").abbr("A").city("A").build();
        Club clubB = Club.builder().id(2L).name("Club B").abbr("B").city("B").build();
        Club clubC = Club.builder().id(3L).name("Club C").abbr("C").city("C").build();

        Match m1 = Match.builder()
                .homeClub(clubA)
                .awayClub(clubB)
                .homeScore(2)
                .awayScore(0)
                .status(MatchStatus.FINISHED)
                .build();

        Match m2 = Match.builder()
                .homeClub(clubB)
                .awayClub(clubC)
                .homeScore(3)
                .awayScore(1)
                .status(MatchStatus.FINISHED)
                .build();

        Match m3 = Match.builder()
                .homeClub(clubC)
                .awayClub(clubA)
                .homeScore(1)
                .awayScore(0)
                .status(MatchStatus.FINISHED)
                .build();

        List<StandingRowDto> standings = standingsService.calculateStandings(List.of(m1, m2, m3));

        assertEquals(3, standings.size());
        assertEquals("Club A", standings.get(0).club().name());
        assertEquals(3, standings.get(0).points());
        assertEquals(1, standings.get(0).goalDifference());

        assertEquals("Club B", standings.get(1).club().name());
        assertEquals(3, standings.get(1).points());
        assertEquals(0, standings.get(1).goalDifference());

        assertEquals("Club C", standings.get(2).club().name());
        assertEquals(3, standings.get(2).points());
        assertEquals(-1, standings.get(2).goalDifference());
    }
}
