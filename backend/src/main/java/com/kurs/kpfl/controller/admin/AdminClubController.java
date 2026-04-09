package com.kurs.kpfl.controller.admin;

import com.kurs.kpfl.dto.ClubDetailDto;
import com.kurs.kpfl.dto.admin.AdminClubUpsertRequest;
import com.kurs.kpfl.service.admin.AdminClubService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/clubs")
@RequiredArgsConstructor
public class AdminClubController {

    private final AdminClubService adminClubService;

    @PostMapping
    public ClubDetailDto create(@Valid @RequestBody AdminClubUpsertRequest request) {
        return adminClubService.create(request);
    }

    @PutMapping("/{id}")
    public ClubDetailDto update(@PathVariable Long id, @Valid @RequestBody AdminClubUpsertRequest request) {
        return adminClubService.update(id, request);
    }
}
