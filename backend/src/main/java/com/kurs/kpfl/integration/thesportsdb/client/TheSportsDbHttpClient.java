package com.kurs.kpfl.integration.thesportsdb.client;

import com.kurs.kpfl.config.TheSportsDbProperties;
import com.kurs.kpfl.integration.thesportsdb.dto.TheSportsDbEventDto;
import com.kurs.kpfl.integration.thesportsdb.dto.TheSportsDbEventsResponse;
import com.kurs.kpfl.integration.thesportsdb.dto.TheSportsDbLeagueDto;
import com.kurs.kpfl.integration.thesportsdb.dto.TheSportsDbLeagueResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class TheSportsDbHttpClient implements TheSportsDbClient {

    private static final String SEASON_EVENTS_ENDPOINT = "/eventsseason.php";
    private static final String NEXT_EVENTS_ENDPOINT = "/eventsnextleague.php";
    private static final String PAST_EVENTS_ENDPOINT = "/eventspastleague.php";
    private static final String LOOKUP_LEAGUE_ENDPOINT = "/lookupleague.php";

    private final RestTemplate theSportsDbRestTemplate;
    private final TheSportsDbProperties properties;

    @Override
    public List<TheSportsDbEventDto> fetchSeasonEvents(String season) {
        if (season == null || season.isBlank()) {
            return Collections.emptyList();
        }
        String url = UriComponentsBuilder.fromUriString(properties.getBaseUrl())
                .path(SEASON_EVENTS_ENDPOINT)
                .queryParam("id", properties.getLeagueId())
                .queryParam("s", season)
                .toUriString();
        return fetchEvents(url);
    }

    @Override
    public List<TheSportsDbEventDto> fetchNextLeagueEvents() {
        return fetchEvents(buildLeagueUrl(NEXT_EVENTS_ENDPOINT));
    }

    @Override
    public List<TheSportsDbEventDto> fetchPastLeagueEvents() {
        return fetchEvents(buildLeagueUrl(PAST_EVENTS_ENDPOINT));
    }

    @Override
    public Optional<TheSportsDbLeagueDto> fetchLeague() {
        String url = buildLeagueUrl(LOOKUP_LEAGUE_ENDPOINT);
        TheSportsDbLeagueResponse response = theSportsDbRestTemplate.getForObject(url, TheSportsDbLeagueResponse.class);
        if (response == null || response.getLeagues() == null || response.getLeagues().isEmpty()) {
            return Optional.empty();
        }
        return Optional.ofNullable(response.getLeagues().getFirst());
    }

    private List<TheSportsDbEventDto> fetchEvents(String url) {
        TheSportsDbEventsResponse response = theSportsDbRestTemplate.getForObject(url, TheSportsDbEventsResponse.class);
        if (response == null || response.getEvents() == null) {
            return Collections.emptyList();
        }
        return response.getEvents().stream()
                .filter(event -> event != null)
                .toList();
    }

    private String buildLeagueUrl(String endpoint) {
        return UriComponentsBuilder.fromUriString(properties.getBaseUrl())
                .path(endpoint)
                .queryParam("id", properties.getLeagueId())
                .toUriString();
    }
}
