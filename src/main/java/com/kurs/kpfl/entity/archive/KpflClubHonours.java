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
@Table(name = "kpfl_club_honours")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KpflClubHonours {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "club_name", nullable = false, length = 120)
    private String clubName;

    @Column(nullable = false)
    private Integer titles;

    @Column(name = "runner_up_count", nullable = false)
    private Integer runnerUpCount;

    @Column(name = "third_place_count", nullable = false)
    private Integer thirdPlaceCount;

    @Column(name = "championship_years", length = 500)
    private String championshipYears;
}
