package com.kurs.kpfl.dto.fantasy;

import java.math.BigDecimal;

public record FantasyAdminTeamDto(
        Long teamId,
        String teamName,
        String ownerEmail,
        String ownerDisplayName,
        Integer seasonYear,
        Integer totalPoints,
        BigDecimal currentBudget,
        long activeSquadSize
) {
}
