package com.kurs.kpfl.dto.admin;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AdminMatchResultRequest {
    @NotNull
    @Min(0)
    private Integer homeGoals;

    @NotNull
    @Min(0)
    private Integer awayGoals;
}
