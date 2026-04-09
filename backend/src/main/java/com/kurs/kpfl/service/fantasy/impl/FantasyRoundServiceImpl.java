package com.kurs.kpfl.service.fantasy.impl;

import com.kurs.kpfl.dto.fantasy.FantasyRoundInfoDto;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.repository.MatchRepository;
import com.kurs.kpfl.repository.SeasonRepository;
import com.kurs.kpfl.service.fantasy.FantasyRoundService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FantasyRoundServiceImpl implements FantasyRoundService {

    private final SeasonRepository seasonRepository;
    private final MatchRepository matchRepository;

    @Override
    public Season getCurrentSeason() {
        return seasonRepository.findFirstByOrderByYearDesc()
                .orElseThrow(() -> new NotFoundException("Current season not found."));
    }

    @Override
    public Season resolveSeason(Integer seasonYear) {
        if (seasonYear == null) {
            return getCurrentSeason();
        }
        return seasonRepository.findByYear(seasonYear)
                .orElseThrow(() -> new NotFoundException("Season not found for year " + seasonYear));
    }

    @Override
    public int getFirstRoundNumber(Season season) {
        return matchRepository.findFirstRoundNumber(season.getId())
                .orElseThrow(() -> new NotFoundException("No matches found for season " + season.getYear()));
    }

    @Override
    public int getLastRoundNumber(Season season) {
        return matchRepository.findLastRoundNumber(season.getId())
                .orElseThrow(() -> new NotFoundException("No matches found for season " + season.getYear()));
    }

    @Override
    public int getUpcomingRoundNumber(Season season) {
        int firstRound = getFirstRoundNumber(season);
        int lastRound = getLastRoundNumber(season);
        LocalDateTime now = LocalDateTime.now();

        for (int round = firstRound; round <= lastRound; round++) {
            LocalDateTime lock = getRoundLock(season, round);
            if (now.isBefore(lock)) {
                return round;
            }
        }

        return lastRound;
    }

    @Override
    public LocalDateTime getRoundLock(Season season, int roundNumber) {
        return matchRepository.findRoundLockTime(season.getId(), roundNumber)
                .orElseThrow(() -> new NotFoundException(
                        "Round " + roundNumber + " not found for season " + season.getYear()
                ));
    }

    @Override
    public boolean isRoundLocked(Season season, int roundNumber) {
        return !LocalDateTime.now().isBefore(getRoundLock(season, roundNumber));
    }

    @Override
    public FantasyRoundInfoDto getCurrentRoundInfo() {
        Season season = getCurrentSeason();
        int round = getUpcomingRoundNumber(season);
        LocalDateTime lock = getRoundLock(season, round);
        return new FantasyRoundInfoDto(season.getYear(), round, lock, !LocalDateTime.now().isBefore(lock));
    }
}
