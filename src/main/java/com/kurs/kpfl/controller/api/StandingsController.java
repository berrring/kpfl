package com.kurs.kpfl.controller.api;

import com.kurs.kpfl.dto.StandingRowDto;
import com.kurs.kpfl.service.StandingsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/standings")
@RequiredArgsConstructor
public class StandingsController {

    private final StandingsService standingsService;

    @GetMapping
    public List<StandingRowDto> getStandings(@RequestParam(required = false) Integer seasonYear) {
        return standingsService.getStandings(seasonYear);
    }
}
