package com.kurs.kpfl.service.admin;

import com.kurs.kpfl.dto.NewsDetailDto;
import com.kurs.kpfl.dto.admin.AdminNewsUpsertRequest;
import com.kurs.kpfl.entity.Club;
import com.kurs.kpfl.entity.News;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.repository.ClubRepository;
import com.kurs.kpfl.repository.NewsRepository;
import com.kurs.kpfl.repository.PlayerRepository;
import com.kurs.kpfl.service.NewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminNewsService {

    private final NewsRepository newsRepository;
    private final ClubRepository clubRepository;
    private final PlayerRepository playerRepository;
    private final NewsService newsService;

    public NewsDetailDto create(AdminNewsUpsertRequest request) {
        News news = new News();
        map(request, news);
        news.setCreatedAt(LocalDateTime.now());
        News saved = newsRepository.save(news);
        return newsService.getNewsDetail(saved.getId());
    }

    public NewsDetailDto update(Long id, AdminNewsUpsertRequest request) {
        News news = newsRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("News not found with id " + id));
        map(request, news);
        newsRepository.save(news);
        return newsService.getNewsDetail(news.getId());
    }

    private void map(AdminNewsUpsertRequest request, News news) {
        Club club = request.getClubId() == null ? null : clubRepository.findById(request.getClubId())
                .orElseThrow(() -> new NotFoundException("Club not found with id " + request.getClubId()));
        Player player = request.getPlayerId() == null ? null : playerRepository.findById(request.getPlayerId())
                .orElseThrow(() -> new NotFoundException("Player not found with id " + request.getPlayerId()));

        news.setTitle(request.getTitle());
        news.setShortText(request.getShortText());
        news.setTag(request.getTag());
        news.setPublishedAt(request.getPublishedAt());
        news.setClub(club);
        news.setPlayer(player);
    }
}
