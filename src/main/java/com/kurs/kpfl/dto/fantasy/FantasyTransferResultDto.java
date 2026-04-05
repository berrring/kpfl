package com.kurs.kpfl.dto.fantasy;

import java.math.BigDecimal;
import java.util.List;

public record FantasyTransferResultDto(
        Long teamId,
        Integer seasonYear,
        Integer roundNumber,
        int transfersMade,
        int freeTransfersUsed,
        int transferPenalty,
        BigDecimal currentBudget,
        boolean lineupReset,
        List<FantasySquadPlayerDto> squad
) {
}
