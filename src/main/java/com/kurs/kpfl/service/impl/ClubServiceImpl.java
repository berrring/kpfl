package com.kurs.kpfl.service.impl;

import com.kurs.kpfl.dto.ClubDetailDto;
import com.kurs.kpfl.dto.ClubListItemDto;
import com.kurs.kpfl.dto.PlayerListItemDto;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.model.entity.Club;
import com.kurs.kpfl.repository.ClubRepository;
import com.kurs.kpfl.service.ClubService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClubServiceImpl implements ClubService {
    private final ClubRepository clubRepository;

    @Override
    public List<ClubListItemDto> getAllClubs() {
        return clubRepository.findAll().stream()
                .map(this::mapToListDto)
                .toList();
    }

    @Override
    public ClubDetailDto getClubDetail(Long id) {
        Club club = clubRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Club not found with id " + id));

        List<PlayerListItemDto> players = club.getPlayers().stream()
                .map(p -> new PlayerListItemDto(p.getId(), p.getFirstName(), p.getLastName(), p.getJerseyNumber(), p.getPosition()))
                .toList();

        return new ClubDetailDto(
                club.getId(), club.getName(), club.getAbbr(), club.getCity(),
                club.getLogoUrl(), club.getStadium(), club.getFoundedYear(), players
        );
    }

    @Override
    public ClubListItemDto mapToListDto(Club club) {
        if (club == null) return null;
        return new ClubListItemDto(club.getId(), club.getName(), club.getAbbr(), club.getCity(), club.getLogoUrl());
    }
}