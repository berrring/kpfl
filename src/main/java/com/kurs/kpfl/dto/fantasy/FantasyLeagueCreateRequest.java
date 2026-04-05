package com.kurs.kpfl.dto.fantasy;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class FantasyLeagueCreateRequest {
    @NotBlank
    @Size(max = 100)
    private String name;
}
