package com.kurs.kpfl.dto;
import java.time.LocalDateTime;
public record NewsListItemDto(Long id, String title, String tag, LocalDateTime publishedAt) {}