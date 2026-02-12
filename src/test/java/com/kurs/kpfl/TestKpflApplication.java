package com.kurs.kpfl;

import org.springframework.boot.SpringApplication;

public class TestKpflApplication {

    public static void main(String[] args) {
        SpringApplication.from(KpflApplication::main).with(TestcontainersConfiguration.class).run(args);
    }

}
