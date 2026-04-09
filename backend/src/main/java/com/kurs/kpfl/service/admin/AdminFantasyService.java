package com.kurs.kpfl.service.admin;

import com.kurs.kpfl.dto.admin.AdminFantasyPlayerStatUpsertRequest;
import com.kurs.kpfl.dto.fantasy.*;
import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.fantasy.FantasyLeague;
import com.kurs.kpfl.entity.fantasy.FantasyPlayerMatchStat;
import com.kurs.kpfl.entity.fantasy.FantasyTeam;
import com.kurs.kpfl.exception.ConflictException;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.model.PlayerPosition;
import com.kurs.kpfl.repository.MatchRepository;
import com.kurs.kpfl.repository.PlayerRepository;
import com.kurs.kpfl.repository.fantasy.FantasyLeagueRepository;
import com.kurs.kpfl.repository.fantasy.FantasyPlayerMatchStatRepository;
import com.kurs.kpfl.repository.fantasy.FantasyTeamPlayerRepository;
import com.kurs.kpfl.repository.fantasy.FantasyTeamRepository;
import com.kurs.kpfl.service.fantasy.FantasyLeagueService;
import com.kurs.kpfl.service.fantasy.FantasyPricingService;
import com.kurs.kpfl.service.fantasy.FantasyRoundService;
import com.kurs.kpfl.service.fantasy.FantasyScoringService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminFantasyService {

    private final FantasyPlayerMatchStatRepository fantasyPlayerMatchStatRepository;
    private final MatchRepository matchRepository;
    private final PlayerRepository playerRepository;
    private final FantasyScoringService fantasyScoringService;
    private final FantasyPricingService fantasyPricingService;
    private final FantasyRoundService fantasyRoundService;
    private final FantasyTeamRepository fantasyTeamRepository;
    private final FantasyTeamPlayerRepository fantasyTeamPlayerRepository;
    private final FantasyLeagueRepository fantasyLeagueRepository;
    private final FantasyLeagueService fantasyLeagueService;

    public FantasyPlayerMatchStatDto createPlayerStat(AdminFantasyPlayerStatUpsertRequest request) {
        if (fantasyPlayerMatchStatRepository.findByPlayerIdAndMatchId(request.getPlayerId(), request.getMatchId()).isPresent()) {
            throw new ConflictException("Fantasy player stats already exist for this player and match.");
        }
        return toDto(fantasyPlayerMatchStatRepository.save(mapRequest(request, new FantasyPlayerMatchStat())));
    }

    public FantasyPlayerMatchStatDto updatePlayerStat(Long id, AdminFantasyPlayerStatUpsertRequest request) {
        FantasyPlayerMatchStat existing = fantasyPlayerMatchStatRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Fantasy player stats not found with id " + id));
        return toDto(fantasyPlayerMatchStatRepository.save(mapRequest(request, existing)));
    }

    @Transactional(readOnly = true)
    public List<FantasyPlayerMatchStatDto> getMatchStats(Long matchId) {
        return fantasyPlayerMatchStatRepository.findByMatchId(matchId).stream()
                .map(this::toDto)
                .toList();
    }

    public FantasyRoundRecalculationDto recalculateRound(Long seasonId, Integer roundNumber) {
        return fantasyScoringService.recalculateRound(seasonId, roundNumber);
    }

    public List<FantasyPriceDto> rebuildPrices() {
        return fantasyPricingService.rebuildCurrentSeasonPrices();
    }

    public FantasyPriceDto rebuildPrice(Long playerId) {
        return fantasyPricingService.rebuildCurrentSeasonPriceForPlayer(playerId);
    }

    @Transactional(readOnly = true)
    public List<FantasyAdminTeamDto> getTeams() {
        Season season = fantasyRoundService.getCurrentSeason();
        return fantasyTeamRepository.findBySeasonIdAndActiveTrue(season.getId()).stream()
                .map(this::toTeamDto)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<FantasyLeagueDto> getLeagues() {
        Season season = fantasyRoundService.getCurrentSeason();
        return fantasyLeagueService.getLeagues(season.getYear());
    }

    private FantasyPlayerMatchStat mapRequest(AdminFantasyPlayerStatUpsertRequest request, FantasyPlayerMatchStat target) {
        Match match = matchRepository.findById(request.getMatchId())
                .orElseThrow(() -> new NotFoundException("Match not found with id " + request.getMatchId()));
        Player player = playerRepository.findById(request.getPlayerId())
                .orElseThrow(() -> new NotFoundException("Player not found with id " + request.getPlayerId()));

        boolean playerInMatchClub = player.getClub().getId().equals(match.getHomeClub().getId())
                || player.getClub().getId().equals(match.getAwayClub().getId());
        if (!playerInMatchClub) {
            throw new IllegalArgumentException("Player does not belong to either club in the specified match.");
        }
        if (Boolean.TRUE.equals(request.getCleanSheet()) && defaultInt(request.getGoalsConceded()) > 0) {
            throw new IllegalArgumentException("Clean sheet cannot be true when goals conceded is greater than zero.");
        }
        if (Boolean.TRUE.equals(request.getStarted()) && Boolean.TRUE.equals(request.getSubstitutedIn())) {
            throw new IllegalArgumentException("A player cannot start and be marked as substituted in.");
        }
        if (player.getPosition() != PlayerPosition.GK
                && (defaultInt(request.getPenaltiesSaved()) > 0 || defaultInt(request.getSaves()) > 0)) {
            throw new IllegalArgumentException("Only goalkeepers can record saves or penalties saved.");
        }

        target.setPlayer(player);
        target.setMatch(match);
        target.setMinutesPlayed(request.getMinutesPlayed());
        target.setGoals(defaultInt(request.getGoals()));
        target.setAssists(defaultInt(request.getAssists()));
        target.setCleanSheet(Boolean.TRUE.equals(request.getCleanSheet()));
        target.setGoalsConceded(defaultInt(request.getGoalsConceded()));
        target.setYellowCards(defaultInt(request.getYellowCards()));
        target.setRedCards(defaultInt(request.getRedCards()));
        target.setOwnGoals(defaultInt(request.getOwnGoals()));
        target.setPenaltiesSaved(defaultInt(request.getPenaltiesSaved()));
        target.setPenaltiesMissed(defaultInt(request.getPenaltiesMissed()));
        target.setSaves(defaultInt(request.getSaves()));
        target.setStarted(Boolean.TRUE.equals(request.getStarted()));
        target.setSubstitutedIn(Boolean.TRUE.equals(request.getSubstitutedIn()));
        target.setSubstitutedOut(Boolean.TRUE.equals(request.getSubstitutedOut()));
        target.setCreatedAt(target.getCreatedAt() == null ? LocalDateTime.now() : target.getCreatedAt());
        target.setUpdatedAt(LocalDateTime.now());
        return target;
    }

    private FantasyPlayerMatchStatDto toDto(FantasyPlayerMatchStat stat) {
        return new FantasyPlayerMatchStatDto(
                stat.getId(),
                stat.getPlayer().getId(),
                stat.getPlayer().getFirstName() + " " + stat.getPlayer().getLastName(),
                stat.getMatch().getId(),
                stat.getMatch().getSeason().getYear(),
                stat.getMatch().getRound(),
                stat.getMinutesPlayed(),
                stat.getGoals(),
                stat.getAssists(),
                stat.getCleanSheet(),
                stat.getGoalsConceded(),
                stat.getYellowCards(),
                stat.getRedCards(),
                stat.getOwnGoals(),
                stat.getPenaltiesSaved(),
                stat.getPenaltiesMissed(),
                stat.getSaves(),
                stat.getStarted(),
                stat.getSubstitutedIn(),
                stat.getSubstitutedOut()
        );
    }

    private FantasyAdminTeamDto toTeamDto(FantasyTeam team) {
        return new FantasyAdminTeamDto(
                team.getId(),
                team.getName(),
                team.getUser().getEmail(),
                team.getUser().getDisplayName(),
                team.getSeason().getYear(),
                team.getTotalPoints(),
                team.getCurrentBudget(),
                fantasyTeamPlayerRepository.countByFantasyTeamIdAndActiveTrue(team.getId())
        );
    }

    private int defaultInt(Integer value) {
        return value == null ? 0 : value;
    }
}
