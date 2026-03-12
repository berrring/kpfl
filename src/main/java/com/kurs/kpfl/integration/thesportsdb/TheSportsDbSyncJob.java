package com.kurs.kpfl.integration.thesportsdb;

import com.kurs.kpfl.config.TheSportsDbProperties;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicBoolean;

@Component
@RequiredArgsConstructor
public class TheSportsDbSyncJob {

    private static final Logger log = LoggerFactory.getLogger(TheSportsDbSyncJob.class);

    private final TheSportsDbSyncService syncService;
    private final TheSportsDbProperties properties;
    private final AtomicBoolean running = new AtomicBoolean(false);

    @Scheduled(cron = "${thesportsdb.sync.cron:0 0 */2 * * *}", zone = "${thesportsdb.timezone:UTC}")
    public void scheduledSync() {
        TheSportsDbSyncSummary summary = runSync("scheduled");
        logSummary("scheduled", summary);
    }

    public TheSportsDbSyncSummary runManualSync() {
        TheSportsDbSyncSummary summary = runSync("manual");
        logSummary("manual", summary);
        return summary;
    }

    private TheSportsDbSyncSummary runSync(String trigger) {
        if (!properties.isEnabled()) {
            log.info("TheSportsDB {} sync skipped: integration disabled", trigger);
            return TheSportsDbSyncSummary.notExecuted("Sync disabled by configuration");
        }

        if (!running.compareAndSet(false, true)) {
            log.warn("TheSportsDB {} sync skipped: another sync is already running", trigger);
            return TheSportsDbSyncSummary.notExecuted("Sync already running");
        }

        try {
            return syncService.sync();
        } catch (Exception ex) {
            log.error("TheSportsDB {} sync failed with unexpected error: {}", trigger, ex.getMessage(), ex);
            return new TheSportsDbSyncSummary(0, 0, 0, 1, "Unexpected sync error");
        } finally {
            running.set(false);
        }
    }

    private void logSummary(String trigger, TheSportsDbSyncSummary summary) {
        log.info(
                "TheSportsDB {} sync summary: imported={}, updated={}, skipped={}, errors={}, note='{}'",
                trigger, summary.imported(), summary.updated(), summary.skipped(), summary.errors(), summary.note()
        );
    }
}
