package com.kurs.kpfl.dto;
import java.time.LocalDateTime;
public record NewsDetailDto(
        Long id,
        String title,
        String tag,
        LocalDateTime publishedAt,
        String shortText,
        ClubListItemDto club,
        PlayerListItemDto player
) {}
