package com.kurs.kpfl.dto;
import java.time.LocalDate;
public record PlayerDetailDto(Long id, String firstName, String lastName, Integer number, String position, LocalDate birthDate, String nationality, Integer heightCm, Integer weightKg, ClubListItemDto club) {}