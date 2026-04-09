package com.kurs.kpfl.service;

import com.kurs.kpfl.dto.NewsDetailDto;
import com.kurs.kpfl.dto.NewsListItemDto;

import java.util.List;

public interface NewsService {
    List<NewsListItemDto> getNewsList(int limit);
    NewsDetailDto getNewsDetail(Long id);
}