package com.kurs.kpfl.dto.fantasy;

import java.time.LocalDateTime;

public record FantasyRoundRecalculationDto(
        Integer seasonYear,
        Integer roundNumber,
        int teamsProcessed,
        int playerPointRows,
        LocalDateTime scoredAt
) {
}
