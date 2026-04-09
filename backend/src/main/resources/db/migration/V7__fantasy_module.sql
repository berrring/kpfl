CREATE TABLE fantasy_teams (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    season_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    total_points INT NOT NULL DEFAULT 0,
    current_budget NUMERIC(5,1) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_teams_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_fantasy_teams_season FOREIGN KEY (season_id) REFERENCES seasons(id),
    CONSTRAINT uk_fantasy_teams_user_season UNIQUE (user_id, season_id)
);

CREATE TABLE fantasy_team_players (
    id BIGSERIAL PRIMARY KEY,
    fantasy_team_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    acquired_price NUMERIC(5,1) NOT NULL,
    acquired_round INT NOT NULL,
    sold_round INT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_team_players_team FOREIGN KEY (fantasy_team_id) REFERENCES fantasy_teams(id),
    CONSTRAINT fk_fantasy_team_players_player FOREIGN KEY (player_id) REFERENCES players(id),
    CONSTRAINT chk_fantasy_team_players_rounds CHECK (acquired_round > 0 AND (sold_round IS NULL OR sold_round >= acquired_round))
);

CREATE UNIQUE INDEX uk_fantasy_team_players_active
    ON fantasy_team_players (fantasy_team_id, player_id)
    WHERE active = TRUE;

CREATE TABLE fantasy_team_round_selections (
    id BIGSERIAL PRIMARY KEY,
    fantasy_team_id BIGINT NOT NULL,
    season_id BIGINT NOT NULL,
    round_number INT NOT NULL,
    locked_at TIMESTAMP NOT NULL,
    finalized BOOLEAN NOT NULL DEFAULT FALSE,
    captain_player_id BIGINT NOT NULL,
    vice_captain_player_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_selections_team FOREIGN KEY (fantasy_team_id) REFERENCES fantasy_teams(id),
    CONSTRAINT fk_fantasy_selections_season FOREIGN KEY (season_id) REFERENCES seasons(id),
    CONSTRAINT fk_fantasy_selections_captain FOREIGN KEY (captain_player_id) REFERENCES players(id),
    CONSTRAINT fk_fantasy_selections_vice FOREIGN KEY (vice_captain_player_id) REFERENCES players(id),
    CONSTRAINT uk_fantasy_selections_team_round UNIQUE (fantasy_team_id, season_id, round_number),
    CONSTRAINT chk_fantasy_selections_round CHECK (round_number > 0),
    CONSTRAINT chk_fantasy_selections_captains CHECK (captain_player_id <> vice_captain_player_id)
);

CREATE TABLE fantasy_lineup_entries (
    id BIGSERIAL PRIMARY KEY,
    round_selection_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    starter BOOLEAN NOT NULL,
    starter_order INT NULL,
    bench_order INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_lineup_selection FOREIGN KEY (round_selection_id) REFERENCES fantasy_team_round_selections(id) ON DELETE CASCADE,
    CONSTRAINT fk_fantasy_lineup_player FOREIGN KEY (player_id) REFERENCES players(id),
    CONSTRAINT uk_fantasy_lineup_selection_player UNIQUE (round_selection_id, player_id),
    CONSTRAINT uk_fantasy_lineup_selection_starter_order UNIQUE (round_selection_id, starter_order),
    CONSTRAINT uk_fantasy_lineup_selection_bench_order UNIQUE (round_selection_id, bench_order),
    CONSTRAINT chk_fantasy_lineup_role CHECK (
        (starter = TRUE AND starter_order BETWEEN 1 AND 11 AND bench_order IS NULL)
        OR
        (starter = FALSE AND bench_order BETWEEN 1 AND 4 AND starter_order IS NULL)
    )
);

