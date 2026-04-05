package com.kurs.kpfl.dto.fantasy;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class FantasySquadUpdateRequest {
    @NotEmpty
    @Size(min = 15, max = 15)
    private List<Long> playerIds;
}
