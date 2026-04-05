package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyTransfer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FantasyTransferRepository extends JpaRepository<FantasyTransfer, Long> {
    long countByFantasyTeamIdAndSeasonIdAndRoundNumber(Long fantasyTeamId, Long seasonId, Integer roundNumber);
    List<FantasyTransfer> findByFantasyTeamIdAndSeasonIdOrderByRoundNumberAscCreatedAtAsc(Long fantasyTeamId, Long seasonId);
    List<FantasyTransfer> findByFantasyTeamIdAndSeasonIdAndRoundNumberOrderByCreatedAtAsc(Long fantasyTeamId, Long seasonId, Integer roundNumber);
    void deleteByFantasyTeamIdAndSeasonId(Long fantasyTeamId, Long seasonId);
}
