package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyLeague;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FantasyLeagueRepository extends JpaRepository<FantasyLeague, Long> {
    Optional<FantasyLeague> findByCodeIgnoreCase(String code);
    List<FantasyLeague> findBySeasonIdOrderByCreatedAtDesc(Long seasonId);
}
