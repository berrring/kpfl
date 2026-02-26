package com.kurs.kpfl.dto.admin;

import com.kurs.kpfl.model.NewsTag;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AdminNewsUpsertRequest {
    @NotBlank
    @Size(max = 255)
    private String title;

    @Size(max = 500)
    private String shortText;

    @NotNull
    private NewsTag tag;

    @NotNull
    private LocalDateTime publishedAt;

    private Long clubId;
    private Long playerId;
}
