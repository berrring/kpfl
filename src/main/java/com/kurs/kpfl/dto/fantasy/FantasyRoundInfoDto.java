package com.kurs.kpfl.dto.fantasy;

import java.time.LocalDateTime;

public record FantasyRoundInfoDto(
        Integer seasonYear,
        Integer roundNumber,
        LocalDateTime lockAt,
        boolean locked
) {
}
