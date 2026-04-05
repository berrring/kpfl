package com.kurs.kpfl.dto.fantasy;

public record FantasyLineupPlayerDto(
        Long playerId,
        String firstName,
        String lastName,
        String position,
        String clubName,
        boolean starter,
        Integer starterOrder,
        Integer benchOrder,
        boolean captain,
        boolean viceCaptain
) {
}
