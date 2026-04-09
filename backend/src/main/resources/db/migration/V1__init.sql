CREATE TABLE seasons (
    id BIGSERIAL PRIMARY KEY,
    year INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    CONSTRAINT uk_seasons_year UNIQUE (year)
);

CREATE TABLE clubs (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    abbr VARCHAR(10) NOT NULL,
    city VARCHAR(100) NOT NULL,
    stadium VARCHAR(100) NULL,
    founded_year INT NULL,
    primary_color VARCHAR(30) NULL,
    logo_url VARCHAR(255) NULL,
    coach_name VARCHAR(255) NULL,
    coach_info VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_clubs_name UNIQUE (name),
    CONSTRAINT uk_clubs_abbr UNIQUE (abbr)
);

CREATE TABLE players (
    id BIGSERIAL PRIMARY KEY,
    club_id BIGINT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    jersey_number INT NULL,
    position VARCHAR(10) NOT NULL,
    birth_date DATE NULL,
    nationality VARCHAR(50) NULL,
    height_cm INT NULL,
    weight_kg INT NULL,
    age_years INT NULL,
    market_value_eur BIGINT NULL,
    photo_url VARCHAR(255) NULL,
    source_url VARCHAR(500) NULL,
    source_note VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_players_club FOREIGN KEY (club_id) REFERENCES clubs(id),
    CONSTRAINT uk_players_club_number UNIQUE (club_id, jersey_number),
    CONSTRAINT chk_players_position CHECK (position IN ('GK', 'DF', 'MF', 'FW'))
);

CREATE TABLE matches (
    id BIGSERIAL PRIMARY KEY,
    season_id BIGINT NOT NULL,
    round_number INT NOT NULL,
    date_time TIMESTAMP NOT NULL,
    stadium VARCHAR(100) NULL,
    home_club_id BIGINT NOT NULL,
    away_club_id BIGINT NOT NULL,
    home_goals INT NULL,
    away_goals INT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_matches_season FOREIGN KEY (season_id) REFERENCES seasons(id),
    CONSTRAINT fk_matches_home_club FOREIGN KEY (home_club_id) REFERENCES clubs(id),
    CONSTRAINT fk_matches_away_club FOREIGN KEY (away_club_id) REFERENCES clubs(id),
    CONSTRAINT chk_matches_home_away CHECK (home_club_id <> away_club_id),
    CONSTRAINT chk_matches_status CHECK (status IN ('SCHEDULED', 'FINISHED', 'POSTPONED'))
);

CREATE TABLE news (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    short_text VARCHAR(500) NULL,
    tag VARCHAR(20) NOT NULL,
    published_at TIMESTAMP NOT NULL,
    club_id BIGINT NULL,
    player_id BIGINT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_news_club FOREIGN KEY (club_id) REFERENCES clubs(id),
    CONSTRAINT fk_news_player FOREIGN KEY (player_id) REFERENCES players(id),
    CONSTRAINT chk_news_tag CHECK (tag IN ('TRANSFER', 'MATCHDAY', 'INJURY', 'OFFICIAL', 'OTHER'))
);

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    display_name VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_users_email UNIQUE (email),
    CONSTRAINT chk_users_role CHECK (role IN ('USER', 'ADMIN'))
);
