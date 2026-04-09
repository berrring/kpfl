package com.kurs.kpfl.service.impl;

import com.kurs.kpfl.dto.history.KpflChampionHistoryDto;
import com.kurs.kpfl.dto.history.KpflClubHonoursDto;
import com.kurs.kpfl.dto.history.KpflLeagueRecordDto;
import com.kurs.kpfl.dto.history.KpflSeasonStandingsArchiveDto;
import com.kurs.kpfl.dto.history.KpflTopAppearanceAllTimeDto;
import com.kurs.kpfl.dto.history.KpflTopScorerAllTimeDto;
import com.kurs.kpfl.entity.archive.KpflChampionHistory;
import com.kurs.kpfl.entity.archive.KpflClubHonours;
import com.kurs.kpfl.entity.archive.KpflLeagueRecord;
import com.kurs.kpfl.entity.archive.KpflSeasonStandingsArchive;
import com.kurs.kpfl.entity.archive.KpflTopAppearanceAllTime;
import com.kurs.kpfl.entity.archive.KpflTopScorerAllTime;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.repository.archive.KpflChampionHistoryRepository;
import com.kurs.kpfl.repository.archive.KpflClubHonoursRepository;
import com.kurs.kpfl.repository.archive.KpflLeagueRecordRepository;
import com.kurs.kpfl.repository.archive.KpflSeasonStandingsArchiveRepository;
import com.kurs.kpfl.repository.archive.KpflTopAppearanceAllTimeRepository;
import com.kurs.kpfl.repository.archive.KpflTopScorerAllTimeRepository;
import com.kurs.kpfl.service.KpflHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class KpflHistoryServiceImpl implements KpflHistoryService {

    private final KpflChampionHistoryRepository championHistoryRepository;
    private final KpflClubHonoursRepository clubHonoursRepository;
    private final KpflSeasonStandingsArchiveRepository seasonStandingsArchiveRepository;
    private final KpflLeagueRecordRepository leagueRecordRepository;
    private final KpflTopScorerAllTimeRepository topScorerAllTimeRepository;
    private final KpflTopAppearanceAllTimeRepository topAppearanceAllTimeRepository;

    @Override
    public List<KpflChampionHistoryDto> getChampions(Integer fromYear, Integer toYear) {
        if (fromYear != null && toYear != null && fromYear > toYear) {
            throw new IllegalArgumentException("fromYear must be less than or equal to toYear");
        }

        return championHistoryRepository.findAllByOrderBySeasonYearAsc().stream()
                .filter(row -> fromYear == null || row.getSeasonYear() >= fromYear)
                .filter(row -> toYear == null || row.getSeasonYear() <= toYear)
                .map(this::toChampionDto)
                .toList();
    }

    @Override
    public KpflChampionHistoryDto getChampionBySeasonYear(Integer seasonYear) {
        KpflChampionHistory row = championHistoryRepository.findBySeasonYear(seasonYear)
                .orElseThrow(() -> new NotFoundException("Champion history not found for seasonYear " + seasonYear));
        return toChampionDto(row);
    }

    @Override
    public List<KpflClubHonoursDto> getClubHonours() {
        return clubHonoursRepository.findAllByOrderByTitlesDescRunnerUpCountDescThirdPlaceCountDescClubNameAsc().stream()
                .map(this::toClubHonoursDto)
                .toList();
    }

    @Override
    public List<KpflSeasonStandingsArchiveDto> getSeasonStandings(Integer seasonYear) {
        List<KpflSeasonStandingsArchive> rows = seasonYear == null
                ? seasonStandingsArchiveRepository.findAllByOrderBySeasonYearDescPlaceNoAsc()
                : seasonStandingsArchiveRepository.findBySeasonYearOrderByPlaceNoAsc(seasonYear);

        return rows.stream()
                .map(this::toSeasonStandingsDto)
                .toList();
    }

    @Override
    public List<Integer> getSeasonStandingsYears() {
        return seasonStandingsArchiveRepository.findDistinctSeasonYearsDesc();
    }

    @Override
    public List<KpflLeagueRecordDto> getLeagueRecords() {
        return leagueRecordRepository.findAllByOrderByRecordKeyAsc().stream()
                .map(this::toLeagueRecordDto)
                .toList();
    }

    @Override
    public List<KpflTopScorerAllTimeDto> getTopScorers() {
        return topScorerAllTimeRepository.findAllByOrderByRankNoAsc().stream()
                .map(this::toTopScorerDto)
                .toList();
    }

    @Override
    public List<KpflTopAppearanceAllTimeDto> getTopAppearances() {
        return topAppearanceAllTimeRepository.findAllByOrderByRankNoAsc().stream()
                .map(this::toTopAppearanceDto)
                .toList();
    }

    private KpflChampionHistoryDto toChampionDto(KpflChampionHistory row) {
        return new KpflChampionHistoryDto(
                row.getId(),
                row.getSeasonYear(),
                row.getChampion(),
                row.getChampionTitleNo(),
                row.getRunnerUp(),
                row.getThirdPlace(),
                row.getTopScorer(),
                row.getTopScorerGoals(),
                row.getTopScorerClub(),
                row.getPlayerOfYear(),
                row.getNotes()
        );
    }

    private KpflClubHonoursDto toClubHonoursDto(KpflClubHonours row) {
        return new KpflClubHonoursDto(
                row.getId(),
                row.getClubName(),
                row.getTitles(),
                row.getRunnerUpCount(),
                row.getThirdPlaceCount(),
                row.getChampionshipYears()
        );
    }

    private KpflSeasonStandingsArchiveDto toSeasonStandingsDto(KpflSeasonStandingsArchive row) {
        return new KpflSeasonStandingsArchiveDto(
                row.getId(),
                row.getSeasonYear(),
                row.getPlaceNo(),
                row.getClubName(),
                row.getPlayed(),
                row.getWins(),
                row.getDraws(),
                row.getLosses(),
                row.getGoalsFor(),
                row.getGoalsAgainst(),
                row.getGoalDifference(),
                row.getPoints(),
                row.getMatchesTotal()
        );
    }

    private KpflLeagueRecordDto toLeagueRecordDto(KpflLeagueRecord row) {
        return new KpflLeagueRecordDto(
                row.getId(),
                row.getRecordKey(),
                row.getRecordValue(),
                row.getSourceNote()
        );
    }

    private KpflTopScorerAllTimeDto toTopScorerDto(KpflTopScorerAllTime row) {
        return new KpflTopScorerAllTimeDto(
                row.getId(),
                row.getRankNo(),
                row.getPlayerName(),
                row.getPositionName(),
                row.getGoals(),
                row.getMatchesPlayed(),
                row.getGoalsPerMatch(),
                row.getSourceNote()
        );
    }

    private KpflTopAppearanceAllTimeDto toTopAppearanceDto(KpflTopAppearanceAllTime row) {
        return new KpflTopAppearanceAllTimeDto(
                row.getId(),
                row.getRankNo(),
                row.getPlayerName(),
                row.getPositionName(),
                row.getMatchesPlayed(),
                row.getGoals(),
                row.getSourceNote()
        );
    }
}
