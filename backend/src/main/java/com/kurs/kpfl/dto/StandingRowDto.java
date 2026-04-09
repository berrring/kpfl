package com.kurs.kpfl.dto;

public record StandingRowDto(
        Integer position,
        ClubListItemDto club,
        Integer played,
        Integer wins,
        Integer draws,
        Integer losses,
        Integer goalsFor,
        Integer goalsAgainst,
        Integer goalDifference,
        Integer points
) {
}
