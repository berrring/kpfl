package com.kurs.kpfl.integration.thesportsdb.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class TheSportsDbEventDto {
    private String idEvent;
    private String dateEvent;
    private String strTime;
    private String strTimestamp;
    private String strHomeTeam;
    private String strAwayTeam;
    private Integer intHomeScore;
    private Integer intAwayScore;
    private String strVenue;
    private String strStatus;
    private String idHomeTeam;
    private String idAwayTeam;
    private Integer intRound;
}
