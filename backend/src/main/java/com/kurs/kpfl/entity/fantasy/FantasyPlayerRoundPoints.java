package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "fantasy_player_round_points",
        uniqueConstraints = @UniqueConstraint(name = "uk_fantasy_round_points_team_round_player", columnNames = {"fantasy_team_id", "season_id", "round_number", "player_id"})
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyPlayerRoundPoints {

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
    @JoinColumn(name = "player_id", nullable = false)
    private Player player;

    @Column(name = "raw_points", nullable = false)
    private Integer rawPoints;

    @Column(name = "applied_points", nullable = false)
    private Integer appliedPoints;

    @Column(nullable = false)
    private Boolean starter;

    @Column(name = "captain_applied", nullable = false)
    private Boolean captainApplied;

    @Column(name = "vice_captain_applied", nullable = false)
    private Boolean viceCaptainApplied;

    @Column(name = "auto_sub_applied", nullable = false)
    private Boolean autoSubApplied;

    @Column(length = 500)
    private String explanation;
}
