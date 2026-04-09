package com.kurs.kpfl.dto.history;

public record KpflClubHonoursDto(
        Long id,
        String clubName,
        Integer titles,
        Integer runnerUpCount,
        Integer thirdPlaceCount,
        String championshipYears
) {
}
