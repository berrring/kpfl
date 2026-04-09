package com.kurs.kpfl.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
        name = "clubs",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_clubs_name", columnNames = "name"),
                @UniqueConstraint(name = "uk_clubs_abbr", columnNames = "abbr")
        }
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Club {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 10)
    private String abbr;

    @Column(nullable = false, length = 100)
    private String city;

    @Column(name = "logo_url")
    private String logoUrl;

    @Column(name = "primary_color", length = 30)
    private String primaryColor;

    @Column(name = "coach_name")
    private String coachName;

    @Column(name = "coach_info", length = 500)
    private String coachInfo;

    @Column(length = 100)
    private String stadium;

    @Column(name = "founded_year")
    private Integer foundedYear;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "club")
    @Builder.Default
    private List<Player> players = new ArrayList<>();
}
