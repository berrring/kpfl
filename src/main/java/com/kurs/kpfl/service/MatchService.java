package com.kurs.kpfl.service;

import com.kurs.kpfl.dto.MatchDetailDto;
import com.kurs.kpfl.dto.MatchListItemDto;
import com.kurs.kpfl.model.MatchStatus;

import java.time.LocalDate;
import java.util.List;

public interface MatchService {
    List<MatchListItemDto> getMatches(
            Integer seasonYear,
            Integer round,
            Long clubId,
            LocalDate dateFrom,
            LocalDate dateTo,
            MatchStatus status
    );
    MatchDetailDto getMatchDetail(Long id);
}
