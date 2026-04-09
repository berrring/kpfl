package com.kurs.kpfl.controller.api;

import com.kurs.kpfl.dto.SeasonDto;
import com.kurs.kpfl.service.SeasonService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/seasons")
@RequiredArgsConstructor
public class SeasonController {

    private final SeasonService seasonService;

    @GetMapping
    public List<SeasonDto> getSeasons() {
        return seasonService.getSeasons();
    }
}
