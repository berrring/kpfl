package com.kurs.kpfl.service.fantasy;

import com.kurs.kpfl.dto.fantasy.FantasyLeagueCreateRequest;
import com.kurs.kpfl.dto.fantasy.FantasyLeagueDto;
import com.kurs.kpfl.dto.fantasy.FantasyLeagueJoinRequest;
import com.kurs.kpfl.dto.fantasy.FantasyLeaderboardEntryDto;
import com.kurs.kpfl.entity.User;

import java.util.List;

public interface FantasyLeagueService {
    List<FantasyLeagueDto> getMyLeagues(User user);
    FantasyLeagueDto createLeague(User user, FantasyLeagueCreateRequest request);
    FantasyLeagueDto joinLeague(User user, FantasyLeagueJoinRequest request);
    List<FantasyLeaderboardEntryDto> getLeagueLeaderboard(Long leagueId);
    List<FantasyLeagueDto> getLeagues(Integer seasonYear);
}
