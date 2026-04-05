package com.kurs.kpfl.entity.fantasy;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "fantasy_league_members",
        uniqueConstraints = @UniqueConstraint(name = "uk_fantasy_league_members", columnNames = {"fantasy_league_id", "fantasy_team_id"})
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyLeagueMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fantasy_league_id", nullable = false)
    private FantasyLeague fantasyLeague;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fantasy_team_id", nullable = false)
    private FantasyTeam fantasyTeam;

    @Column(name = "joined_at", nullable = false)
    private LocalDateTime joinedAt;
}
