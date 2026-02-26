package com.kurs.kpfl.service.impl;

import com.kurs.kpfl.dto.MatchDetailDto;
import com.kurs.kpfl.dto.MatchListItemDto;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.model.MatchStatus;
import com.kurs.kpfl.repository.MatchRepository;
import com.kurs.kpfl.service.ClubService;
import com.kurs.kpfl.service.MatchService;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MatchServiceImpl implements MatchService {
    private final MatchRepository matchRepository;
    private final ClubService clubService;

    @Override
    public List<MatchListItemDto> getMatches(
            Integer seasonYear,
            Integer round,
            Long clubId,
            LocalDate dateFrom,
            LocalDate dateTo,
            MatchStatus status
    ) {
        Specification<Match> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (seasonYear != null) predicates.add(cb.equal(root.get("season").get("year"), seasonYear));
            if (round != null) predicates.add(cb.equal(root.get("round"), round));
            if (status != null) predicates.add(cb.equal(root.get("status"), status));
            if (clubId != null) {
                predicates.add(cb.or(
                        cb.equal(root.get("homeClub").get("id"), clubId),
                        cb.equal(root.get("awayClub").get("id"), clubId)
                ));
            }
            if (dateFrom != null) predicates.add(cb.greaterThanOrEqualTo(root.get("dateTime"), dateFrom.atStartOfDay()));
            if (dateTo != null) predicates.add(cb.lessThanOrEqualTo(root.get("dateTime"), dateTo.atTime(23, 59, 59)));
            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return matchRepository.findAll(spec).stream()
                .map(this::mapToListDto)
                .toList();
    }

    @Override
    public MatchDetailDto getMatchDetail(Long id) {
        Match match = matchRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Match not found with id " + id));

        return new MatchDetailDto(
                match.getId(),
                match.getDateTime(),
                match.getStatus() == null ? null : match.getStatus().name(),
                clubService.mapToListDto(match.getHomeClub()),
                clubService.mapToListDto(match.getAwayClub()),
                formatScore(match), match.getStadium(), match.getRound(),
                match.getSeason() == null ? null : match.getSeason().getYear(),
                Collections.emptyList()
        );
    }

    private MatchListItemDto mapToListDto(Match match) {
        return new MatchListItemDto(
                match.getId(), match.getDateTime(), match.getStatus() == null ? null : match.getStatus().name(),
                clubService.mapToListDto(match.getHomeClub()),
                clubService.mapToListDto(match.getAwayClub()),
                formatScore(match)
        );
    }

    private String formatScore(Match match) {
        if (match.getHomeScore() == null || match.getAwayScore() == null) return null;
        return match.getHomeScore() + " - " + match.getAwayScore();
    }
}
