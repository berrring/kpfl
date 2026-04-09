package com.kurs.kpfl.service;

import com.kurs.kpfl.dto.PlayerDetailDto;
import com.kurs.kpfl.dto.PlayerListItemDto;
import com.kurs.kpfl.entity.Player;

import java.util.List;

public interface PlayerService {
    List<PlayerListItemDto> getPlayers(Long clubId);
    PlayerDetailDto getPlayerDetail(Long id);
    PlayerListItemDto mapToListDto(Player player);
}
