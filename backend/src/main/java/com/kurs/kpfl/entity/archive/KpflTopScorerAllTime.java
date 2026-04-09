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

import java.math.BigDecimal;

@Entity
@Table(name = "kpfl_top_scorers_all_time")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KpflTopScorerAllTime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "rank_no", nullable = false)
    private Integer rankNo;

    @Column(name = "player_name", nullable = false, length = 120)
    private String playerName;

    @Column(name = "position_name", length = 60)
    private String positionName;

    @Column(nullable = false)
    private Integer goals;

    @Column(name = "matches_played", nullable = false)
    private Integer matchesPlayed;

    @Column(name = "goals_per_match", nullable = false)
    private BigDecimal goalsPerMatch;

    @Column(name = "source_note", length = 255)
    private String sourceNote;
}
