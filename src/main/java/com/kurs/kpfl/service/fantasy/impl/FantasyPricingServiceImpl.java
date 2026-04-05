package com.kurs.kpfl.service.fantasy.impl;

import com.kurs.kpfl.dto.fantasy.FantasyPriceDto;
import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.fantasy.FantasyPlayerPrice;
import com.kurs.kpfl.exception.NotFoundException;
import com.kurs.kpfl.model.FantasyPriceSource;
import com.kurs.kpfl.model.PlayerPosition;
import com.kurs.kpfl.repository.PlayerRepository;
import com.kurs.kpfl.repository.fantasy.FantasyPlayerPriceRepository;
import com.kurs.kpfl.service.fantasy.FantasyPricingService;
import com.kurs.kpfl.service.fantasy.FantasyRoundService;
import com.kurs.kpfl.service.fantasy.FantasyRules;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional
public class FantasyPricingServiceImpl implements FantasyPricingService {

    private static final BigDecimal MARKET_VALUE_DIVISOR = new BigDecimal("100000");
    private static final BigDecimal MAX_MARKET_UPLIFT = new BigDecimal("4.5");
    private static final BigDecimal MAX_PRICE = new BigDecimal("12.0");

    private final FantasyPlayerPriceRepository fantasyPlayerPriceRepository;
    private final PlayerRepository playerRepository;
    private final FantasyRoundService fantasyRoundService;

    @Override
    public FantasyPlayerPrice getOrCreatePrice(Player player, Season season) {
        return fantasyPlayerPriceRepository.findByPlayerIdAndSeasonId(player.getId(), season.getId())
                .orElseGet(() -> fantasyPlayerPriceRepository.save(buildPrice(player, season, null)));
    }

    @Override
    public Map<Long, FantasyPlayerPrice> getOrCreatePrices(Collection<Player> players, Season season) {
        Map<Long, FantasyPlayerPrice> byPlayerId = new HashMap<>();
        if (players.isEmpty()) {
            return byPlayerId;
        }

        List<Long> playerIds = players.stream().map(Player::getId).toList();
        fantasyPlayerPriceRepository.findByPlayerIdInAndSeasonId(playerIds, season.getId())
                .forEach(price -> byPlayerId.put(price.getPlayer().getId(), price));

        for (Player player : players) {
            byPlayerId.computeIfAbsent(player.getId(), ignored -> fantasyPlayerPriceRepository.save(buildPrice(player, season, null)));
        }
        return byPlayerId;
    }

    @Override
    public List<FantasyPriceDto> rebuildCurrentSeasonPrices() {
        Season season = fantasyRoundService.getCurrentSeason();
        List<Player> players = playerRepository.findAll();
        LocalDateTime now = LocalDateTime.now();

        List<FantasyPlayerPrice> prices = players.stream()
                .map(player -> fantasyPlayerPriceRepository.findByPlayerIdAndSeasonId(player.getId(), season.getId())
                        .map(existing -> buildPrice(player, season, existing))
                        .orElseGet(() -> buildPrice(player, season, null)))
                .map(price -> {
                    price.setLastUpdatedAt(now);
                    return fantasyPlayerPriceRepository.save(price);
                })
                .toList();

        return prices.stream()
                .map(this::toDto)
                .toList();
    }

    @Override
    public FantasyPriceDto rebuildCurrentSeasonPriceForPlayer(Long playerId) {
        Season season = fantasyRoundService.getCurrentSeason();
        Player player = playerRepository.findById(playerId)
                .orElseThrow(() -> new NotFoundException("Player not found with id " + playerId));

        FantasyPlayerPrice price = fantasyPlayerPriceRepository.findByPlayerIdAndSeasonId(playerId, season.getId())
                .map(existing -> buildPrice(player, season, existing))
                .orElseGet(() -> buildPrice(player, season, null));
        price.setLastUpdatedAt(LocalDateTime.now());
        return toDto(fantasyPlayerPriceRepository.save(price));
    }

    private FantasyPlayerPrice buildPrice(Player player, Season season, FantasyPlayerPrice existing) {
        PlayerPosition position = player.getPosition();
        if (position == null) {
            throw new IllegalArgumentException("Player " + player.getId() + " does not have a position.");
        }

        PriceComputation computation = computePrice(player);
        FantasyPlayerPrice price = existing == null ? new FantasyPlayerPrice() : existing;
        price.setPlayer(player);
        price.setSeason(season);
        price.setCurrentPrice(computation.price());
        price.setInitialPrice(computation.price());
        price.setPriceSource(computation.source());
        price.setLastUpdatedAt(LocalDateTime.now());
        return price;
    }

    private PriceComputation computePrice(Player player) {
        BigDecimal base = FantasyRules.DEFAULT_PRICES.get(player.getPosition());
        if (player.getMarketValueEur() == null) {
            return new PriceComputation(base.setScale(1, RoundingMode.HALF_UP), FantasyPriceSource.POSITION_DEFAULT);
        }

        BigDecimal uplift = BigDecimal.valueOf(player.getMarketValueEur())
                .divide(MARKET_VALUE_DIVISOR, 4, RoundingMode.HALF_UP)
                .min(MAX_MARKET_UPLIFT);
        BigDecimal price = base.add(uplift).min(MAX_PRICE).setScale(1, RoundingMode.HALF_UP);
        return new PriceComputation(price, FantasyPriceSource.MARKET_VALUE);
    }

    private FantasyPriceDto toDto(FantasyPlayerPrice price) {
        return new FantasyPriceDto(
                price.getPlayer().getId(),
                price.getPlayer().getFirstName() + " " + price.getPlayer().getLastName(),
                price.getSeason().getYear(),
                price.getCurrentPrice(),
                price.getInitialPrice(),
                price.getPriceSource().name(),
                price.getLastUpdatedAt()
        );
    }

    private record PriceComputation(BigDecimal price, FantasyPriceSource source) {
    }
}
