package com.kurs.kpfl.service.impl;

import com.kurs.kpfl.dto.ClubListItemDto;
import com.kurs.kpfl.dto.StandingRowDto;
import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.model.MatchStatus;
import com.kurs.kpfl.repository.MatchRepository;
import com.kurs.kpfl.service.StandingsService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class StandingsServiceImpl implements StandingsService {

    private final MatchRepository matchRepository;

    @Override
    public List<StandingRowDto> getStandings(Integer seasonYear) {
        Specification<Match> spec = (root, query, cb) -> seasonYear == null
                ? cb.conjunction()
                : cb.equal(root.get("season").get("year"), seasonYear);

        List<Match> matches = matchRepository.findAll(spec);
        return calculateStandings(matches);
    }

    List<StandingRowDto> calculateStandings(List<Match> matches) {
        Map<Long, TeamStats> table = new LinkedHashMap<>();

        for (Match match : matches) {
            TeamStats home = table.computeIfAbsent(match.getHomeClub().getId(), id -> TeamStats.of(match.getHomeClub()));
            TeamStats away = table.computeIfAbsent(match.getAwayClub().getId(), id -> TeamStats.of(match.getAwayClub()));

            if (match.getStatus() != MatchStatus.FINISHED || match.getHomeScore() == null || match.getAwayScore() == null) {
                continue;
            }

            int homeGoals = match.getHomeScore();
            int awayGoals = match.getAwayScore();

            home.played++;
            away.played++;

            home.goalsFor += homeGoals;
            home.goalsAgainst += awayGoals;
            away.goalsFor += awayGoals;
            away.goalsAgainst += homeGoals;

            if (homeGoals > awayGoals) {
                home.wins++;
                away.losses++;
                home.points += 3;
            } else if (homeGoals < awayGoals) {
                away.wins++;
                home.losses++;
                away.points += 3;
            } else {
                home.draws++;
                away.draws++;
                home.points++;
                away.points++;
            }
        }

        List<TeamStats> sorted = new ArrayList<>(table.values());
        sorted.sort(
                Comparator.comparingInt(TeamStats::points).reversed()
                        .thenComparing(Comparator.comparingInt(TeamStats::goalDifference).reversed())
                        .thenComparing(Comparator.comparingInt(TeamStats::goalsFor).reversed())
                        .thenComparing(ts -> ts.club.getName())
        );

        List<StandingRowDto> result = new ArrayList<>();
        for (int i = 0; i < sorted.size(); i++) {
            TeamStats row = sorted.get(i);
            result.add(new StandingRowDto(
                    i + 1,
                    new ClubListItemDto(row.club.getId(), row.club.getName(), row.club.getAbbr(), row.club.getCity(), row.club.getLogoUrl()),
                    row.played,
                    row.wins,
                    row.draws,
                    row.losses,
                    row.goalsFor,
                    row.goalsAgainst,
                    row.goalDifference(),
                    row.points
            ));
        }

        return result;
    }

    private static class TeamStats {
        private final Club club;
        private int played;
        private int wins;
        private int draws;
        private int losses;
        private int goalsFor;
        private int goalsAgainst;
        private int points;

        private TeamStats(Club club) {
            this.club = club;
        }

        static TeamStats of(Club club) {
            return new TeamStats(club);
        }

        int goalDifference() {
            return goalsFor - goalsAgainst;
        }

        int goalsFor() {
            return goalsFor;
        }

        int points() {
            return points;
        }
    }
}
