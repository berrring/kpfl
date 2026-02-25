package com.kurs.kpfl.service;

import com.kurs.kpfl.dto.MatchDetailDto;
import com.kurs.kpfl.dto.MatchListItemDto;

import java.time.LocalDate;
import java.util.List;

public interface MatchService {
    List<MatchListItemDto> getMatches(Integer seasonYear, Integer round, Long clubId, LocalDate dateFrom, LocalDate dateTo);
    MatchDetailDto getMatchDetail(Long id);
}