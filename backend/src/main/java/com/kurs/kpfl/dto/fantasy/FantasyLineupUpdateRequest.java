package com.kurs.kpfl.dto.fantasy;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class FantasyLineupUpdateRequest {
    private Integer seasonYear;

    @NotNull
    @Min(1)
    private Integer roundNumber;

    @NotEmpty
    @Size(min = 11, max = 11)
    private List<Long> starterPlayerIds;

    @NotEmpty
    @Size(min = 4, max = 4)
    private List<Long> benchPlayerIds;

    @NotNull
    private Long captainPlayerId;

    @NotNull
    private Long viceCaptainPlayerId;
}
