package com.kurs.kpfl.dto.fantasy;

public record FantasyLeagueDto(
        Long leagueId,
        String name,
        String code,
        boolean isPrivate,
        Integer seasonYear,
        String ownerDisplayName,
        long memberCount
) {
}
