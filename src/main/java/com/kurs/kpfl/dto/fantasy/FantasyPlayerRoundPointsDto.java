package com.kurs.kpfl.dto.fantasy;

public record FantasyPlayerRoundPointsDto(
        Long playerId,
        String firstName,
        String lastName,
        String position,
        String clubName,
        Integer rawPoints,
        Integer appliedPoints,
        boolean starter,
        boolean captainApplied,
        boolean viceCaptainApplied,
        boolean autoSubApplied,
        String explanation
) {
}
