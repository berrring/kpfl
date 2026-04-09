package com.kurs.kpfl.dto;
import java.time.LocalDateTime;
public record MatchListItemDto(Long id, LocalDateTime dateTime, String status, ClubListItemDto homeClub, ClubListItemDto awayClub, String score) {}