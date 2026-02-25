package com.kurs.kpfl.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "news")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class News {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(length = 50)
    private String tag;

    @Column(name = "published_at", nullable = false)
    private LocalDateTime publishedAt;

    @Column(name = "short_text", columnDefinition = "TEXT")
    private String shortText;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "related_club_id")
    private Club relatedClub;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "related_player_id")
    private Player relatedPlayer;
}