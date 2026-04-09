package com.kurs.kpfl.service.admin;

import com.kurs.kpfl.dto.ClubDetailDto;
import com.kurs.kpfl.dto.admin.AdminClubUpsertRequest;
import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.repository.ClubRepository;
import com.kurs.kpfl.service.ClubService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminClubService {

    private final ClubRepository clubRepository;
    private final ClubService clubService;

    public ClubDetailDto create(AdminClubUpsertRequest request) {
        Club club = new Club();
        map(request, club);
        club.setCreatedAt(LocalDateTime.now());
        Club saved = clubRepository.save(club);
        return clubService.getClubDetail(saved.getId());
    }

    public ClubDetailDto update(Long id, AdminClubUpsertRequest request) {
        Club club = clubRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Club not found with id " + id));
        map(request, club);
        clubRepository.save(club);
        return clubService.getClubDetail(club.getId());
    }

    private void map(AdminClubUpsertRequest request, Club club) {
        club.setName(request.getName());
        club.setAbbr(request.getAbbr());
        club.setCity(request.getCity());
        club.setStadium(request.getStadium());
        club.setFoundedYear(request.getFoundedYear());
        club.setPrimaryColor(request.getPrimaryColor());
        club.setLogoUrl(request.getLogoUrl());
        club.setCoachName(request.getCoachName());
        club.setCoachInfo(request.getCoachInfo());
    }
}
