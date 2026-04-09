package com.kurs.kpfl;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class KpflApplication {

    public static void main(String[] args) {
        SpringApplication.run(KpflApplication.class, args);
    }

}