CREATE TABLE fantasy_transfers (
    id BIGSERIAL PRIMARY KEY,
    fantasy_team_id BIGINT NOT NULL,
    season_id BIGINT NOT NULL,
    round_number INT NOT NULL,
    player_out_id BIGINT NOT NULL,
    player_in_id BIGINT NOT NULL,
    cost_points INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_transfers_team FOREIGN KEY (fantasy_team_id) REFERENCES fantasy_teams(id),
    CONSTRAINT fk_fantasy_transfers_season FOREIGN KEY (season_id) REFERENCES seasons(id),
    CONSTRAINT fk_fantasy_transfers_player_out FOREIGN KEY (player_out_id) REFERENCES players(id),
    CONSTRAINT fk_fantasy_transfers_player_in FOREIGN KEY (player_in_id) REFERENCES players(id),
    CONSTRAINT chk_fantasy_transfers_round CHECK (round_number > 0),
    CONSTRAINT chk_fantasy_transfers_players CHECK (player_out_id <> player_in_id)
);

CREATE TABLE fantasy_player_prices (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,
    season_id BIGINT NOT NULL,
    current_price NUMERIC(5,1) NOT NULL,
    initial_price NUMERIC(5,1) NOT NULL,
    price_source VARCHAR(30) NOT NULL,
    last_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_prices_player FOREIGN KEY (player_id) REFERENCES players(id),
    CONSTRAINT fk_fantasy_prices_season FOREIGN KEY (season_id) REFERENCES seasons(id),
    CONSTRAINT uk_fantasy_prices_player_season UNIQUE (player_id, season_id),
    CONSTRAINT chk_fantasy_prices_source CHECK (price_source IN ('MARKET_VALUE', 'POSITION_DEFAULT'))
);

CREATE TABLE fantasy_player_match_stats (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,
    match_id BIGINT NOT NULL,
    minutes_played INT NOT NULL DEFAULT 0,
    goals INT NOT NULL DEFAULT 0,
    assists INT NOT NULL DEFAULT 0,
    clean_sheet BOOLEAN NOT NULL DEFAULT FALSE,
    goals_conceded INT NOT NULL DEFAULT 0,
    yellow_cards INT NOT NULL DEFAULT 0,
    red_cards INT NOT NULL DEFAULT 0,
    own_goals INT NOT NULL DEFAULT 0,
    penalties_saved INT NOT NULL DEFAULT 0,
    penalties_missed INT NOT NULL DEFAULT 0,
    saves INT NOT NULL DEFAULT 0,
    started BOOLEAN NOT NULL DEFAULT FALSE,
    substituted_in BOOLEAN NOT NULL DEFAULT FALSE,
    substituted_out BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_match_stats_player FOREIGN KEY (player_id) REFERENCES players(id),
    CONSTRAINT fk_fantasy_match_stats_match FOREIGN KEY (match_id) REFERENCES matches(id),
    CONSTRAINT uk_fantasy_match_stats_player_match UNIQUE (player_id, match_id),
    CONSTRAINT chk_fantasy_match_stats_minutes CHECK (minutes_played >= 0),
    CONSTRAINT chk_fantasy_match_stats_goals CHECK (goals >= 0),
    CONSTRAINT chk_fantasy_match_stats_assists CHECK (assists >= 0),
    CONSTRAINT chk_fantasy_match_stats_conceded CHECK (goals_conceded >= 0),
    CONSTRAINT chk_fantasy_match_stats_yellow CHECK (yellow_cards >= 0),
    CONSTRAINT chk_fantasy_match_stats_red CHECK (red_cards >= 0),
    CONSTRAINT chk_fantasy_match_stats_own_goals CHECK (own_goals >= 0),
    CONSTRAINT chk_fantasy_match_stats_pen_saved CHECK (penalties_saved >= 0),
    CONSTRAINT chk_fantasy_match_stats_pen_missed CHECK (penalties_missed >= 0),
    CONSTRAINT chk_fantasy_match_stats_saves CHECK (saves >= 0)
);

