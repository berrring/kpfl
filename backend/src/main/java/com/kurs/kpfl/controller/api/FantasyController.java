package com.kurs.kpfl.controller.api;

import com.kurs.kpfl.dto.fantasy.FantasyLeaderboardEntryDto;
import com.kurs.kpfl.dto.fantasy.FantasyRoundInfoDto;
import com.kurs.kpfl.service.fantasy.FantasyLeagueService;
import com.kurs.kpfl.service.fantasy.FantasyRoundService;
import com.kurs.kpfl.service.fantasy.FantasyTeamService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/fantasy")
@RequiredArgsConstructor
public class FantasyController {

    private final FantasyTeamService fantasyTeamService;
    private final FantasyLeagueService fantasyLeagueService;
    private final FantasyRoundService fantasyRoundService;

    @GetMapping("/leaderboard")
    public List<FantasyLeaderboardEntryDto> getLeaderboard(@RequestParam(required = false) Integer seasonYear) {
        return fantasyTeamService.getGlobalLeaderboard(seasonYear);
    }

    @GetMapping("/leagues/{leagueId}/leaderboard")
    public List<FantasyLeaderboardEntryDto> getLeagueLeaderboard(@PathVariable Long leagueId) {
        return fantasyLeagueService.getLeagueLeaderboard(leagueId);
    }

    @GetMapping("/rounds/current")
    public FantasyRoundInfoDto getCurrentRound() {
        return fantasyRoundService.getCurrentRoundInfo();
    }
}
