package com.kurs.kpfl.dto.history;

public record KpflSeasonStandingsArchiveDto(
        Long id,
        Integer seasonYear,
        Integer placeNo,
        String clubName,
        Integer played,
        Integer wins,
        Integer draws,
        Integer losses,
        Integer goalsFor,
        Integer goalsAgainst,
        Integer goalDifference,
        Integer points,
        Integer matchesTotal
) {
}
