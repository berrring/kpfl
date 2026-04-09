package com.kurs.kpfl.integration.thesportsdb;

import com.kurs.kpfl.config.TheSportsDbProperties;
import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.integration.thesportsdb.client.TheSportsDbClient;
import com.kurs.kpfl.integration.thesportsdb.dto.TheSportsDbEventDto;
import com.kurs.kpfl.model.MatchStatus;
import com.kurs.kpfl.repository.ClubRepository;
import com.kurs.kpfl.repository.MatchRepository;
import com.kurs.kpfl.repository.SeasonRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DateTimeException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Supplier;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Transactional
public class TheSportsDbSyncService {

    private static final Logger log = LoggerFactory.getLogger(TheSportsDbSyncService.class);
    private static final String EXTERNAL_SOURCE = "THESPORTSDB";
    private static final Pattern TIME_PATTERN = Pattern.compile("(\\d{2}:\\d{2}(?::\\d{2})?)");

    private static final List<DateTimeFormatter> OFFSET_DATE_TIME_FORMATS = List.of(
            DateTimeFormatter.ISO_OFFSET_DATE_TIME,
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ssXXX"),
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ssXXX"),
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ssX"),
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ssX")
    );

    private static final List<DateTimeFormatter> LOCAL_DATE_TIME_FORMATS = List.of(
            DateTimeFormatter.ISO_LOCAL_DATE_TIME,
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"),
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")
    );

    private final TheSportsDbClient theSportsDbClient;
    private final ClubRepository clubRepository;
    private final MatchRepository matchRepository;
    private final SeasonRepository seasonRepository;
    private final TheSportsDbProperties properties;
    private final TheSportsDbClubMatcher clubMatcher;

    public TheSportsDbSyncSummary sync() {
        SyncStats stats = new SyncStats();
        ZoneId zoneId = resolveZoneId();

        List<TheSportsDbEventDto> rawEvents = new ArrayList<>();
        rawEvents.addAll(fetchEventsSafely("past", theSportsDbClient::fetchPastLeagueEvents, stats));
        rawEvents.addAll(fetchEventsSafely("next", theSportsDbClient::fetchNextLeagueEvents, stats));
        fetchLeagueMetadataSafely(stats);

        Map<String, TheSportsDbEventDto> dedupedEvents = deduplicate(rawEvents, stats);
        if (dedupedEvents.isEmpty() && stats.errors == 0) {
            return stats.toSummary("No events received from provider");
        }

        List<Club> clubs = clubRepository.findAll();
        Map<Integer, Season> seasonCache = new HashMap<>();

        for (TheSportsDbEventDto event : dedupedEvents.values()) {
            try {
                processEvent(event, clubs, seasonCache, zoneId, stats);
            } catch (Exception ex) {
                stats.errors++;
                log.error("Failed to process TheSportsDB event id={}: {}", event.getIdEvent(), ex.getMessage(), ex);
            }
        }

        return stats.toSummary("Completed");
    }

    private void processEvent(
            TheSportsDbEventDto event,
            List<Club> clubs,
            Map<Integer, Season> seasonCache,
            ZoneId zoneId,
            SyncStats stats
    ) {
        String externalId = trimToNull(event.getIdEvent());
        if (externalId == null) {
            stats.skipped++;
            log.warn("TheSportsDB event skipped: missing idEvent");
            return;
        }

        LocalDateTime kickoff = resolveKickoffDateTime(event, zoneId);
        if (kickoff == null) {
            stats.skipped++;
            log.warn("TheSportsDB event {} skipped: could not parse date/time", externalId);
            return;
        }

        Club homeClub = clubMatcher.match(event.getStrHomeTeam(), clubs).orElse(null);
        Club awayClub = clubMatcher.match(event.getStrAwayTeam(), clubs).orElse(null);

        if (homeClub == null || awayClub == null) {
            stats.skipped++;
            log.warn(
                    "TheSportsDB event {} skipped: unresolved clubs home='{}' away='{}'",
                    externalId, event.getStrHomeTeam(), event.getStrAwayTeam()
            );
            return;
        }

        if (homeClub.getId().equals(awayClub.getId())) {
            stats.skipped++;
            log.warn(
                    "TheSportsDB event {} skipped: same club resolved for both sides ('{}')",
                    externalId, homeClub.getName()
            );
            return;
        }

        Match match = matchRepository.findByExternalSourceAndExternalId(EXTERNAL_SOURCE, externalId).orElseGet(Match::new);
        boolean isNew = match.getId() == null;

        Season season = resolveSeason(kickoff.getYear(), seasonCache);
        mapEventToMatch(match, event, externalId, kickoff, season, homeClub, awayClub);

        if (isNew) {
            match.setCreatedAt(LocalDateTime.now());
        }

        matchRepository.save(match);
        if (isNew) {
            stats.imported++;
        } else {
            stats.updated++;
        }
    }

