package com.kurs.kpfl.dto.fantasy;

public record FantasyHistoryItemDto(
        Integer seasonYear,
        Integer roundNumber,
        Integer points,
        Integer transferPenalty,
        Integer finalPoints,
        Integer cumulativePoints,
        Integer rankSnapshot
) {
}
