package com.kurs.kpfl.dto.history;

public record KpflChampionHistoryDto(
        Long id,
        Integer seasonYear,
        String champion,
        Integer championTitleNo,
        String runnerUp,
        String thirdPlace,
        String topScorer,
        Integer topScorerGoals,
        String topScorerClub,
        String playerOfYear,
        String notes
) {
}
