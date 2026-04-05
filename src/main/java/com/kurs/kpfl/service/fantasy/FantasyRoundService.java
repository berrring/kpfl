package com.kurs.kpfl.service.fantasy;

import com.kurs.kpfl.dto.fantasy.FantasyRoundInfoDto;
import com.kurs.kpfl.entity.Season;

import java.time.LocalDateTime;

public interface FantasyRoundService {
    Season getCurrentSeason();
    Season resolveSeason(Integer seasonYear);
    int getFirstRoundNumber(Season season);
    int getLastRoundNumber(Season season);
    int getUpcomingRoundNumber(Season season);
    LocalDateTime getRoundLock(Season season, int roundNumber);
    boolean isRoundLocked(Season season, int roundNumber);
    FantasyRoundInfoDto getCurrentRoundInfo();
}
