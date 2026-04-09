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
        assertThat(normalizer.normalize("Bars Issyk-Kul")).isEqualTo("bars");
        assertThat(normalizer.normalize("Bars Karakol")).isEqualTo("bars");
        assertThat(normalizer.normalize("OshSU Aldier")).isEqualTo("oshmu");
        assertThat(normalizer.normalize("FC OshMU")).isEqualTo("oshmu");
    }

    @Test
    void matcher_shouldResolveByAbbrAndNormalizedName() {
        Club dordoi = Club.builder().id(7L).name("FK Dordoi Bishkek").abbr("DOR").city("Bishkek").build();
        Club muras = Club.builder().id(1L).name("Muras United Dzhalal-Abad").abbr("MUR").city("Dzhalal-Abad").build();
        Club bars = Club.builder().id(3L).name("Bars Karakol").abbr("BRS").city("Karakol").build();
        Club oshmu = Club.builder().id(14L).name("FC OshMU").abbr("OSM").city("Osh").build();

        List<Club> clubs = List.of(dordoi, muras, bars, oshmu);

        assertThat(matcher.match("dor", clubs)).contains(dordoi);
        assertThat(matcher.match("Dordoi Bishkek", clubs)).contains(dordoi);
        assertThat(matcher.match("Muras United", clubs)).contains(muras);
        assertThat(matcher.match("Bars Issyk-Kul", clubs)).contains(bars);
        assertThat(matcher.match("OshSU Aldier", clubs)).contains(oshmu);
    }
}
