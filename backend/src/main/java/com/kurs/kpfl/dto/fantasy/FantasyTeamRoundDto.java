package com.kurs.kpfl.dto.fantasy;

import java.time.LocalDateTime;
import java.util.List;

public record FantasyTeamRoundDto(
        Integer seasonYear,
        Integer roundNumber,
        LocalDateTime lockedAt,
        boolean finalized,
        Long captainPlayerId,
        Long viceCaptainPlayerId,
        Integer points,
        Integer transferPenalty,
        Integer finalPoints,
        Integer rankSnapshot,
        List<FantasyLineupPlayerDto> lineup,
        List<FantasyPlayerRoundPointsDto> playerPoints
) {
}
