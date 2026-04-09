package com.kurs.kpfl.integration.thesportsdb.client;

import com.kurs.kpfl.integration.thesportsdb.dto.TheSportsDbEventDto;
import com.kurs.kpfl.integration.thesportsdb.dto.TheSportsDbLeagueDto;

import java.util.List;
import java.util.Optional;

public interface TheSportsDbClient {
    List<TheSportsDbEventDto> fetchSeasonEvents(String season);
    List<TheSportsDbEventDto> fetchNextLeagueEvents();
    List<TheSportsDbEventDto> fetchPastLeagueEvents();
    Optional<TheSportsDbLeagueDto> fetchLeague();
}
