package com.kurs.kpfl.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "thesportsdb")
public class TheSportsDbProperties {

    private String baseUrl = "https://www.thesportsdb.com/api/v1/json/123";
    private String leagueId = "4969";
    private boolean enabled = true;
    private String timezone = "UTC";
    private Sync sync = new Sync();

    @Getter
    @Setter
    public static class Sync {
        private String cron = "0 0 */2 * * *";
    }
}
