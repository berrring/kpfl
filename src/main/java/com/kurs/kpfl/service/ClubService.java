package com.kurs.kpfl.service;

import com.kurs.kpfl.dto.ClubDetailDto;
import com.kurs.kpfl.dto.ClubListItemDto;
import com.kurs.kpfl.entity.Club;

import java.util.List;

public interface ClubService {
    List<ClubListItemDto> getAllClubs();
    ClubDetailDto getClubDetail(Long id);
    ClubListItemDto mapToListDto(Club club);
}