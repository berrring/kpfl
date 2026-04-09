package com.kurs.kpfl.dto.history;

public record KpflTopAppearanceAllTimeDto(
        Long id,
        Integer rankNo,
        String playerName,
        String positionName,
        Integer matchesPlayed,
        Integer goals,
        String sourceNote
) {
}
