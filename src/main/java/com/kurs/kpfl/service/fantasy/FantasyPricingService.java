package com.kurs.kpfl.service.fantasy;

import com.kurs.kpfl.dto.fantasy.FantasyPriceDto;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.fantasy.FantasyPlayerPrice;

import java.util.Collection;
import java.util.List;
import java.util.Map;

public interface FantasyPricingService {
    FantasyPlayerPrice getOrCreatePrice(Player player, Season season);
    Map<Long, FantasyPlayerPrice> getOrCreatePrices(Collection<Player> players, Season season);
    List<FantasyPriceDto> rebuildCurrentSeasonPrices();
    FantasyPriceDto rebuildCurrentSeasonPriceForPlayer(Long playerId);
}
