package com.kurs.kpfl.dto;
import java.time.LocalDateTime;
import java.util.List;
public record MatchDetailDto(Long id, LocalDateTime dateTime, String status, ClubListItemDto homeClub, ClubListItemDto awayClub, String score, String stadium, Integer round, Integer seasonYear, List<String> events) {}