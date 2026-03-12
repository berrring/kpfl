package com.kurs.kpfl.integration.thesportsdb.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class TheSportsDbEventsResponse {
    private List<TheSportsDbEventDto> events;
}
