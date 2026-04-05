package com.kurs.kpfl.dto.fantasy;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record FantasyPriceDto(
        Long playerId,
        String playerName,
        Integer seasonYear,
        BigDecimal currentPrice,
        BigDecimal initialPrice,
        String priceSource,
        LocalDateTime lastUpdatedAt
) {
}
