package com.kurs.kpfl.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class TheSportsDbClientConfig {

    @Bean
    public RestTemplate theSportsDbRestTemplate() {
        return new RestTemplate();
    }
}
