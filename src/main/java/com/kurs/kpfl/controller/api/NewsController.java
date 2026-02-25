package com.kurs.kpfl.controller.api;

import com.kurs.kpfl.dto.NewsDetailDto;
import com.kurs.kpfl.dto.NewsListItemDto;
import com.kurs.kpfl.service.NewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/news")
@RequiredArgsConstructor
public class NewsController {
    private final NewsService newsService;

    @GetMapping
    public List<NewsListItemDto> getNews(@RequestParam(defaultValue = "20") int limit) {
        return newsService.getNewsList(limit);
    }

    @GetMapping("/{id}")
    public NewsDetailDto getNewsDetail(@PathVariable Long id) {
        return newsService.getNewsDetail(id);
    }
}