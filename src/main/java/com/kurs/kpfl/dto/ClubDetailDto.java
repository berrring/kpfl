package com.kurs.kpfl.dto;
import java.util.List;
public record ClubDetailDto(Long id, String name, String abbr, String city, String logoUrl, String stadium, Integer foundedYear, List<PlayerListItemDto> players) {}