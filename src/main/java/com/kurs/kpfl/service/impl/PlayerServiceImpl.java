package com.kurs.kpfl.service.impl;

import com.kurs.kpfl.dto.PlayerDetailDto;
import com.kurs.kpfl.dto.PlayerListItemDto;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.repository.PlayerRepository;
import com.kurs.kpfl.service.ClubService;
import com.kurs.kpfl.service.PlayerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PlayerServiceImpl implements PlayerService {
    private final PlayerRepository playerRepository;
    private final ClubService clubService;

    @Override
    public List<PlayerListItemDto> getPlayers(Long clubId) {
        List<Player> players = clubId == null
                ? playerRepository.findAllByOrderByLastNameAscFirstNameAsc()
                : playerRepository.findByClubIdOrderByLastNameAscFirstNameAsc(clubId);

        return players.stream()
                .map(this::mapToListDto)
                .toList();
    }

    @Override
    public PlayerDetailDto getPlayerDetail(Long id) {
        Player player = playerRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Player not found with id " + id));

        return new PlayerDetailDto(
                player.getId(), player.getFirstName(), player.getLastName(),
                player.getJerseyNumber(), player.getPosition() == null ? null : player.getPosition().name(), player.getBirthDate(),
                player.getNationality(), player.getHeightCm(), player.getWeightKg(),
                player.getAgeYears(), player.getMarketValueEur(), player.getPhotoUrl(), player.getSourceUrl(), player.getSourceNote(),
                clubService.mapToListDto(player.getClub())
        );
    }

    @Override
    public PlayerListItemDto mapToListDto(Player player) {
        if (player == null) return null;
        return new PlayerListItemDto(
                player.getId(),
                player.getFirstName(),
                player.getLastName(),
                player.getJerseyNumber(),
                player.getPosition() == null ? null : player.getPosition().name()
        );
    }
}
