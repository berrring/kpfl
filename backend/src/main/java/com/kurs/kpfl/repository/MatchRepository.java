package com.kurs.kpfl.repository;

import com.kurs.kpfl.entity.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface MatchRepository extends JpaRepository<Match, Long>, JpaSpecificationExecutor<Match> {
    Optional<Match> findByExternalSourceAndExternalId(String externalSource, String externalId);
    List<Match> findBySeasonIdAndRoundOrderByDateTimeAsc(Long seasonId, Integer round);

    @Query("select min(m.dateTime) from Match m where m.season.id = :seasonId and m.round = :roundNumber")
    Optional<LocalDateTime> findRoundLockTime(@Param("seasonId") Long seasonId, @Param("roundNumber") Integer roundNumber);

    @Query("select min(m.round) from Match m where m.season.id = :seasonId")
    Optional<Integer> findFirstRoundNumber(@Param("seasonId") Long seasonId);

    @Query("select max(m.round) from Match m where m.season.id = :seasonId")
    Optional<Integer> findLastRoundNumber(@Param("seasonId") Long seasonId);

    @Query("select min(m.round) from Match m where m.season.id = :seasonId and m.dateTime >= :timestamp")
    Optional<Integer> findUpcomingRoundNumber(@Param("seasonId") Long seasonId, @Param("timestamp") LocalDateTime timestamp);
}
