package com.kurs.kpfl.service.impl;

import com.kurs.kpfl.dto.SeasonDto;
import com.kurs.kpfl.repository.SeasonRepository;
import com.kurs.kpfl.service.SeasonService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SeasonServiceImpl implements SeasonService {

    private final SeasonRepository seasonRepository;

    @Override
    public List<SeasonDto> getSeasons() {
        return seasonRepository.findAll(Sort.by(Sort.Direction.DESC, "year")).stream()
                .map(season -> new SeasonDto(
                        season.getId(),
                        season.getYear(),
                        season.getName(),
                        season.getStartDate(),
                        season.getEndDate()
                ))
                .toList();
    }
}
