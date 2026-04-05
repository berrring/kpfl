package com.kurs.kpfl.entity.fantasy;

import com.kurs.kpfl.entity.Season;
import com.kurs.kpfl.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "fantasy_leagues",
        uniqueConstraints = @UniqueConstraint(name = "uk_fantasy_leagues_code", columnNames = "code")
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FantasyLeague {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "season_id", nullable = false)
    private Season season;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_user_id", nullable = false)
    private User owner;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 20)
    private String code;

    @Column(name = "is_private", nullable = false)
    private Boolean isPrivate;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
