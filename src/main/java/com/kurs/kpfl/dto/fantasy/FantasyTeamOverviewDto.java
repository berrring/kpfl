package com.kurs.kpfl.dto.fantasy;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record FantasyTeamOverviewDto(
        Long teamId,
        String teamName,
        Integer seasonYear,
        Integer totalPoints,
        BigDecimal currentBudget,
        Integer nextRoundNumber,
        LocalDateTime nextRoundLock,
        boolean active
) {
}