    private void mapEventToMatch(
            Match match,
            TheSportsDbEventDto event,
            String externalId,
            LocalDateTime kickoff,
            Season season,
            Club homeClub,
            Club awayClub
    ) {
        match.setExternalSource(EXTERNAL_SOURCE);
        match.setExternalId(externalId);
        match.setSeason(season);
        match.setDateTime(kickoff);
        match.setRound(resolveRound(event.getIntRound(), match.getRound()));
        match.setStadium(trimToNull(event.getStrVenue()));
        match.setHomeClub(homeClub);
        match.setAwayClub(awayClub);

        if (hasScore(event)) {
            match.setHomeScore(event.getIntHomeScore());
            match.setAwayScore(event.getIntAwayScore());
            match.setStatus(MatchStatus.FINISHED);
        } else {
            match.setHomeScore(null);
            match.setAwayScore(null);
            match.setStatus(MatchStatus.SCHEDULED);
        }
    }

    private int resolveRound(Integer incomingRound, Integer existingRound) {
        if (incomingRound != null && incomingRound > 0) {
            return incomingRound;
        }
        if (existingRound != null && existingRound > 0) {
            return existingRound;
        }
        return 1;
    }

    private Season resolveSeason(int year, Map<Integer, Season> seasonCache) {
        return seasonCache.computeIfAbsent(year, this::loadOrCreateSeason);
    }

    private Season loadOrCreateSeason(int year) {
        return seasonRepository.findByYear(year).orElseGet(() -> seasonRepository.save(Season.builder()
                .year(year)
                .name("KPFL " + year)
                .startDate(LocalDate.of(year, 1, 1))
                .endDate(LocalDate.of(year, 12, 31))
                .build()));
    }

    private boolean hasScore(TheSportsDbEventDto event) {
        return event.getIntHomeScore() != null && event.getIntAwayScore() != null;
    }

    private Map<String, TheSportsDbEventDto> deduplicate(List<TheSportsDbEventDto> events, SyncStats stats) {
        Map<String, TheSportsDbEventDto> deduped = new LinkedHashMap<>();
        for (TheSportsDbEventDto event : events) {
            if (event == null) {
                stats.skipped++;
                continue;
            }

            String externalId = trimToNull(event.getIdEvent());
            if (externalId == null) {
                stats.skipped++;
                log.warn("TheSportsDB event skipped during deduplication: missing idEvent");
                continue;
            }

            TheSportsDbEventDto existing = deduped.get(externalId);
            if (existing == null || (!hasScore(existing) && hasScore(event))) {
                deduped.put(externalId, event);
            }
        }
        return deduped;
    }

    private List<TheSportsDbEventDto> fetchEventsSafely(
            String label,
            Supplier<List<TheSportsDbEventDto>> supplier,
            SyncStats stats
    ) {
        try {
            List<TheSportsDbEventDto> events = supplier.get();
            return events == null ? List.of() : events;
        } catch (Exception ex) {
            stats.errors++;
            log.error("Failed to fetch {} events from TheSportsDB: {}", label, ex.getMessage(), ex);
            return List.of();
        }
    }

