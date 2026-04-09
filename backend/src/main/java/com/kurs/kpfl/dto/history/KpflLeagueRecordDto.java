package com.kurs.kpfl.dto.history;

public record KpflLeagueRecordDto(
        Long id,
        String recordKey,
        String recordValue,
        String sourceNote
) {
}
