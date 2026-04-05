package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyPlayerMatchStat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FantasyPlayerMatchStatRepository extends JpaRepository<FantasyPlayerMatchStat, Long> {
    Optional<FantasyPlayerMatchStat> findByPlayerIdAndMatchId(Long playerId, Long matchId);
    List<FantasyPlayerMatchStat> findByMatchId(Long matchId);

    @Query("""
            select stat
            from FantasyPlayerMatchStat stat
            join stat.match match
            where match.season.id = :seasonId and match.round = :roundNumber
            """)
    List<FantasyPlayerMatchStat> findBySeasonAndRound(@Param("seasonId") Long seasonId, @Param("roundNumber") Integer roundNumber);
}
