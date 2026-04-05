package com.kurs.kpfl.service.fantasy;

import com.kurs.kpfl.dto.fantasy.*;
import com.kurs.kpfl.entity.User;

import java.util.List;

public interface FantasyTeamService {
    FantasyTeamOverviewDto createTeam(User user, FantasyTeamCreateRequest request);
    FantasyTeamOverviewDto getTeamOverview(User user);
    FantasyTeamSquadDto getTeamSquad(User user);
    FantasyTeamSquadDto updateSquad(User user, FantasySquadUpdateRequest request);
    FantasyTeamRoundDto saveLineup(User user, FantasyLineupUpdateRequest request);
    FantasyTransferResultDto performTransfers(User user, FantasyTransferRequest request);
    FantasyTeamRoundDto getRoundDetails(User user, Integer seasonYear, Integer roundNumber);
    List<FantasyHistoryItemDto> getHistory(User user, Integer seasonYear);
    List<FantasyLeaderboardEntryDto> getGlobalLeaderboard(Integer seasonYear);
}
