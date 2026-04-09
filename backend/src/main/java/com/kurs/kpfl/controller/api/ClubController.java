package com.kurs.kpfl.controller.api;

import com.kurs.kpfl.dto.ClubDetailDto;
import com.kurs.kpfl.dto.ClubListItemDto;
import com.kurs.kpfl.service.ClubService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clubs")
@RequiredArgsConstructor
public class ClubController {
    private final ClubService clubService;

    @GetMapping
    public List<ClubListItemDto> getAllClubs() {
        return clubService.getAllClubs();
    }

    @GetMapping("/{id}")
    public ClubDetailDto getClub(@PathVariable Long id) {
        return clubService.getClubDetail(id);
    }
}