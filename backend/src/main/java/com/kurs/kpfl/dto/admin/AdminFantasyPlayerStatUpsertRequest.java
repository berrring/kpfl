package com.kurs.kpfl.dto.admin;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AdminFantasyPlayerStatUpsertRequest {
    @NotNull
    private Long matchId;

    @NotNull
    private Long playerId;

    @NotNull
    @Min(0)
    @Max(200)
    private Integer minutesPlayed;

    @Min(0)
    private Integer goals;

    @Min(0)
    private Integer assists;

    private Boolean cleanSheet;

    @Min(0)
    private Integer goalsConceded;

    @Min(0)
    private Integer yellowCards;

    @Min(0)
    private Integer redCards;

    @Min(0)
    private Integer ownGoals;

    @Min(0)
    private Integer penaltiesSaved;

    @Min(0)
    private Integer penaltiesMissed;

    @Min(0)
    private Integer saves;

    private Boolean started;

    private Boolean substitutedIn;

    private Boolean substitutedOut;
}
