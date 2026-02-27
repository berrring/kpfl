package com.kurs.kpfl.repository;

import com.kurs.kpfl.entity.Player;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlayerRepository extends JpaRepository<Player, Long> {
    List<Player> findAllByOrderByLastNameAscFirstNameAsc();
    List<Player> findByClubIdOrderByLastNameAscFirstNameAsc(Long clubId);
}
