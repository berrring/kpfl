package com.kurs.kpfl.dto;

import java.time.LocalDate;

public record SeasonDto(
        Long id,
        Integer year,
        String name,
        LocalDate startDate,
        LocalDate endDate
) {
}
