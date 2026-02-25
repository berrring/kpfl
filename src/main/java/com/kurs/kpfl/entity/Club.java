package com.kurs.kpfl.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "clubs")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Club {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 10)
    private String abbr;

    @Column(nullable = false, length = 100)
    private String city;

    @Column(name = "logo_url")
    private String logoUrl;

    @Column(length = 100)
    private String stadium;

    @Column(name = "founded_year")
    private Integer foundedYear;

    @OneToMany(mappedBy = "club")
    @Builder.Default
    private List<Player> players = new ArrayList<>();
}