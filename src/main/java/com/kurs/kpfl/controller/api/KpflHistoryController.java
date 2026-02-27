package com.kurs.kpfl.controller.api;

import com.kurs.kpfl.dto.history.KpflChampionHistoryDto;
import com.kurs.kpfl.dto.history.KpflClubHonoursDto;
import com.kurs.kpfl.dto.history.KpflLeagueRecordDto;
import com.kurs.kpfl.dto.history.KpflSeasonStandingsArchiveDto;
import com.kurs.kpfl.dto.history.KpflTopAppearanceAllTimeDto;
import com.kurs.kpfl.dto.history.KpflTopScorerAllTimeDto;
import com.kurs.kpfl.service.KpflHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/history")
@RequiredArgsConstructor
public class KpflHistoryController {

    private final KpflHistoryService historyService;

    @GetMapping("/champions")
    public List<KpflChampionHistoryDto> getChampions(
            @RequestParam(required = false) Integer fromYear,
            @RequestParam(required = false) Integer toYear
    ) {
        return historyService.getChampions(fromYear, toYear);
    }

    @GetMapping("/champions/{seasonYear}")
    public KpflChampionHistoryDto getChampionBySeason(@PathVariable Integer seasonYear) {
        return historyService.getChampionBySeasonYear(seasonYear);
    }

    @GetMapping("/club-honours")
    public List<KpflClubHonoursDto> getClubHonours() {
        return historyService.getClubHonours();
    }

    @GetMapping("/standings")
    public List<KpflSeasonStandingsArchiveDto> getStandings(@RequestParam(required = false) Integer seasonYear) {
        return historyService.getSeasonStandings(seasonYear);
    }

    @GetMapping("/standings/seasons")
    public List<Integer> getStandingsSeasons() {
        return historyService.getSeasonStandingsYears();
    }

    @GetMapping("/records")
    public List<KpflLeagueRecordDto> getRecords() {
        return historyService.getLeagueRecords();
    }

    @GetMapping("/top-scorers")
    public List<KpflTopScorerAllTimeDto> getTopScorers() {
        return historyService.getTopScorers();
    }

    @GetMapping("/top-appearances")
    public List<KpflTopAppearanceAllTimeDto> getTopAppearances() {
        return historyService.getTopAppearances();
    }
}
