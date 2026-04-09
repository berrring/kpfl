package com.kurs.kpfl.repository.archive;

import com.kurs.kpfl.entity.archive.KpflLeagueRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface KpflLeagueRecordRepository extends JpaRepository<KpflLeagueRecord, Long> {
    List<KpflLeagueRecord> findAllByOrderByRecordKeyAsc();
}
