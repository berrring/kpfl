package com.kurs.kpfl.dto.admin;

import com.kurs.kpfl.model.PlayerPosition;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;

@Data
public class AdminPlayerUpsertRequest {
    @NotNull
    private Long clubId;

    @NotBlank
    @Size(max = 50)
    private String firstName;

    @NotBlank
    @Size(max = 80)
    private String lastName;

    @Min(1)
    private Integer number;

    @NotNull
    private PlayerPosition position;

    private LocalDate birthDate;

    @Size(max = 50)
    private String nationality;

    @Min(100)
    private Integer heightCm;

    @Min(35)
    private Integer weightKg;

    @Min(15)
    private Integer ageYears;

    @Min(0)
    private Long marketValueEur;

    @Size(max = 255)
    private String photoUrl;

    @Size(max = 500)
    private String sourceUrl;

    @Size(max = 500)
    private String sourceNote;
}
