package com.kurs.kpfl.dto.fantasy;

public record FantasyPlayerMatchStatDto(
        Long id,
        Long playerId,
        String playerName,
        Long matchId,
        Integer seasonYear,
        Integer roundNumber,
        Integer minutesPlayed,
        Integer goals,
        Integer assists,
        boolean cleanSheet,
        Integer goalsConceded,
        Integer yellowCards,
        Integer redCards,
        Integer ownGoals,
        Integer penaltiesSaved,
        Integer penaltiesMissed,
        Integer saves,
        boolean started,
        boolean substitutedIn,
        boolean substitutedOut
) {
}
