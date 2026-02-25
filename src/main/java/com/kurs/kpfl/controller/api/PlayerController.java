package com.kurs.kpfl.controller.api;

import com.kurs.kpfl.dto.PlayerDetailDto;
import com.kurs.kpfl.service.PlayerService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/players")
@RequiredArgsConstructor
public class PlayerController {
    private final PlayerService playerService;

    @GetMapping("/{id}")
    public PlayerDetailDto getPlayer(@PathVariable Long id) {
        return playerService.getPlayerDetail(id);
    }
}