package com.kurs.kpfl.entity;

import com.kurs.kpfl.model.PlayerPosition;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "players",
        uniqueConstraints = @UniqueConstraint(name = "uk_players_club_number", columnNames = {"club_id", "jersey_number"})
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Player {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "first_name", nullable = false, length = 50)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 50)
    private String lastName;

    @Column(name = "jersey_number")
    private Integer jerseyNumber;

    @Enumerated(EnumType.STRING)
    @Column(length = 10, nullable = false)
    private PlayerPosition position;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(length = 50)
    private String nationality;

    @Column(name = "height_cm")
    private Integer heightCm;

    @Column(name = "weight_kg")
    private Integer weightKg;

    @Column(name = "age_years")
    private Integer ageYears;

    @Column(name = "market_value_eur")
    private Long marketValueEur;

    @Column(name = "photo_url")
    private String photoUrl;

    @Column(name = "source_url")
    private String sourceUrl;

    @Column(name = "source_note", length = 500)
    private String sourceNote;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "club_id", nullable = false)
    private Club club;
}
