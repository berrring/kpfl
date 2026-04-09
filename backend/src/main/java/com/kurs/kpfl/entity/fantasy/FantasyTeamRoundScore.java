package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Season;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "fantasy_team_round_scores",
        uniqueConstraints = @UniqueConstraint(name = "uk_fantasy_round_scores_team_round", columnNames = {"fantasy_team_id", "season_id", "round_number"})
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyTeamRoundScore {

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

    @Column(nullable = false)
    private Integer points;

    @Column(name = "transfer_penalty", nullable = false)
    private Integer transferPenalty;

    @Column(name = "final_points", nullable = false)
    private Integer finalPoints;

    @Column(name = "rank_snapshot")
    private Integer rankSnapshot;

    @Column(name = "calculated_at", nullable = false)
    private LocalDateTime calculatedAt;
}
