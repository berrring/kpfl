package com.kurs.kpfl.service.fantasy.impl;

import com.kurs.kpfl.dto.fantasy.FantasyLeagueCreateRequest;
import com.kurs.kpfl.dto.fantasy.FantasyLeagueDto;
import com.kurs.kpfl.dto.fantasy.FantasyLeagueJoinRequest;
import com.kurs.kpfl.dto.fantasy.FantasyLeaderboardEntryDto;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.User;
import com.kurs.kpfl.entity.fantasy.FantasyLeague;
import com.kurs.kpfl.entity.fantasy.FantasyLeagueMember;
import com.kurs.kpfl.entity.fantasy.FantasyTeam;
import com.kurs.kpfl.exception.ConflictException;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.repository.fantasy.FantasyLeagueMemberRepository;
import com.kurs.kpfl.repository.fantasy.FantasyLeagueRepository;
import com.kurs.kpfl.repository.fantasy.FantasyTeamRepository;
import com.kurs.kpfl.service.fantasy.FantasyLeagueService;
import com.kurs.kpfl.service.fantasy.FantasyRoundService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.atomic.AtomicInteger;

@Service
@RequiredArgsConstructor
@Transactional
public class FantasyLeagueServiceImpl implements FantasyLeagueService {

    private static final String LEAGUE_CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    private final FantasyLeagueRepository fantasyLeagueRepository;
    private final FantasyLeagueMemberRepository fantasyLeagueMemberRepository;
    private final FantasyTeamRepository fantasyTeamRepository;
    private final FantasyRoundService fantasyRoundService;

    @Override
    @Transactional(readOnly = true)
    public List<FantasyLeagueDto> getMyLeagues(User user) {
        Season season = fantasyRoundService.getCurrentSeason();
        FantasyTeam team = fantasyTeamRepository.findByUserIdAndSeasonId(user.getId(), season.getId()).orElse(null);
        if (team == null) {
            return List.of();
        }
        return fantasyLeagueMemberRepository.findByFantasyTeamId(team.getId()).stream()
                .map(FantasyLeagueMember::getFantasyLeague)
                .sorted(Comparator.comparing(FantasyLeague::getCreatedAt).reversed())
                .map(this::toDto)
                .toList();
    }

    @Override
    public FantasyLeagueDto createLeague(User user, FantasyLeagueCreateRequest request) {
        Season season = fantasyRoundService.getCurrentSeason();
        FantasyTeam team = resolveTeam(user, season);

        FantasyLeague league = fantasyLeagueRepository.save(FantasyLeague.builder()
                .season(season)
                .owner(user)
                .name(request.getName())
                .code(generateUniqueCode())
                .isPrivate(Boolean.TRUE)
                .createdAt(LocalDateTime.now())
                .build());

        fantasyLeagueMemberRepository.save(FantasyLeagueMember.builder()
                .fantasyLeague(league)
                .fantasyTeam(team)
                .joinedAt(LocalDateTime.now())
                .build());
        return toDto(league);
    }

    @Override
    public FantasyLeagueDto joinLeague(User user, FantasyLeagueJoinRequest request) {
        Season season = fantasyRoundService.getCurrentSeason();
        FantasyTeam team = resolveTeam(user, season);
        FantasyLeague league = fantasyLeagueRepository.findByCodeIgnoreCase(request.getCode().trim())
                .orElseThrow(() -> new NotFoundException("Fantasy league not found for code " + request.getCode()));

        if (!league.getSeason().getId().equals(team.getSeason().getId())) {
            throw new IllegalArgumentException("Fantasy league belongs to a different season.");
        }
        if (fantasyLeagueMemberRepository.existsByFantasyLeagueIdAndFantasyTeamId(league.getId(), team.getId())) {
            throw new ConflictException("Fantasy team is already a member of this league.");
        }

        fantasyLeagueMemberRepository.save(FantasyLeagueMember.builder()
                .fantasyLeague(league)
                .fantasyTeam(team)
                .joinedAt(LocalDateTime.now())
                .build());
        return toDto(league);
    }

    @Override
    @Transactional(readOnly = true)
    public List<FantasyLeaderboardEntryDto> getLeagueLeaderboard(Long leagueId) {
        FantasyLeague league = fantasyLeagueRepository.findById(leagueId)
                .orElseThrow(() -> new NotFoundException("Fantasy league not found with id " + leagueId));

        AtomicInteger rank = new AtomicInteger(1);
        return fantasyLeagueMemberRepository.findByFantasyLeagueId(league.getId()).stream()
                .map(FantasyLeagueMember::getFantasyTeam)
                .sorted(Comparator.comparing(FantasyTeam::getTotalPoints).reversed()
                        .thenComparing(FantasyTeam::getName))
                .map(team -> new FantasyLeaderboardEntryDto(
                        rank.getAndIncrement(),
                        team.getId(),
                        team.getName(),
                        ownerDisplayName(team.getUser()),
                        team.getTotalPoints()
                ))
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<FantasyLeagueDto> getLeagues(Integer seasonYear) {
        Season season = fantasyRoundService.resolveSeason(seasonYear);
        return fantasyLeagueRepository.findBySeasonIdOrderByCreatedAtDesc(season.getId()).stream()
                .map(this::toDto)
                .toList();
    }

    private FantasyTeam resolveTeam(User user, Season season) {
        return fantasyTeamRepository.findByUserIdAndSeasonId(user.getId(), season.getId())
                .orElseThrow(() -> new NotFoundException("Fantasy team not found for the current user."));
    }

    private FantasyLeagueDto toDto(FantasyLeague league) {
        return new FantasyLeagueDto(
                league.getId(),
                league.getName(),
                league.getCode(),
                league.getIsPrivate(),
                league.getSeason().getYear(),
                ownerDisplayName(league.getOwner()),
                fantasyLeagueMemberRepository.countByFantasyLeagueId(league.getId())
        );
    }

    private String ownerDisplayName(User user) {
        return user.getDisplayName() == null || user.getDisplayName().isBlank()
                ? user.getEmail()
                : user.getDisplayName();
    }

    private String generateUniqueCode() {
        String code;
        do {
            StringBuilder builder = new StringBuilder(8);
            for (int i = 0; i < 8; i++) {
                int index = ThreadLocalRandom.current().nextInt(LEAGUE_CODE_CHARS.length());
                builder.append(LEAGUE_CODE_CHARS.charAt(index));
            }
            code = builder.toString().toUpperCase(Locale.ROOT);
        } while (fantasyLeagueRepository.findByCodeIgnoreCase(code).isPresent());
        return code;
    }
}
