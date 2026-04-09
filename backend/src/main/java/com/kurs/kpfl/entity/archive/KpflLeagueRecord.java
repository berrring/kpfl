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
@Table(name = "kpfl_league_records")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KpflLeagueRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "record_key", nullable = false, length = 120)
    private String recordKey;

    @Column(name = "record_value", nullable = false, length = 500)
    private String recordValue;

    @Column(name = "source_note", length = 255)
    private String sourceNote;
}
