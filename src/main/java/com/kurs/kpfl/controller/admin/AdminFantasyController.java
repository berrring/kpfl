package com.kurs.kpfl.controller.admin;

import com.kurs.kpfl.dto.admin.AdminFantasyPlayerStatUpsertRequest;
import com.kurs.kpfl.dto.fantasy.*;
import com.kurs.kpfl.service.admin.AdminFantasyService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/fantasy")
@RequiredArgsConstructor
public class AdminFantasyController {

    private final AdminFantasyService adminFantasyService;

    @PostMapping("/player-stats")
    public FantasyPlayerMatchStatDto createPlayerStats(@Valid @RequestBody AdminFantasyPlayerStatUpsertRequest request) {
        return adminFantasyService.createPlayerStat(request);
    }

    @PutMapping("/player-stats/{id}")
    public FantasyPlayerMatchStatDto updatePlayerStats(
            @PathVariable Long id,
            @Valid @RequestBody AdminFantasyPlayerStatUpsertRequest request
    ) {
        return adminFantasyService.updatePlayerStat(id, request);
    }

    @GetMapping("/player-stats/match/{matchId}")
    public List<FantasyPlayerMatchStatDto> getMatchStats(@PathVariable Long matchId) {
        return adminFantasyService.getMatchStats(matchId);
    }

    @PostMapping("/recalculate/round/{seasonId}/{roundNumber}")
    public FantasyRoundRecalculationDto recalculateRound(@PathVariable Long seasonId, @PathVariable Integer roundNumber) {
        return adminFantasyService.recalculateRound(seasonId, roundNumber);
    }

    @PostMapping("/prices/rebuild")
    public List<FantasyPriceDto> rebuildPrices() {
        return adminFantasyService.rebuildPrices();
    }

    @PostMapping("/prices/player/{playerId}")
    public FantasyPriceDto rebuildPlayerPrice(@PathVariable Long playerId) {
        return adminFantasyService.rebuildPrice(playerId);
    }

    @GetMapping("/teams")
    public List<FantasyAdminTeamDto> getTeams() {
        return adminFantasyService.getTeams();
    }

    @GetMapping("/leagues")
    public List<FantasyLeagueDto> getLeagues() {
        return adminFantasyService.getLeagues();
    }
}
