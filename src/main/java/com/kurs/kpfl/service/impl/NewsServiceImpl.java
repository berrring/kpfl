package com.kurs.kpfl.service.impl;

import com.kurs.kpfl.dto.NewsDetailDto;
import com.kurs.kpfl.dto.NewsListItemDto;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.entity.News;
import com.kurs.kpfl.repository.NewsRepository;
import com.kurs.kpfl.service.ClubService;
import com.kurs.kpfl.service.NewsService;
import com.kurs.kpfl.service.PlayerService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NewsServiceImpl implements NewsService {
    private final NewsRepository newsRepository;
    private final ClubService clubService;
    private final PlayerService playerService;

    @Override
    public List<NewsListItemDto> getNewsList(int limit) {
        if (limit < 1 || limit > 50) throw new IllegalArgumentException("Limit must be between 1 and 50");
        return newsRepository.findAllByOrderByPublishedAtDesc(PageRequest.of(0, limit))
                .stream()
                .map(n -> new NewsListItemDto(n.getId(), n.getTitle(), n.getTag(), n.getPublishedAt()))
                .toList();
    }

    @Override
    public NewsDetailDto getNewsDetail(Long id) {
        News news = newsRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("News not found with id " + id));

        return new NewsDetailDto(
                news.getId(), news.getTitle(), news.getTag(), news.getPublishedAt(), news.getShortText(),
                clubService.mapToListDto(news.getRelatedClub()),
                playerService.mapToListDto(news.getRelatedPlayer())
        );
    }
}