package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "fantasy_teams",
        uniqueConstraints = @UniqueConstraint(name = "uk_fantasy_teams_user_season", columnNames = {"user_id", "season_id"})
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyTeam {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "season_id", nullable = false)
    private Season season;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(name = "total_points", nullable = false)
    private Integer totalPoints;

    @Column(name = "current_budget", nullable = false, precision = 5, scale = 1)
    private BigDecimal currentBudget;

    @Column(nullable = false)
    private Boolean active;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
