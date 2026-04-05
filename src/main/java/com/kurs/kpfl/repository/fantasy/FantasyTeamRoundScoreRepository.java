package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyTeamRoundScore;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FantasyTeamRoundScoreRepository extends JpaRepository<FantasyTeamRoundScore, Long> {
    Optional<FantasyTeamRoundScore> findByFantasyTeamIdAndSeasonIdAndRoundNumber(Long fantasyTeamId, Long seasonId, Integer roundNumber);
    List<FantasyTeamRoundScore> findByFantasyTeamIdAndSeasonIdOrderByRoundNumberAsc(Long fantasyTeamId, Long seasonId);
    List<FantasyTeamRoundScore> findBySeasonIdAndRoundNumber(Long seasonId, Integer roundNumber);
    void deleteBySeasonIdAndRoundNumber(Long seasonId, Integer roundNumber);
}
