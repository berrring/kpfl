package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Player;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "fantasy_lineup_entries")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyLineupEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "round_selection_id", nullable = false)
    private FantasyTeamRoundSelection roundSelection;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_id", nullable = false)
    private Player player;

    @Column(nullable = false)
    private Boolean starter;

    @Column(name = "starter_order")
    private Integer starterOrder;

    @Column(name = "bench_order")
    private Integer benchOrder;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
