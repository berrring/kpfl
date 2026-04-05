package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "fantasy_transfers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyTransfer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fantasy_team_id", nullable = false)
    private FantasyTeam fantasyTeam;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "season_id", nullable = false)
    private Season season;

    @Column(name = "round_number", nullable = false)
    private Integer roundNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_out_id", nullable = false)
    private Player playerOut;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_in_id", nullable = false)
    private Player playerIn;

    @Column(name = "cost_points", nullable = false)
    private Integer costPoints;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
