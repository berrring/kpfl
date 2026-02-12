-- V1: initial schema

CREATE TABLE seasons (
                         id BIGINT PRIMARY KEY AUTO_INCREMENT,
                         year INT NOT NULL,
                         name VARCHAR(64) NOT NULL,
                         start_date DATE NULL,
                         end_date DATE NULL,
                         UNIQUE KEY uk_seasons_year (year)
);

CREATE TABLE clubs (
                       id BIGINT PRIMARY KEY AUTO_INCREMENT,
                       name VARCHAR(128) NOT NULL,
                       abbr VARCHAR(10) NOT NULL,
                       city VARCHAR(64) NULL,
                       stadium VARCHAR(128) NULL,
                       founded_year INT NULL,
                       primary_color VARCHAR(32) NULL,
                       logo_url VARCHAR(512) NULL,
                       UNIQUE KEY uk_clubs_abbr (abbr),
                       UNIQUE KEY uk_clubs_name (name)
);

CREATE TABLE players (
                         id BIGINT PRIMARY KEY AUTO_INCREMENT,
                         club_id BIGINT NOT NULL,
                         first_name VARCHAR(64) NOT NULL,
                         last_name VARCHAR(64) NOT NULL,
                         number INT NULL,
                         position VARCHAR(8) NOT NULL, -- GK/DF/MF/FW
                         birth_date DATE NULL,
                         nationality VARCHAR(64) NULL,
                         height_cm INT NULL,
                         weight_kg INT NULL,
                         CONSTRAINT fk_players_club
                             FOREIGN KEY (club_id) REFERENCES clubs(id)
);

CREATE TABLE matches (
                         id BIGINT PRIMARY KEY AUTO_INCREMENT,
                         season_id BIGINT NOT NULL,
                         round_number INT NOT NULL,
                         date_time DATETIME NOT NULL,
                         stadium VARCHAR(128) NULL,
                         home_club_id BIGINT NOT NULL,
                         away_club_id BIGINT NOT NULL,
                         home_goals INT NULL,
                         away_goals INT NULL,
                         status VARCHAR(16) NOT NULL DEFAULT 'SCHEDULED', -- SCHEDULED/FINISHED/POSTPONED
                         CONSTRAINT fk_matches_season
                             FOREIGN KEY (season_id) REFERENCES seasons(id),
                         CONSTRAINT fk_matches_home_club
                             FOREIGN KEY (home_club_id) REFERENCES clubs(id),
                         CONSTRAINT fk_matches_away_club
                             FOREIGN KEY (away_club_id) REFERENCES clubs(id)
);

CREATE TABLE match_events (
                              id BIGINT PRIMARY KEY AUTO_INCREMENT,
                              match_id BIGINT NOT NULL,
                              minute INT NOT NULL,
                              type VARCHAR(16) NOT NULL, -- GOAL/YELLOW/RED
                              club_id BIGINT NOT NULL,
                              player_id BIGINT NULL,
                              assist_player_id BIGINT NULL,
                              CONSTRAINT fk_events_match
                                  FOREIGN KEY (match_id) REFERENCES matches(id),
                              CONSTRAINT fk_events_club
                                  FOREIGN KEY (club_id) REFERENCES clubs(id),
                              CONSTRAINT fk_events_player
                                  FOREIGN KEY (player_id) REFERENCES players(id),
                              CONSTRAINT fk_events_assist_player
                                  FOREIGN KEY (assist_player_id) REFERENCES players(id)
);

CREATE TABLE news (
                      id BIGINT PRIMARY KEY AUTO_INCREMENT,
                      title VARCHAR(200) NOT NULL,
                      short_text VARCHAR(1000) NOT NULL,
                      tag VARCHAR(64) NULL,
                      published_at DATETIME NOT NULL,
                      related_club_id BIGINT NULL,
                      related_player_id BIGINT NULL,
                      CONSTRAINT fk_news_club
                          FOREIGN KEY (related_club_id) REFERENCES clubs(id),
                      CONSTRAINT fk_news_player
                          FOREIGN KEY (related_player_id) REFERENCES players(id)
);

CREATE TABLE users (
                       id BIGINT PRIMARY KEY AUTO_INCREMENT,
                       email VARCHAR(200) NOT NULL,
                       password_hash VARCHAR(200) NOT NULL,
                       role VARCHAR(16) NOT NULL, -- USER/ADMIN
                       UNIQUE KEY uk_users_email (email)
);