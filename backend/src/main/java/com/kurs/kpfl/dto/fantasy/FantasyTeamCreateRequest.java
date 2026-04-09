package com.kurs.kpfl.dto.fantasy;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class FantasyTeamCreateRequest {
    @NotBlank
    @Size(max = 100)
    private String name;

    @NotEmpty
    @Size(min = 15, max = 15)
    private List<Long> playerIds;
}
