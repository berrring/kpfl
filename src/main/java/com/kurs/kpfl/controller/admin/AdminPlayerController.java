package com.kurs.kpfl.controller.admin;

import com.kurs.kpfl.dto.PlayerDetailDto;
import com.kurs.kpfl.dto.admin.AdminPlayerUpsertRequest;
import com.kurs.kpfl.service.admin.AdminPlayerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/players")
@RequiredArgsConstructor
public class AdminPlayerController {

    private final AdminPlayerService adminPlayerService;

    @PostMapping
    public PlayerDetailDto create(@Valid @RequestBody AdminPlayerUpsertRequest request) {
        return adminPlayerService.create(request);
    }

    @PutMapping("/{id}")
    public PlayerDetailDto update(@PathVariable Long id, @Valid @RequestBody AdminPlayerUpsertRequest request) {
        return adminPlayerService.update(id, request);
    }
}