    private void fetchLeagueMetadataSafely(SyncStats stats) {
        try {
            theSportsDbClient.fetchLeague().ifPresent(league -> log.info(
                    "TheSportsDB league metadata: id={}, name='{}', badge='{}'",
                    league.getIdLeague(), league.getStrLeague(), league.getStrBadge()
            ));
        } catch (Exception ex) {
            stats.errors++;
            log.error("Failed to fetch league metadata from TheSportsDB: {}", ex.getMessage(), ex);
        }
    }

    private LocalDateTime resolveKickoffDateTime(TheSportsDbEventDto event, ZoneId zoneId) {
        LocalDateTime parsedTimestamp = parseTimestamp(event.getStrTimestamp(), zoneId);
        if (parsedTimestamp != null) {
            return parsedTimestamp;
        }
        return parseDateAndTime(event.getDateEvent(), event.getStrTime());
    }

    private LocalDateTime parseTimestamp(String rawTimestamp, ZoneId zoneId) {
        String timestamp = trimToNull(rawTimestamp);
        if (timestamp == null) {
            return null;
        }

        try {
            return OffsetDateTime.parse(timestamp).atZoneSameInstant(zoneId).toLocalDateTime();
        } catch (DateTimeParseException ignored) {
            // Try additional formats.
        }

        try {
            return LocalDateTime.ofInstant(Instant.parse(timestamp), zoneId);
        } catch (DateTimeParseException ignored) {
            // Try additional formats.
        }

        for (DateTimeFormatter formatter : OFFSET_DATE_TIME_FORMATS) {
            try {
                return OffsetDateTime.parse(timestamp, formatter).atZoneSameInstant(zoneId).toLocalDateTime();
            } catch (DateTimeParseException ignored) {
                // Continue.
            }
        }

        for (DateTimeFormatter formatter : LOCAL_DATE_TIME_FORMATS) {
            try {
                return LocalDateTime.parse(timestamp, formatter);
            } catch (DateTimeParseException ignored) {
                // Continue.
            }
        }

        return null;
    }

    private LocalDateTime parseDateAndTime(String rawDate, String rawTime) {
        String dateText = trimToNull(rawDate);
        if (dateText == null) {
            return null;
        }

        final LocalDate date;
        try {
            date = LocalDate.parse(dateText);
        } catch (DateTimeParseException ex) {
            return null;
        }

        LocalTime parsedTime = parseTime(rawTime);
        return LocalDateTime.of(date, parsedTime == null ? LocalTime.MIDNIGHT : parsedTime);
    }

    private LocalTime parseTime(String rawTime) {
        String value = trimToNull(rawTime);
        if (value == null) {
            return null;
        }

        Matcher matcher = TIME_PATTERN.matcher(value);
        if (matcher.find()) {
            String normalized = matcher.group(1);
            if (normalized.length() == 5) {
                normalized = normalized + ":00";
            }
            try {
                return LocalTime.parse(normalized);
            } catch (DateTimeParseException ignored) {
                // Try fallback parsing below.
            }
        }

        try {
            return LocalTime.parse(value);
        } catch (DateTimeParseException ignored) {
            return null;
        }
    }

    private ZoneId resolveZoneId() {
        String zone = trimToNull(properties.getTimezone());
        if (zone == null) {
            return ZoneOffset.UTC;
        }
        try {
            return ZoneId.of(zone);
        } catch (DateTimeException ex) {
            log.warn("Invalid thesportsdb.timezone '{}', fallback to UTC", zone);
            return ZoneOffset.UTC;
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static class SyncStats {
        private int imported;
        private int updated;
        private int skipped;
        private int errors;

        private TheSportsDbSyncSummary toSummary(String note) {
            return new TheSportsDbSyncSummary(imported, updated, skipped, errors, note);
        }
    }
}
