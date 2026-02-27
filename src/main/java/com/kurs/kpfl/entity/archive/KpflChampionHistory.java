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
@Table(name = "kpfl_champion_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KpflChampionHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "season_year", nullable = false)
    private Integer seasonYear;

    @Column(nullable = false, length = 120)
    private String champion;

    @Column(name = "champion_title_no")
    private Integer championTitleNo;

    @Column(name = "runner_up", length = 120)
    private String runnerUp;

    @Column(name = "third_place", length = 120)
    private String thirdPlace;

    @Column(name = "top_scorer", length = 120)
    private String topScorer;

    @Column(name = "top_scorer_goals")
    private Integer topScorerGoals;

    @Column(name = "top_scorer_club", length = 120)
    private String topScorerClub;

    @Column(name = "player_of_year", length = 120)
    private String playerOfYear;

    @Column(length = 255)
    private String notes;
}
