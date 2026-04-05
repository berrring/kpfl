package com.kurs.kpfl.dto.fantasy;

public record FantasyLeaderboardEntryDto(
        Integer rank,
        Long teamId,
        String teamName,
        String ownerDisplayName,
        Integer totalPoints
) {
}
