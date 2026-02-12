-- V2: indexes

CREATE INDEX ix_players_club_id ON players(club_id);

CREATE INDEX ix_matches_season_datetime ON matches(season_id, date_time);
CREATE INDEX ix_matches_season_round ON matches(season_id, round_number);
CREATE INDEX ix_matches_home_club ON matches(home_club_id);
CREATE INDEX ix_matches_away_club ON matches(away_club_id);

CREATE INDEX ix_match_events_match_minute ON match_events(match_id, minute);

CREATE INDEX ix_news_published_at ON news(published_at);