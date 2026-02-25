package com.kurs.kpfl.service;

import com.kurs.kpfl.dto.PlayerDetailDto;
import com.kurs.kpfl.dto.PlayerListItemDto;
import com.kurs.kpfl.entity.Player;

public interface PlayerService {
    PlayerDetailDto getPlayerDetail(Long id);
    PlayerListItemDto mapToListDto(Player player);
}