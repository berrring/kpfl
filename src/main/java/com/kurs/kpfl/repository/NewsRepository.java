package com.kurs.kpfl.repository;

import com.kurs.kpfl.model.entity.News;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface NewsRepository extends JpaRepository<News, Long> {
    Page<News> findAllByOrderByPublishedAtDesc(Pageable pageable);
}