package com.kurs.kpfl.repository.archive;

import com.kurs.kpfl.entity.archive.KpflSeasonStandingsArchive;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface KpflSeasonStandingsArchiveRepository extends JpaRepository<KpflSeasonStandingsArchive, Long> {
    List<KpflSeasonStandingsArchive> findBySeasonYearOrderByPlaceNoAsc(Integer seasonYear);
    List<KpflSeasonStandingsArchive> findAllByOrderBySeasonYearDescPlaceNoAsc();

    @Query("select distinct s.seasonYear from KpflSeasonStandingsArchive s order by s.seasonYear desc")
    List<Integer> findDistinctSeasonYearsDesc();
}
