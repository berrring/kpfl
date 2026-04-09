package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyTeamRoundSelection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FantasyTeamRoundSelectionRepository extends JpaRepository<FantasyTeamRoundSelection, Long> {
    Optional<FantasyTeamRoundSelection> findByFantasyTeamIdAndSeasonIdAndRoundNumber(Long fantasyTeamId, Long seasonId, Integer roundNumber);
    List<FantasyTeamRoundSelection> findBySeasonIdAndRoundNumber(Long seasonId, Integer roundNumber);
    void deleteByFantasyTeamIdAndSeasonId(Long fantasyTeamId, Long seasonId);
}
