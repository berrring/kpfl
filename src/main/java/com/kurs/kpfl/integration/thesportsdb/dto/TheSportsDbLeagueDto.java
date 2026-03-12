package com.kurs.kpfl.integration.thesportsdb.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class TheSportsDbLeagueDto {
    private String idLeague;
    private String strLeague;
    private String strBadge;
}
