package com.kurs.kpfl.controller.api;

import com.kurs.kpfl.dto.MatchDetailDto;
import com.kurs.kpfl.dto.MatchListItemDto;
import com.kurs.kpfl.model.MatchStatus;
import com.kurs.kpfl.service.MatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/matches")
@RequiredArgsConstructor
public class MatchController {
    private final MatchService matchService;

    @GetMapping
    public List<MatchListItemDto> getMatches(
            @RequestParam(required = false) Integer seasonYear,
            @RequestParam(required = false) Integer round,
            @RequestParam(required = false) Long clubId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateTo,
            @RequestParam(required = false) MatchStatus status
    ) {
        return matchService.getMatches(seasonYear, round, clubId, dateFrom, dateTo, status);
    }

    @GetMapping("/{id}")
    public MatchDetailDto getMatch(@PathVariable Long id) {
        return matchService.getMatchDetail(id);
    }
}
