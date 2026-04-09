package com.kurs.kpfl.dto.fantasy;

import java.math.BigDecimal;
import java.util.List;

public record FantasyTeamSquadDto(
        Long teamId,
        String teamName,
        Integer seasonYear,
        Integer totalPoints,
        BigDecimal currentBudget,
        BigDecimal squadValue,
        List<FantasySquadPlayerDto> players
) {
}
