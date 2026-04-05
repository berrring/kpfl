package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Match;
import com.kurs.kpfl.entity.Player;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "fantasy_player_match_stats",
        uniqueConstraints = @UniqueConstraint(name = "uk_fantasy_match_stats_player_match", columnNames = {"player_id", "match_id"})
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyPlayerMatchStat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_id", nullable = false)
    private Player player;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "match_id", nullable = false)
    private Match match;

    @Column(name = "minutes_played", nullable = false)
    private Integer minutesPlayed;

    @Column(nullable = false)
    private Integer goals;

    @Column(nullable = false)
    private Integer assists;

    @Column(name = "clean_sheet", nullable = false)
    private Boolean cleanSheet;

    @Column(name = "goals_conceded", nullable = false)
    private Integer goalsConceded;

    @Column(name = "yellow_cards", nullable = false)
    private Integer yellowCards;

    @Column(name = "red_cards", nullable = false)
    private Integer redCards;

    @Column(name = "own_goals", nullable = false)
    private Integer ownGoals;

    @Column(name = "penalties_saved", nullable = false)
    private Integer penaltiesSaved;

    @Column(name = "penalties_missed", nullable = false)
    private Integer penaltiesMissed;

    @Column(nullable = false)
    private Integer saves;

    @Column(nullable = false)
    private Boolean started;

    @Column(name = "substituted_in", nullable = false)
    private Boolean substitutedIn;

    @Column(name = "substituted_out", nullable = false)
    private Boolean substitutedOut;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
