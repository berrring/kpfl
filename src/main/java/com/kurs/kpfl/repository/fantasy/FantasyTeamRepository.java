package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyTeam;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FantasyTeamRepository extends JpaRepository<FantasyTeam, Long> {
    Optional<FantasyTeam> findByUserIdAndSeasonId(Long userId, Long seasonId);
    Optional<FantasyTeam> findByIdAndUserId(Long id, Long userId);
    List<FantasyTeam> findBySeasonIdAndActiveTrue(Long seasonId);
}
