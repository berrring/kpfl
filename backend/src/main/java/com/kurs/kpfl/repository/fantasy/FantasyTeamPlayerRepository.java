package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyTeamPlayer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FantasyTeamPlayerRepository extends JpaRepository<FantasyTeamPlayer, Long> {
    List<FantasyTeamPlayer> findByFantasyTeamIdAndActiveTrue(Long fantasyTeamId);
    Optional<FantasyTeamPlayer> findByFantasyTeamIdAndPlayerIdAndActiveTrue(Long fantasyTeamId, Long playerId);
    long countByFantasyTeamIdAndActiveTrue(Long fantasyTeamId);
    void deleteByFantasyTeamId(Long fantasyTeamId);
}
