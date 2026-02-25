CREATE INDEX ix_players_club_id ON players(club_id);
CREATE INDEX ix_matches_season_datetime ON matches(season_year, date_time);
CREATE INDEX ix_matches_season_round ON matches(season_year, round_number);
CREATE INDEX ix_matches_home_club ON matches(home_club_id);
CREATE INDEX ix_matches_away_club ON matches(away_club_id);
CREATE INDEX ix_news_published_at ON news(published_at);