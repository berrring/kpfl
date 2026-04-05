package com.kurs.kpfl.service.fantasy;

import com.kurs.kpfl.dto.fantasy.FantasyRoundRecalculationDto;

public interface FantasyScoringService {
    FantasyRoundRecalculationDto recalculateRound(Long seasonId, Integer roundNumber);
}