CREATE TABLE fantasy_player_round_points (
    id BIGSERIAL PRIMARY KEY,
    fantasy_team_id BIGINT NOT NULL,
    season_id BIGINT NOT NULL,
    round_number INT NOT NULL,
    player_id BIGINT NOT NULL,
    raw_points INT NOT NULL,
    applied_points INT NOT NULL,
    starter BOOLEAN NOT NULL,
    captain_applied BOOLEAN NOT NULL DEFAULT FALSE,
    vice_captain_applied BOOLEAN NOT NULL DEFAULT FALSE,
    auto_sub_applied BOOLEAN NOT NULL DEFAULT FALSE,
    explanation VARCHAR(500) NULL,
    CONSTRAINT fk_fantasy_round_points_team FOREIGN KEY (fantasy_team_id) REFERENCES fantasy_teams(id),
    CONSTRAINT fk_fantasy_round_points_season FOREIGN KEY (season_id) REFERENCES seasons(id),
    CONSTRAINT fk_fantasy_round_points_player FOREIGN KEY (player_id) REFERENCES players(id),
    CONSTRAINT uk_fantasy_round_points_team_round_player UNIQUE (fantasy_team_id, season_id, round_number, player_id),
    CONSTRAINT chk_fantasy_round_points_round CHECK (round_number > 0)
);

CREATE TABLE fantasy_team_round_scores (
    id BIGSERIAL PRIMARY KEY,
    fantasy_team_id BIGINT NOT NULL,
    season_id BIGINT NOT NULL,
    round_number INT NOT NULL,
    points INT NOT NULL,
    transfer_penalty INT NOT NULL DEFAULT 0,
    final_points INT NOT NULL,
    rank_snapshot INT NULL,
    calculated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_round_scores_team FOREIGN KEY (fantasy_team_id) REFERENCES fantasy_teams(id),
    CONSTRAINT fk_fantasy_round_scores_season FOREIGN KEY (season_id) REFERENCES seasons(id),
    CONSTRAINT uk_fantasy_round_scores_team_round UNIQUE (fantasy_team_id, season_id, round_number),
    CONSTRAINT chk_fantasy_round_scores_round CHECK (round_number > 0),
    CONSTRAINT chk_fantasy_round_scores_penalty CHECK (transfer_penalty >= 0)
);

CREATE TABLE fantasy_leagues (
    id BIGSERIAL PRIMARY KEY,
    season_id BIGINT NOT NULL,
    owner_user_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL,
    is_private BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_leagues_season FOREIGN KEY (season_id) REFERENCES seasons(id),
    CONSTRAINT fk_fantasy_leagues_owner FOREIGN KEY (owner_user_id) REFERENCES users(id),
    CONSTRAINT uk_fantasy_leagues_code UNIQUE (code)
);

CREATE TABLE fantasy_league_members (
    id BIGSERIAL PRIMARY KEY,
    fantasy_league_id BIGINT NOT NULL,
    fantasy_team_id BIGINT NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fantasy_league_members_league FOREIGN KEY (fantasy_league_id) REFERENCES fantasy_leagues(id) ON DELETE CASCADE,
    CONSTRAINT fk_fantasy_league_members_team FOREIGN KEY (fantasy_team_id) REFERENCES fantasy_teams(id),
    CONSTRAINT uk_fantasy_league_members UNIQUE (fantasy_league_id, fantasy_team_id)
);

CREATE INDEX ix_fantasy_teams_season_points ON fantasy_teams (season_id, total_points DESC);
CREATE INDEX ix_fantasy_team_players_team_active ON fantasy_team_players (fantasy_team_id, active);
CREATE INDEX ix_fantasy_selections_season_round ON fantasy_team_round_selections (season_id, round_number);
CREATE INDEX ix_fantasy_transfers_team_round ON fantasy_transfers (fantasy_team_id, season_id, round_number);
CREATE INDEX ix_fantasy_prices_season ON fantasy_player_prices (season_id);
CREATE INDEX ix_fantasy_match_stats_match ON fantasy_player_match_stats (match_id);
CREATE INDEX ix_fantasy_round_points_season_round ON fantasy_player_round_points (season_id, round_number);
CREATE INDEX ix_fantasy_round_scores_season_round ON fantasy_team_round_scores (season_id, round_number);
CREATE INDEX ix_fantasy_leagues_season ON fantasy_leagues (season_id);
CREATE INDEX ix_fantasy_league_members_team ON fantasy_league_members (fantasy_team_id);
