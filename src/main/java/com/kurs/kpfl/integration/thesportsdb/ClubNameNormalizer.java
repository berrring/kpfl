package com.kurs.kpfl.integration.thesportsdb;

import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

@Component
public class ClubNameNormalizer {

    private static final Pattern NON_ALPHA_NUMERIC = Pattern.compile("[^\\p{L}\\p{N}\\s]");
    private static final Pattern MULTI_SPACE = Pattern.compile("\\s+");
    private static final Set<String> IGNORED_TOKENS = Set.of(
            "fc", "fk", "pfk", "sc", "cf", "football", "club"
    );

    public String normalize(String rawValue) {
        if (rawValue == null) {
            return "";
        }

        String prepared = rawValue
                .trim()
                .toLowerCase(Locale.ROOT)
                .replace('-', ' ');

        String withoutPunctuation = NON_ALPHA_NUMERIC
                .matcher(prepared)
                .replaceAll(" ");

        return Arrays.stream(MULTI_SPACE.split(withoutPunctuation.trim()))
                .filter(token -> !token.isBlank())
                .filter(token -> !IGNORED_TOKENS.contains(token))
                .reduce((left, right) -> left + " " + right)
                .orElse("");
    }
}
