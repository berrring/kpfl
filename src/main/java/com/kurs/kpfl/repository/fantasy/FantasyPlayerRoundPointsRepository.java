package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyPlayerRoundPoints;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FantasyPlayerRoundPointsRepository extends JpaRepository<FantasyPlayerRoundPoints, Long> {
    List<FantasyPlayerRoundPoints> findByFantasyTeamIdAndSeasonIdAndRoundNumber(Long fantasyTeamId, Long seasonId, Integer roundNumber);
    void deleteBySeasonIdAndRoundNumber(Long seasonId, Integer roundNumber);
}
