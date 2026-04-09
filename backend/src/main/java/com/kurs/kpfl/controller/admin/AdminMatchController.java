package com.kurs.kpfl.controller.admin;

import com.kurs.kpfl.dto.MatchDetailDto;
import com.kurs.kpfl.dto.admin.AdminMatchResultRequest;
import com.kurs.kpfl.dto.admin.AdminMatchUpsertRequest;
import com.kurs.kpfl.service.admin.AdminMatchService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/matches")
@RequiredArgsConstructor
public class AdminMatchController {

    private final AdminMatchService adminMatchService;

    @PostMapping
    public MatchDetailDto create(@Valid @RequestBody AdminMatchUpsertRequest request) {
        return adminMatchService.create(request);
    }

    @PutMapping("/{id}")
    public MatchDetailDto update(@PathVariable Long id, @Valid @RequestBody AdminMatchUpsertRequest request) {
        return adminMatchService.update(id, request);
    }

    @PostMapping("/{id}/result")
    public MatchDetailDto setResult(@PathVariable Long id, @Valid @RequestBody AdminMatchResultRequest request) {
        return adminMatchService.setResult(id, request);
    }
}
