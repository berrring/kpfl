package com.kurs.kpfl.integration.thesportsdb;

import com.kurs.kpfl.entity.Club;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class TheSportsDbClubMatcher {

    private final ClubNameNormalizer clubNameNormalizer;

    public Optional<Club> match(String externalTeamName, Collection<Club> clubs) {
        if (clubs == null || clubs.isEmpty() || externalTeamName == null || externalTeamName.isBlank()) {
            return Optional.empty();
        }

        String probe = externalTeamName.trim();

        Optional<Club> exact = clubs.stream()
                .filter(club -> equalsIgnoreCase(probe, club.getAbbr()) || equalsIgnoreCase(probe, club.getName()))
                .findFirst();
        if (exact.isPresent()) {
            return exact;
        }

        String normalizedProbe = clubNameNormalizer.normalize(probe);
        if (normalizedProbe.isBlank()) {
            return Optional.empty();
        }

        List<Club> normalizedExact = clubs.stream()
                .filter(club -> normalizedProbe.equals(clubNameNormalizer.normalize(club.getAbbr()))
                        || normalizedProbe.equals(clubNameNormalizer.normalize(club.getName())))
                .toList();
        if (normalizedExact.size() == 1) {
            return Optional.of(normalizedExact.getFirst());
        }
        if (normalizedExact.size() > 1) {
            return Optional.empty();
        }

        List<Club> fuzzy = clubs.stream()
                .filter(club -> isFuzzyMatch(normalizedProbe, clubNameNormalizer.normalize(club.getName())))
                .toList();
        if (fuzzy.size() == 1) {
            return Optional.of(fuzzy.getFirst());
        }

        return Optional.empty();
    }

    private boolean isFuzzyMatch(String normalizedProbe, String normalizedClubName) {
        if (normalizedProbe.isBlank() || normalizedClubName.isBlank()) {
            return false;
        }
        if (normalizedProbe.length() < 3 || normalizedClubName.length() < 3) {
            return false;
        }
        return normalizedProbe.contains(normalizedClubName) || normalizedClubName.contains(normalizedProbe);
    }

    private boolean equalsIgnoreCase(String left, String right) {
        return left != null && right != null && left.equalsIgnoreCase(right);
    }
}
