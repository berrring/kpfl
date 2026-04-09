package com.kurs.kpfl.controller.me;

import com.kurs.kpfl.dto.fantasy.*;
import com.kurs.kpfl.entity.User;
import com.kurs.kpfl.service.fantasy.FantasyLeagueService;
import com.kurs.kpfl.service.fantasy.FantasyTeamService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/me/fantasy")
@RequiredArgsConstructor
public class MeFantasyController {

    private final FantasyTeamService fantasyTeamService;
    private final FantasyLeagueService fantasyLeagueService;

    @PostMapping("/team")
    public FantasyTeamOverviewDto createTeam(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FantasyTeamCreateRequest request
    ) {
        return fantasyTeamService.createTeam(user, request);
    }

    @GetMapping("/team")
    public FantasyTeamOverviewDto getTeam(@AuthenticationPrincipal User user) {
        return fantasyTeamService.getTeamOverview(user);
    }

    @GetMapping("/team/squad")
    public FantasyTeamSquadDto getSquad(@AuthenticationPrincipal User user) {
        return fantasyTeamService.getTeamSquad(user);
    }

    @PutMapping("/team/squad")
    public FantasyTeamSquadDto updateSquad(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FantasySquadUpdateRequest request
    ) {
        return fantasyTeamService.updateSquad(user, request);
    }

    @PutMapping("/team/lineup")
    public FantasyTeamRoundDto saveLineup(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FantasyLineupUpdateRequest request
    ) {
        return fantasyTeamService.saveLineup(user, request);
    }

    @PostMapping("/team/transfers")
    public FantasyTransferResultDto makeTransfers(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FantasyTransferRequest request
    ) {
        return fantasyTeamService.performTransfers(user, request);
    }

    @GetMapping("/team/rounds/{roundNumber}")
    public FantasyTeamRoundDto getRoundDetails(
            @AuthenticationPrincipal User user,
            @PathVariable Integer roundNumber,
            @RequestParam(required = false) Integer seasonYear
    ) {
        return fantasyTeamService.getRoundDetails(user, seasonYear, roundNumber);
    }

    @GetMapping("/team/history")
    public List<FantasyHistoryItemDto> getHistory(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) Integer seasonYear
    ) {
        return fantasyTeamService.getHistory(user, seasonYear);
    }

    @GetMapping("/leaderboard")
    public List<FantasyLeaderboardEntryDto> getLeaderboard(@RequestParam(required = false) Integer seasonYear) {
        return fantasyTeamService.getGlobalLeaderboard(seasonYear);
    }

    @GetMapping("/leagues")
    public List<FantasyLeagueDto> getMyLeagues(@AuthenticationPrincipal User user) {
        return fantasyLeagueService.getMyLeagues(user);
    }

    @PostMapping("/leagues")
    public FantasyLeagueDto createLeague(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FantasyLeagueCreateRequest request
    ) {
        return fantasyLeagueService.createLeague(user, request);
    }

    @PostMapping("/leagues/join")
    public FantasyLeagueDto joinLeague(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody FantasyLeagueJoinRequest request
    ) {
        return fantasyLeagueService.joinLeague(user, request);
    }
}
