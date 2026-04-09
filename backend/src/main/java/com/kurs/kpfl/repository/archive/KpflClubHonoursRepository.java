package com.kurs.kpfl.repository.archive;

import com.kurs.kpfl.entity.archive.KpflClubHonours;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface KpflClubHonoursRepository extends JpaRepository<KpflClubHonours, Long> {
    List<KpflClubHonours> findAllByOrderByTitlesDescRunnerUpCountDescThirdPlaceCountDescClubNameAsc();
}
