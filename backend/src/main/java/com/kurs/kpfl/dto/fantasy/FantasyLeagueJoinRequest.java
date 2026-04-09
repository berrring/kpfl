package com.kurs.kpfl.dto.fantasy;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class FantasyLeagueJoinRequest {
    @NotBlank
    @Size(max = 20)
    private String code;
}
