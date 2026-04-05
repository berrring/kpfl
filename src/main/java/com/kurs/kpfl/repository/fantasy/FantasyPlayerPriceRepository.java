package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyPlayerPrice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface FantasyPlayerPriceRepository extends JpaRepository<FantasyPlayerPrice, Long> {
    Optional<FantasyPlayerPrice> findByPlayerIdAndSeasonId(Long playerId, Long seasonId);
    List<FantasyPlayerPrice> findBySeasonId(Long seasonId);
    List<FantasyPlayerPrice> findByPlayerIdInAndSeasonId(Collection<Long> playerIds, Long seasonId);
}
