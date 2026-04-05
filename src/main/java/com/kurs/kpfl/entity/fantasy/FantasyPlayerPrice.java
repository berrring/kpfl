package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.model.FantasyPriceSource;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "fantasy_player_prices",
        uniqueConstraints = @UniqueConstraint(name = "uk_fantasy_prices_player_season", columnNames = {"player_id", "season_id"})
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyPlayerPrice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_id", nullable = false)
    private Player player;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "season_id", nullable = false)
    private Season season;

    @Column(name = "current_price", nullable = false, precision = 5, scale = 1)
    private BigDecimal currentPrice;

    @Column(name = "initial_price", nullable = false, precision = 5, scale = 1)
    private BigDecimal initialPrice;

    @Enumerated(EnumType.STRING)
    @Column(name = "price_source", nullable = false, length = 30)
    private FantasyPriceSource priceSource;

    @Column(name = "last_updated_at", nullable = false)
    private LocalDateTime lastUpdatedAt;
}
