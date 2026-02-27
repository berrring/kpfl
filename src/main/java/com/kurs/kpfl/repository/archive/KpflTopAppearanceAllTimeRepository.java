package com.kurs.kpfl.repository.archive;

import com.kurs.kpfl.entity.archive.KpflTopAppearanceAllTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface KpflTopAppearanceAllTimeRepository extends JpaRepository<KpflTopAppearanceAllTime, Long> {
    List<KpflTopAppearanceAllTime> findAllByOrderByRankNoAsc();
}
