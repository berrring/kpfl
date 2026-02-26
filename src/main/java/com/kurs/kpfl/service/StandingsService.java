package com.kurs.kpfl.service;

import com.kurs.kpfl.dto.StandingRowDto;

import java.util.List;

public interface StandingsService {
    List<StandingRowDto> getStandings(Integer seasonYear);
}
