package com.kurs.kpfl.service.admin;

import com.kurs.kpfl.dto.MatchDetailDto;
import com.kurs.kpfl.dto.admin.AdminMatchResultRequest;
import com.kurs.kpfl.dto.admin.AdminMatchUpsertRequest;
import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.model.MatchStatus;
import com.kurs.kpfl.repository.ClubRepository;
import com.kurs.kpfl.repository.MatchRepository;
import com.kurs.kpfl.repository.SeasonRepository;
import com.kurs.kpfl.service.MatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminMatchService {

    private final MatchRepository matchRepository;
    private final ClubRepository clubRepository;
    private final SeasonRepository seasonRepository;
    private final MatchService matchService;

    public MatchDetailDto create(AdminMatchUpsertRequest request) {
        validate(request.getHomeClubId(), request.getAwayClubId(), request.getStatus(), request.getHomeGoals(), request.getAwayGoals());
        Match match = new Match();
        map(request, match);
        match.setCreatedAt(LocalDateTime.now());
        Match saved = matchRepository.save(match);
        return matchService.getMatchDetail(saved.getId());
    }

    public MatchDetailDto update(Long id, AdminMatchUpsertRequest request) {
        validate(request.getHomeClubId(), request.getAwayClubId(), request.getStatus(), request.getHomeGoals(), request.getAwayGoals());
        Match match = matchRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Match not found with id " + id));
        map(request, match);
        matchRepository.save(match);
        return matchService.getMatchDetail(match.getId());
    }

    public MatchDetailDto setResult(Long id, AdminMatchResultRequest request) {
        Match match = matchRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Match not found with id " + id));
        match.setHomeScore(request.getHomeGoals());
        match.setAwayScore(request.getAwayGoals());
        match.setStatus(MatchStatus.FINISHED);
        matchRepository.save(match);
        return matchService.getMatchDetail(match.getId());
    }

    private void map(AdminMatchUpsertRequest request, Match match) {
        Club homeClub = clubRepository.findById(request.getHomeClubId())
                .orElseThrow(() -> new NotFoundException("Club not found with id " + request.getHomeClubId()));
        Club awayClub = clubRepository.findById(request.getAwayClubId())
                .orElseThrow(() -> new NotFoundException("Club not found with id " + request.getAwayClubId()));
        Season season = seasonRepository.findByYear(request.getSeasonYear())
                .orElseGet(() -> seasonRepository.save(Season.builder()
                        .year(request.getSeasonYear())
                        .name("KPFL " + request.getSeasonYear())
                        .build()));

        match.setSeason(season);
        match.setRound(request.getRoundNumber());
        match.setDateTime(request.getDateTime());
        match.setStadium(request.getStadium());
        match.setHomeClub(homeClub);
        match.setAwayClub(awayClub);
        match.setHomeScore(request.getHomeGoals());
        match.setAwayScore(request.getAwayGoals());
        match.setStatus(request.getStatus());
    }

    private void validate(Long homeClubId, Long awayClubId, MatchStatus status, Integer homeGoals, Integer awayGoals) {
        if (homeClubId.equals(awayClubId)) {
            throw new IllegalArgumentException("homeClubId and awayClubId must be different");
        }

        if (status == MatchStatus.FINISHED && (homeGoals == null || awayGoals == null)) {
            throw new IllegalArgumentException("Finished match must contain both goals values");
        }

        if (status != MatchStatus.FINISHED && (homeGoals != null || awayGoals != null)) {
            throw new IllegalArgumentException("Only FINISHED match can contain goals");
        }
    }
}
