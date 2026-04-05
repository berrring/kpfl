package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Player;
import com.kurs.kpfl.entity.Season;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
        name = "fantasy_team_round_selections",
        uniqueConstraints = @UniqueConstraint(name = "uk_fantasy_selections_team_round", columnNames = {"fantasy_team_id", "season_id", "round_number"})
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyTeamRoundSelection {

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

    @Column(name = "locked_at", nullable = false)
    private LocalDateTime lockedAt;

    @Column(nullable = false)
    private Boolean finalized;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "captain_player_id", nullable = false)
    private Player captainPlayer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vice_captain_player_id", nullable = false)
    private Player viceCaptainPlayer;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "roundSelection", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<FantasyLineupEntry> lineupEntries = new ArrayList<>();
}
