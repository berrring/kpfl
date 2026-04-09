package com.kurs.kpfl.dto.admin;

import com.kurs.kpfl.model.MatchStatus;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AdminMatchUpsertRequest {
    @NotNull
    private Integer seasonYear;

    @NotNull
    @Min(1)
    private Integer roundNumber;

    @NotNull
    private LocalDateTime dateTime;

    private String stadium;

    @NotNull
    private Long homeClubId;

    @NotNull
    private Long awayClubId;

    @Min(0)
    private Integer homeGoals;

    @Min(0)
    private Integer awayGoals;

    @NotNull
    private MatchStatus status;
}
