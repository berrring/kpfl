package com.kurs.kpfl.integration.thesportsdb;

import com.kurs.kpfl.entity.Club;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class TheSportsDbClubMatcherTest {

    private final ClubNameNormalizer normalizer = new ClubNameNormalizer();
    private final TheSportsDbClubMatcher matcher = new TheSportsDbClubMatcher(normalizer);

    @Test
    void normalizer_shouldStripPrefixesAndExtraSpaces() {
        assertThat(normalizer.normalize("  FK   Dordoi   Bishkek ")).isEqualTo("dordoi bishkek");
        assertThat(normalizer.normalize("FC Bishkek-City")).isEqualTo("bishkek city");
    }

    @Test
    void matcher_shouldResolveByAbbrAndNormalizedName() {
        Club dordoi = Club.builder().id(7L).name("FK Dordoi Bishkek").abbr("DOR").city("Bishkek").build();
        Club muras = Club.builder().id(1L).name("Muras United Dzhalal-Abad").abbr("MUR").city("Dzhalal-Abad").build();

        List<Club> clubs = List.of(dordoi, muras);

        assertThat(matcher.match("dor", clubs)).contains(dordoi);
        assertThat(matcher.match("Dordoi Bishkek", clubs)).contains(dordoi);
        assertThat(matcher.match("Muras United", clubs)).contains(muras);
    }
}
