package com.kurs.kpfl.controller.admin;

import com.kurs.kpfl.dto.NewsDetailDto;
import com.kurs.kpfl.dto.admin.AdminNewsUpsertRequest;
import com.kurs.kpfl.service.admin.AdminNewsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/news")
@RequiredArgsConstructor
public class AdminNewsController {

    private final AdminNewsService adminNewsService;

    @PostMapping
    public NewsDetailDto create(@Valid @RequestBody AdminNewsUpsertRequest request) {
        return adminNewsService.create(request);
    }

    @PutMapping("/{id}")
    public NewsDetailDto update(@PathVariable Long id, @Valid @RequestBody AdminNewsUpsertRequest request) {
        return adminNewsService.update(id, request);
    }
}
