package com.kurs.kpfl.dto.fantasy;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class FantasyTransferItemRequest {
    @NotNull
    private Long playerOutId;

    @NotNull
    private Long playerInId;
}
