CREATE TABLE clubs (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       name VARCHAR(100) NOT NULL,
                       abbr VARCHAR(10) NOT NULL,
                       city VARCHAR(100) NOT NULL,
                       primary_color VARCHAR(30),
                       logo_url VARCHAR(255),
                       stadium VARCHAR(100),
                       founded_year INT
);

CREATE TABLE players (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         first_name VARCHAR(50) NOT NULL,
                         last_name VARCHAR(50) NOT NULL,
                         jersey_number INT,
                         position VARCHAR(30),
                         birth_date DATE,
                         nationality VARCHAR(50),
                         height_cm INT,
                         weight_kg INT,
                         club_id BIGINT,
                         CONSTRAINT fk_players_club FOREIGN KEY (club_id) REFERENCES clubs(id)
);

CREATE TABLE matches (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         date_time DATETIME NOT NULL,
                         status VARCHAR(30) NOT NULL,
                         home_club_id BIGINT NOT NULL,
                         away_club_id BIGINT NOT NULL,
                         home_goals INT,
                         away_goals INT,
                         stadium VARCHAR(100),
                         round_number INT,
                         season_year INT,
                         CONSTRAINT fk_matches_home_club FOREIGN KEY (home_club_id) REFERENCES clubs(id),
                         CONSTRAINT fk_matches_away_club FOREIGN KEY (away_club_id) REFERENCES clubs(id)
);

CREATE TABLE news (
                      id BIGINT AUTO_INCREMENT PRIMARY KEY,
                      title VARCHAR(255) NOT NULL,
                      tag VARCHAR(50),
                      published_at DATETIME NOT NULL,
                      short_text TEXT,
                      related_club_id BIGINT,
                      related_player_id BIGINT,
                      CONSTRAINT fk_news_club FOREIGN KEY (related_club_id) REFERENCES clubs(id),
                      CONSTRAINT fk_news_player FOREIGN KEY (related_player_id) REFERENCES players(id)
);

CREATE TABLE users (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       email VARCHAR(255) NOT NULL,
                       password_hash VARCHAR(255) NOT NULL,
                       role VARCHAR(50) NOT NULL
);