package com.kurs.kpfl.service.admin;

import com.kurs.kpfl.dto.PlayerDetailDto;
import com.kurs.kpfl.dto.admin.AdminPlayerUpsertRequest;
import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.repository.ClubRepository;
import com.kurs.kpfl.repository.PlayerRepository;
import com.kurs.kpfl.service.PlayerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminPlayerService {

    private final PlayerRepository playerRepository;
    private final ClubRepository clubRepository;
    private final PlayerService playerService;

    public PlayerDetailDto create(AdminPlayerUpsertRequest request) {
        Club club = clubRepository.findById(request.getClubId())
                .orElseThrow(() -> new NotFoundException("Club not found with id " + request.getClubId()));

        Player player = new Player();
        map(request, player, club);
        player.setCreatedAt(LocalDateTime.now());
        Player saved = playerRepository.save(player);
        return playerService.getPlayerDetail(saved.getId());
    }

    public PlayerDetailDto update(Long id, AdminPlayerUpsertRequest request) {
        Player player = playerRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Player not found with id " + id));
        Club club = clubRepository.findById(request.getClubId())
                .orElseThrow(() -> new NotFoundException("Club not found with id " + request.getClubId()));

        map(request, player, club);
        playerRepository.save(player);
        return playerService.getPlayerDetail(player.getId());
    }

    private void map(AdminPlayerUpsertRequest request, Player player, Club club) {
        player.setClub(club);
        player.setFirstName(request.getFirstName());
        player.setLastName(request.getLastName());
        player.setJerseyNumber(request.getNumber());
        player.setPosition(request.getPosition());
        player.setBirthDate(request.getBirthDate());
        player.setNationality(request.getNationality());
        player.setHeightCm(request.getHeightCm());
        player.setWeightKg(request.getWeightKg());
        player.setAgeYears(request.getAgeYears());
        player.setMarketValueEur(request.getMarketValueEur());
        player.setPhotoUrl(request.getPhotoUrl());
        player.setSourceUrl(request.getSourceUrl());
        player.setSourceNote(request.getSourceNote());
    }
}
