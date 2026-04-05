package com.kurs.kpfl.dto.fantasy;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class FantasyTransferRequest {
    private Integer seasonYear;

    @NotNull
    @Min(1)
    private Integer roundNumber;

    @Valid
    @NotEmpty
    private List<FantasyTransferItemRequest> transfers;
}
