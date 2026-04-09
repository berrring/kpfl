package com.kurs.kpfl.controller.admin;

import com.kurs.kpfl.config.OpenApiConfig;
import com.kurs.kpfl.integration.thesportsdb.TheSportsDbSyncJob;
import com.kurs.kpfl.integration.thesportsdb.TheSportsDbSyncSummary;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/import")
@RequiredArgsConstructor
@SecurityRequirement(name = OpenApiConfig.BEARER_AUTH_SCHEME)
public class AdminImportController {

    private final TheSportsDbSyncJob theSportsDbSyncJob;

    @PostMapping("/thesportsdb")
    public TheSportsDbSyncSummary importTheSportsDb() {
        return theSportsDbSyncJob.runManualSync();
    }
}
