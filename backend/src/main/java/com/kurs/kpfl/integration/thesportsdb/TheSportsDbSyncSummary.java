package com.kurs.kpfl.integration.thesportsdb;

public record TheSportsDbSyncSummary(
        int imported,
        int updated,
        int skipped,
        int errors,
        String note
) {
    public static TheSportsDbSyncSummary notExecuted(String note) {
        return new TheSportsDbSyncSummary(0, 0, 0, 0, note);
    }
}
