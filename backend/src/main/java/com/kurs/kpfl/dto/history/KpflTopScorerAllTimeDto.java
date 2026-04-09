package com.kurs.kpfl.dto.history;

import java.math.BigDecimal;

public record KpflTopScorerAllTimeDto(
        Long id,
        Integer rankNo,
        String playerName,
        String positionName,
        Integer goals,
        Integer matchesPlayed,
        BigDecimal goalsPerMatch,
        String sourceNote
) {
}
