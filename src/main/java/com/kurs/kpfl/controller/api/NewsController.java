package com.kurs.kpfl.controller.api;

import com.kurs.kpfl.dto.NewsDetailDto;
import com.kurs.kpfl.dto.NewsListItemDto;
import com.kurs.kpfl.service.NewsService;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/news")
@RequiredArgsConstructor
@Validated
public class NewsController {
    private final NewsService newsService;

    @GetMapping
    public List<NewsListItemDto> getNews(@RequestParam(defaultValue = "20") @Min(1) @Max(50) int limit) {
        return newsService.getNewsList(limit);
    }

    @GetMapping("/{id}")
    public NewsDetailDto getNewsDetail(@PathVariable Long id) {
        return newsService.getNewsDetail(id);
    }
}
