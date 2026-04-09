package com.kurs.kpfl.service;

import com.kurs.kpfl.dto.history.KpflChampionHistoryDto;
import com.kurs.kpfl.dto.history.KpflClubHonoursDto;
import com.kurs.kpfl.dto.history.KpflLeagueRecordDto;
import com.kurs.kpfl.dto.history.KpflSeasonStandingsArchiveDto;
import com.kurs.kpfl.dto.history.KpflTopAppearanceAllTimeDto;
import com.kurs.kpfl.dto.history.KpflTopScorerAllTimeDto;

import java.util.List;

public interface KpflHistoryService {
    List<KpflChampionHistoryDto> getChampions(Integer fromYear, Integer toYear);

    KpflChampionHistoryDto getChampionBySeasonYear(Integer seasonYear);

    List<KpflClubHonoursDto> getClubHonours();

    List<KpflSeasonStandingsArchiveDto> getSeasonStandings(Integer seasonYear);

    List<Integer> getSeasonStandingsYears();

    List<KpflLeagueRecordDto> getLeagueRecords();

    List<KpflTopScorerAllTimeDto> getTopScorers();

    List<KpflTopAppearanceAllTimeDto> getTopAppearances();
}
