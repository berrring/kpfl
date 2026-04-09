package com.kurs.kpfl.dto.fantasy;

import java.math.BigDecimal;

public record FantasySquadPlayerDto(
        Long playerId,
        String firstName,
        String lastName,
        String position,
        Long clubId,
        String clubName,
        String clubAbbr,
        BigDecimal currentPrice,
        BigDecimal acquiredPrice
) {
}
