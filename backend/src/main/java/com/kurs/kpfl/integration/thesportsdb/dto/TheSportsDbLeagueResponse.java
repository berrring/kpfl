package com.kurs.kpfl.integration.thesportsdb.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class TheSportsDbLeagueResponse {
    private List<TheSportsDbLeagueDto> leagues;
}
