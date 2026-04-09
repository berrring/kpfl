package com.kurs.kpfl.repository.fantasy;

import com.kurs.kpfl.entity.fantasy.FantasyLineupEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FantasyLineupEntryRepository extends JpaRepository<FantasyLineupEntry, Long> {
    List<FantasyLineupEntry> findByRoundSelectionId(Long roundSelectionId);
}
