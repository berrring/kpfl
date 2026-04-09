package com.kurs.kpfl.dto.admin;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class AdminClubUpsertRequest {
    @NotBlank
    @Size(max = 100)
    private String name;

    @NotBlank
    @Size(max = 10)
    private String abbr;

    @NotBlank
    @Size(max = 100)
    private String city;

    @Size(max = 100)
    private String stadium;

    private Integer foundedYear;

    @Size(max = 30)
    private String primaryColor;

    @Size(max = 255)
    private String logoUrl;

    @Size(max = 255)
    private String coachName;

    @Size(max = 500)
    private String coachInfo;
}
