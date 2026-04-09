package com.kurs.kpfl.entity.archive;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "kpfl_season_standings_archive")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KpflSeasonStandingsArchive {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "season_year", nullable = false)
    private Integer seasonYear;

    @Column(name = "place_no", nullable = false)
    private Integer placeNo;

    @Column(name = "club_name", nullable = false, length = 120)
    private String clubName;

    @Column(nullable = false)
    private Integer played;

    @Column(nullable = false)
    private Integer wins;

    @Column(nullable = false)
    private Integer draws;

    @Column(nullable = false)
    private Integer losses;

    @Column(name = "goals_for", nullable = false)
    private Integer goalsFor;

    @Column(name = "goals_against", nullable = false)
    private Integer goalsAgainst;

    @Column(name = "goal_difference", nullable = false)
    private Integer goalDifference;

    @Column(nullable = false)
    private Integer points;

    @Column(name = "matches_total")
    private Integer matchesTotal;
}
