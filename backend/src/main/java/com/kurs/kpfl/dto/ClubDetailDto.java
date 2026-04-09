package com.kurs.kpfl.dto;
import java.util.List;
public record ClubDetailDto(
        Long id,
        String name,
        String abbr,
        String city,
        String logoUrl,
        String primaryColor,
        String stadium,
        Integer foundedYear,
        String coachName,
        String coachInfo,
        List<PlayerListItemDto> players
) {}
