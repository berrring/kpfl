package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyLeagueMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FantasyLeagueMemberRepository extends JpaRepository<FantasyLeagueMember, Long> {
    boolean existsByFantasyLeagueIdAndFantasyTeamId(Long fantasyLeagueId, Long fantasyTeamId);
    List<FantasyLeagueMember> findByFantasyTeamId(Long fantasyTeamId);
    List<FantasyLeagueMember> findByFantasyLeagueId(Long fantasyLeagueId);
    long countByFantasyLeagueId(Long fantasyLeagueId);
}
