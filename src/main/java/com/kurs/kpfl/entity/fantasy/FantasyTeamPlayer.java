package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Player;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "fantasy_team_players")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyTeamPlayer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fantasy_team_id", nullable = false)
    private FantasyTeam fantasyTeam;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_id", nullable = false)
    private Player player;

    @Column(name = "acquired_price", nullable = false, precision = 5, scale = 1)
    private BigDecimal acquiredPrice;

    @Column(name = "acquired_round", nullable = false)
    private Integer acquiredRound;

    @Column(name = "sold_round")
    private Integer soldRound;

    @Column(nullable = false)
    private Boolean active;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
