-- Make the fantasy module usable on a fresh database:
-- 1. add enough midfielders/forwards to satisfy squad rules
-- 2. seed demo users with ready fantasy teams and a private league
-- 3. backfill a completed past round with fantasy scores
-- 4. keep one future round open for transfers/lineup testing

INSERT INTO users (email, password_hash, role, display_name, created_at)
SELECT v.email, '{noop}demo123', 'USER', v.display_name, TIMESTAMP '2026-03-01 09:00:00'
FROM (
    VALUES
        ('askar.demo@kpfl.local', 'Askar Demo'),
        ('aidana.demo@kpfl.local', 'Aidana Demo'),
        ('timur.demo@kpfl.local', 'Timur Demo')
) AS v(email, display_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM users u
    WHERE u.email = v.email
);

CREATE TEMPORARY TABLE tmp_fantasy_demo_players (
    club_abbr VARCHAR(10) NOT NULL,
    position VARCHAR(10) NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    age_years INT NULL,
    market_value_eur BIGINT NULL
);

INSERT INTO tmp_fantasy_demo_players (club_abbr, position, full_name, age_years, market_value_eur) VALUES
('MUR', 'MF', 'Bekzat Sydykov', 24, 75000),
('ALG', 'MF', 'Kaiyr Nurmatov', 22, 50000),
('BRS', 'MF', 'Ruslan Kadyrov', 27, 100000),
('OZG', 'MF', 'Argen Osmonov', 23, 75000),
('BSC', 'MF', 'Mirlan Satarov', 21, 25000),
('ASG', 'MF', 'Aibek Tursunov', 25, 50000),
('ABD', 'MF', 'Iskender Ryskulov', 26, 50000),
('ALY', 'MF', 'Marat Kozubekov', 24, 75000),
('ILB', 'MF', 'Adilet Bekturov', 20, 25000),
('TOK', 'MF', 'Nursultan Kadyrkulov', 23, 25000),
('NFK', 'MF', 'Ernis Sulaimanov', 24, 50000),
('OSM', 'MF', 'Dastan Ermatov', 22, 75000),
('KKB', 'MF', 'Temirlan Askarov', 21, 25000),
('MUR', 'FW', 'Joao Pereira', 27, 125000),
('ALG', 'FW', 'Azizbek Omuraliev', 23, 75000),
('BRS', 'FW', 'Bakyt Omurbekov', 26, 50000),
('OZG', 'FW', 'Manuel Silva', 28, 100000),
('BSC', 'FW', 'Amanbek Zholdoshov', 22, 50000),
('ASG', 'FW', 'Egor Titov', 24, 25000),
('DOR', 'FW', 'Talgat Umetaliev', 25, 100000),
('TAL', 'FW', 'Temirbek Akylov', 21, 25000),
('ABD', 'FW', 'Pavel Kireev', 26, 75000),
('ALY', 'FW', 'Sherali Rashidov', 27, 50000),
('ILB', 'FW', 'Islambek Niyazov', 22, 25000),
('TOK', 'FW', 'Giorgi Mchedlishvili', 29, 75000),
('NFK', 'FW', 'Raufkhon Karimov', 24, 50000),
('OSM', 'FW', 'Elnurbek Baatyrov', 23, 25000),
('KKB', 'FW', 'Ainur Aliev', 26, 50000);

INSERT INTO players (
    club_id, first_name, last_name, jersey_number, position, birth_date, nationality,
    height_cm, weight_kg, age_years, market_value_eur, photo_url, source_url, source_note, created_at
)
SELECT
    c.id,
    split_part(t.full_name, ' ', 1),
    TRIM(SUBSTRING(t.full_name FROM POSITION(' ' IN t.full_name) + 1)),
    NULL,
    t.position,
    NULL,
    NULL,
    NULL,
    NULL,
    t.age_years,
    t.market_value_eur,
    NULL,
    'https://www.transfermarkt.com/',
    'Fantasy demo expansion seed',
    TIMESTAMP '2026-03-01 09:05:00'
FROM tmp_fantasy_demo_players t
JOIN clubs c ON c.abbr = t.club_abbr
WHERE NOT EXISTS (
    SELECT 1
    FROM players p
    WHERE CONCAT(p.first_name, ' ', p.last_name) = t.full_name
);

UPDATE matches
SET
    home_goals = v.home_goals,
    away_goals = v.away_goals,
    status = 'FINISHED'
FROM (
    VALUES
        ('ALY', 'OSM', 1, 2),
        ('NFK', 'ASG', 2, 0),
        ('KKB', 'OZG', 1, 1)
) AS v(home_abbr, away_abbr, home_goals, away_goals)
JOIN seasons s ON s.year = 2026
JOIN clubs home_club ON home_club.abbr = v.home_abbr
JOIN clubs away_club ON away_club.abbr = v.away_abbr
WHERE matches.season_id = s.id
  AND matches.round_number = 2
  AND matches.home_club_id = home_club.id
  AND matches.away_club_id = away_club.id;

INSERT INTO matches (
    season_id, round_number, date_time, stadium, home_club_id, away_club_id,
    home_goals, away_goals, status, created_at
)
SELECT
    s.id,
    2,
    v.date_time,
    v.stadium,
    home_club.id,
    away_club.id,
    v.home_goals,
    v.away_goals,
    'FINISHED',
    TIMESTAMP '2026-03-15 08:00:00'
FROM (
    VALUES
        (TIMESTAMP '2026-03-14 20:00:00', 'Bishkek City Arena', 'BSC', 'ABD', 1, 0),
        (TIMESTAMP '2026-03-15 18:00:00', 'Muras Arena', 'MUR', 'ALG', 2, 2),
        (TIMESTAMP '2026-03-15 20:00:00', 'Dolen Omurzakov', 'DOR', 'ATL', 1, 0),
        (TIMESTAMP '2026-03-16 18:00:00', 'Toktogul Stadium', 'TOK', 'TAL', 0, 0),
        (TIMESTAMP '2026-03-16 20:00:00', 'Karakol Arena', 'BRS', 'ILB', 2, 1)
) AS v(date_time, stadium, home_abbr, away_abbr, home_goals, away_goals)
JOIN seasons s ON s.year = 2026
JOIN clubs home_club ON home_club.abbr = v.home_abbr
JOIN clubs away_club ON away_club.abbr = v.away_abbr
WHERE NOT EXISTS (
    SELECT 1
    FROM matches m
    WHERE m.season_id = s.id
      AND m.round_number = 2
      AND m.home_club_id = home_club.id
      AND m.away_club_id = away_club.id
);

INSERT INTO matches (
    season_id, round_number, date_time, stadium, home_club_id, away_club_id,
    home_goals, away_goals, status, created_at
)
SELECT
    s.id,
    3,
    v.date_time,
    v.stadium,
    home_club.id,
    away_club.id,
    NULL,
    NULL,
    'SCHEDULED',
    TIMESTAMP '2026-04-10 09:00:00'
FROM (
    VALUES
        (TIMESTAMP '2026-11-20 18:00:00', 'Alga Arena', 'ALG', 'DOR'),
        (TIMESTAMP '2026-11-20 20:00:00', 'Talas Stadium', 'ATL', 'TOK'),
        (TIMESTAMP '2026-11-21 18:00:00', 'Muras Arena', 'MUR', 'BSC'),
        (TIMESTAMP '2026-11-21 20:00:00', 'Ozgon Stadium', 'OZG', 'KKB'),
        (TIMESTAMP '2026-11-22 18:00:00', 'Asiagoal Arena', 'ASG', 'NFK'),
        (TIMESTAMP '2026-11-22 20:00:00', 'Kant Arena', 'ABD', 'ALY'),
        (TIMESTAMP '2026-11-23 18:00:00', 'Ilbirs Arena', 'ILB', 'BRS'),
        (TIMESTAMP '2026-11-23 20:00:00', 'OshMU Arena', 'OSM', 'TAL')
) AS v(date_time, stadium, home_abbr, away_abbr)
JOIN seasons s ON s.year = 2026
JOIN clubs home_club ON home_club.abbr = v.home_abbr
JOIN clubs away_club ON away_club.abbr = v.away_abbr
WHERE NOT EXISTS (
    SELECT 1
    FROM matches m
    WHERE m.season_id = s.id
      AND m.round_number = 3
      AND m.home_club_id = home_club.id
      AND m.away_club_id = away_club.id
);

INSERT INTO fantasy_player_prices (
    player_id, season_id, current_price, initial_price, price_source, last_updated_at
)
SELECT
    p.id,
    s.id,
    CASE p.position
        WHEN 'GK' THEN
            CASE
                WHEN p.market_value_eur IS NULL THEN 4.5
                ELSE ROUND(LEAST(4.5 + LEAST(p.market_value_eur::NUMERIC / 100000.0, 4.5), 12.0), 1)
            END
        WHEN 'DF' THEN
            CASE
                WHEN p.market_value_eur IS NULL THEN 5.0
                ELSE ROUND(LEAST(5.0 + LEAST(p.market_value_eur::NUMERIC / 100000.0, 4.5), 12.0), 1)
            END
        WHEN 'MF' THEN
            CASE
                WHEN p.market_value_eur IS NULL THEN 5.5
                ELSE ROUND(LEAST(5.5 + LEAST(p.market_value_eur::NUMERIC / 100000.0, 4.5), 12.0), 1)
            END
        WHEN 'FW' THEN
            CASE
                WHEN p.market_value_eur IS NULL THEN 6.0
                ELSE ROUND(LEAST(6.0 + LEAST(p.market_value_eur::NUMERIC / 100000.0, 4.5), 12.0), 1)
            END
    END,
    CASE p.position
        WHEN 'GK' THEN
            CASE
                WHEN p.market_value_eur IS NULL THEN 4.5
                ELSE ROUND(LEAST(4.5 + LEAST(p.market_value_eur::NUMERIC / 100000.0, 4.5), 12.0), 1)
            END
        WHEN 'DF' THEN
            CASE
                WHEN p.market_value_eur IS NULL THEN 5.0
                ELSE ROUND(LEAST(5.0 + LEAST(p.market_value_eur::NUMERIC / 100000.0, 4.5), 12.0), 1)
            END
        WHEN 'MF' THEN
            CASE
                WHEN p.market_value_eur IS NULL THEN 5.5
                ELSE ROUND(LEAST(5.5 + LEAST(p.market_value_eur::NUMERIC / 100000.0, 4.5), 12.0), 1)
            END
        WHEN 'FW' THEN
            CASE
                WHEN p.market_value_eur IS NULL THEN 6.0
                ELSE ROUND(LEAST(6.0 + LEAST(p.market_value_eur::NUMERIC / 100000.0, 4.5), 12.0), 1)
            END
    END,
    CASE
        WHEN p.market_value_eur IS NULL THEN 'POSITION_DEFAULT'
        ELSE 'MARKET_VALUE'
    END,
    TIMESTAMP '2026-03-10 12:00:00'
FROM players p
JOIN seasons s ON s.year = 2026
WHERE NOT EXISTS (
    SELECT 1
    FROM fantasy_player_prices fpp
    WHERE fpp.player_id = p.id
      AND fpp.season_id = s.id
);

CREATE TEMPORARY TABLE tmp_fantasy_demo_teams (
    email VARCHAR(255) NOT NULL,
    team_name VARCHAR(100) NOT NULL,
    captain_full_name VARCHAR(120) NOT NULL,
    vice_full_name VARCHAR(120) NOT NULL
);

INSERT INTO tmp_fantasy_demo_teams (email, team_name, captain_full_name, vice_full_name) VALUES
('askar.demo@kpfl.local', 'Nomad Legends', 'Ernis Sulaimanov', 'Kaiyr Nurmatov'),
('aidana.demo@kpfl.local', 'Issyk Attack', 'Azizbek Omuraliev', 'Ainur Aliev'),
('timur.demo@kpfl.local', 'Steppe Falcons', 'Adil Kadyrzhanov', 'Kaiyr Nurmatov');

INSERT INTO fantasy_teams (
    user_id, season_id, name, total_points, current_budget, active, created_at
)
SELECT
    u.id,
    s.id,
    t.team_name,
    0,
    100.0,
    TRUE,
    TIMESTAMP '2026-03-10 10:00:00'
FROM tmp_fantasy_demo_teams t
JOIN users u ON u.email = t.email
JOIN seasons s ON s.year = 2026
WHERE NOT EXISTS (
    SELECT 1
    FROM fantasy_teams ft
    WHERE ft.user_id = u.id
      AND ft.season_id = s.id
);

CREATE TEMPORARY TABLE tmp_fantasy_demo_squads (
    email VARCHAR(255) NOT NULL,
    player_full_name VARCHAR(120) NOT NULL
);

INSERT INTO tmp_fantasy_demo_squads (email, player_full_name) VALUES
('askar.demo@kpfl.local', 'Aziret Ysmanaliev'),
('askar.demo@kpfl.local', 'Uson Mamatkadyrov'),
('askar.demo@kpfl.local', 'Sergey Nozdrin'),
('askar.demo@kpfl.local', 'Insan Talantbek Uulu'),
('askar.demo@kpfl.local', 'Salim Mambetov'),
('askar.demo@kpfl.local', 'Mukhtar Ishenaliev'),
('askar.demo@kpfl.local', 'Ernar Erkebekov'),
('askar.demo@kpfl.local', 'Bekzat Sydykov'),
('askar.demo@kpfl.local', 'Kaiyr Nurmatov'),
('askar.demo@kpfl.local', 'Mirlan Satarov'),
('askar.demo@kpfl.local', 'Nursultan Kadyrkulov'),
('askar.demo@kpfl.local', 'Ernis Sulaimanov'),
('askar.demo@kpfl.local', 'Egor Titov'),
('askar.demo@kpfl.local', 'Temirbek Akylov'),
('askar.demo@kpfl.local', 'Elnurbek Baatyrov'),
('aidana.demo@kpfl.local', 'Sultan Chomoev'),
('aidana.demo@kpfl.local', 'Sarvar Mirzaev'),
('aidana.demo@kpfl.local', 'Ibrakhim Zhetimishev'),
('aidana.demo@kpfl.local', 'Ulanbek Sultanbekov'),
('aidana.demo@kpfl.local', 'Rauf Asinov'),
('aidana.demo@kpfl.local', 'Shakhsultan Jumabaev'),
('aidana.demo@kpfl.local', 'Asylbek Iskakov'),
('aidana.demo@kpfl.local', 'Aibek Tursunov'),
('aidana.demo@kpfl.local', 'Argen Osmonov'),
('aidana.demo@kpfl.local', 'Marat Kozubekov'),
('aidana.demo@kpfl.local', 'Adilet Bekturov'),
('aidana.demo@kpfl.local', 'Dastan Ermatov'),
('aidana.demo@kpfl.local', 'Azizbek Omuraliev'),
('aidana.demo@kpfl.local', 'Pavel Kireev'),
('aidana.demo@kpfl.local', 'Ainur Aliev'),
('timur.demo@kpfl.local', 'Artur Ismanbekov'),
('timur.demo@kpfl.local', 'Nursultan Nusupov'),
('timur.demo@kpfl.local', 'Emir-Khan Kydyrshaev'),
('timur.demo@kpfl.local', 'Vladislav Mikushin'),
('timur.demo@kpfl.local', 'Adilet Nurlan uulu'),
('timur.demo@kpfl.local', 'Mederbek Kudud'),
('timur.demo@kpfl.local', 'Daniyar Ergeshov'),
('timur.demo@kpfl.local', 'Adil Kadyrzhanov'),
('timur.demo@kpfl.local', 'Demur Chikhladze'),
('timur.demo@kpfl.local', 'Iskender Ryskulov'),
('timur.demo@kpfl.local', 'Temirlan Askarov'),
('timur.demo@kpfl.local', 'Kaiyr Nurmatov'),
('timur.demo@kpfl.local', 'Mykola Agapov'),
('timur.demo@kpfl.local', 'Talgat Umetaliev'),
('timur.demo@kpfl.local', 'Raufkhon Karimov');

INSERT INTO fantasy_team_players (
    fantasy_team_id, player_id, acquired_price, acquired_round, sold_round, active, created_at
)
SELECT
    ft.id,
    p.id,
    fpp.current_price,
    1,
    NULL,
    TRUE,
    TIMESTAMP '2026-03-10 10:30:00'
FROM tmp_fantasy_demo_squads s
JOIN users u ON u.email = s.email
JOIN seasons season_current ON season_current.year = 2026
JOIN fantasy_teams ft ON ft.user_id = u.id AND ft.season_id = season_current.id
JOIN players p ON CONCAT(p.first_name, ' ', p.last_name) = s.player_full_name
JOIN fantasy_player_prices fpp ON fpp.player_id = p.id AND fpp.season_id = season_current.id
WHERE NOT EXISTS (
    SELECT 1
    FROM fantasy_team_players ftp
    WHERE ftp.fantasy_team_id = ft.id
      AND ftp.player_id = p.id
      AND ftp.active = TRUE
);

UPDATE fantasy_teams ft
SET current_budget = ROUND(
    100.0 - COALESCE((
        SELECT SUM(ftp.acquired_price)
        FROM fantasy_team_players ftp
        WHERE ftp.fantasy_team_id = ft.id
          AND ftp.active = TRUE
    ), 0),
    1
)
FROM seasons s
WHERE ft.season_id = s.id
  AND s.year = 2026
  AND ft.user_id IN (
      SELECT u.id
      FROM users u
      WHERE u.email IN ('askar.demo@kpfl.local', 'aidana.demo@kpfl.local', 'timur.demo@kpfl.local')
  );

INSERT INTO fantasy_leagues (
    season_id, owner_user_id, name, code, is_private, created_at
)
SELECT
    s.id,
    u.id,
    'KPFL Demo League',
    'DEMO2026',
    TRUE,
    TIMESTAMP '2026-03-10 11:00:00'
FROM seasons s
JOIN users u ON u.email = 'askar.demo@kpfl.local'
WHERE s.year = 2026
  AND NOT EXISTS (
      SELECT 1
      FROM fantasy_leagues fl
      WHERE fl.code = 'DEMO2026'
  );

INSERT INTO fantasy_league_members (
    fantasy_league_id, fantasy_team_id, joined_at
)
SELECT
    fl.id,
    ft.id,
    TIMESTAMP '2026-03-10 11:05:00'
FROM fantasy_leagues fl
JOIN seasons s ON s.id = fl.season_id AND s.year = 2026
JOIN users u ON u.email IN ('askar.demo@kpfl.local', 'aidana.demo@kpfl.local', 'timur.demo@kpfl.local')
JOIN fantasy_teams ft ON ft.user_id = u.id AND ft.season_id = s.id
WHERE fl.code = 'DEMO2026'
  AND NOT EXISTS (
      SELECT 1
      FROM fantasy_league_members flm
      WHERE flm.fantasy_league_id = fl.id
        AND flm.fantasy_team_id = ft.id
  );

CREATE TEMPORARY TABLE tmp_fantasy_demo_lineup (
    email VARCHAR(255) NOT NULL,
    player_full_name VARCHAR(120) NOT NULL,
    starter BOOLEAN NOT NULL,
    slot_order INT NOT NULL
);

INSERT INTO tmp_fantasy_demo_lineup (email, player_full_name, starter, slot_order) VALUES
('askar.demo@kpfl.local', 'Aziret Ysmanaliev', TRUE, 1),
('askar.demo@kpfl.local', 'Sergey Nozdrin', TRUE, 2),
('askar.demo@kpfl.local', 'Insan Talantbek Uulu', TRUE, 3),
('askar.demo@kpfl.local', 'Salim Mambetov', TRUE, 4),
('askar.demo@kpfl.local', 'Bekzat Sydykov', TRUE, 5),
('askar.demo@kpfl.local', 'Kaiyr Nurmatov', TRUE, 6),
('askar.demo@kpfl.local', 'Mirlan Satarov', TRUE, 7),
('askar.demo@kpfl.local', 'Ernis Sulaimanov', TRUE, 8),
('askar.demo@kpfl.local', 'Egor Titov', TRUE, 9),
('askar.demo@kpfl.local', 'Temirbek Akylov', TRUE, 10),
('askar.demo@kpfl.local', 'Elnurbek Baatyrov', TRUE, 11),
('askar.demo@kpfl.local', 'Uson Mamatkadyrov', FALSE, 1),
('askar.demo@kpfl.local', 'Mukhtar Ishenaliev', FALSE, 2),
('askar.demo@kpfl.local', 'Ernar Erkebekov', FALSE, 3),
('askar.demo@kpfl.local', 'Nursultan Kadyrkulov', FALSE, 4),
('aidana.demo@kpfl.local', 'Sultan Chomoev', TRUE, 1),
('aidana.demo@kpfl.local', 'Ibrakhim Zhetimishev', TRUE, 2),
('aidana.demo@kpfl.local', 'Ulanbek Sultanbekov', TRUE, 3),
('aidana.demo@kpfl.local', 'Rauf Asinov', TRUE, 4),
('aidana.demo@kpfl.local', 'Aibek Tursunov', TRUE, 5),
('aidana.demo@kpfl.local', 'Argen Osmonov', TRUE, 6),
('aidana.demo@kpfl.local', 'Marat Kozubekov', TRUE, 7),
('aidana.demo@kpfl.local', 'Dastan Ermatov', TRUE, 8),
('aidana.demo@kpfl.local', 'Azizbek Omuraliev', TRUE, 9),
('aidana.demo@kpfl.local', 'Pavel Kireev', TRUE, 10),
('aidana.demo@kpfl.local', 'Ainur Aliev', TRUE, 11),
('aidana.demo@kpfl.local', 'Sarvar Mirzaev', FALSE, 1),
('aidana.demo@kpfl.local', 'Shakhsultan Jumabaev', FALSE, 2),
('aidana.demo@kpfl.local', 'Asylbek Iskakov', FALSE, 3),
('aidana.demo@kpfl.local', 'Adilet Bekturov', FALSE, 4),
('timur.demo@kpfl.local', 'Nursultan Nusupov', TRUE, 1),
('timur.demo@kpfl.local', 'Emir-Khan Kydyrshaev', TRUE, 2),
('timur.demo@kpfl.local', 'Vladislav Mikushin', TRUE, 3),
('timur.demo@kpfl.local', 'Adilet Nurlan uulu', TRUE, 4),
('timur.demo@kpfl.local', 'Adil Kadyrzhanov', TRUE, 5),
('timur.demo@kpfl.local', 'Demur Chikhladze', TRUE, 6),
('timur.demo@kpfl.local', 'Iskender Ryskulov', TRUE, 7),
('timur.demo@kpfl.local', 'Kaiyr Nurmatov', TRUE, 8),
('timur.demo@kpfl.local', 'Mykola Agapov', TRUE, 9),
('timur.demo@kpfl.local', 'Talgat Umetaliev', TRUE, 10),
('timur.demo@kpfl.local', 'Raufkhon Karimov', TRUE, 11),
('timur.demo@kpfl.local', 'Artur Ismanbekov', FALSE, 1),
('timur.demo@kpfl.local', 'Mederbek Kudud', FALSE, 2),
('timur.demo@kpfl.local', 'Daniyar Ergeshov', FALSE, 3),
('timur.demo@kpfl.local', 'Temirlan Askarov', FALSE, 4);

INSERT INTO fantasy_team_round_selections (
    fantasy_team_id, season_id, round_number, locked_at, finalized,
    captain_player_id, vice_captain_player_id, created_at, updated_at
)
SELECT
    ft.id,
    s.id,
    2,
    (SELECT MIN(m.date_time) FROM matches m WHERE m.season_id = s.id AND m.round_number = 2),
    TRUE,
    captain.id,
    vice.id,
    TIMESTAMP '2026-03-12 10:00:00',
    TIMESTAMP '2026-03-16 22:30:00'
FROM tmp_fantasy_demo_teams demo_team
JOIN users u ON u.email = demo_team.email
JOIN seasons s ON s.year = 2026
JOIN fantasy_teams ft ON ft.user_id = u.id AND ft.season_id = s.id
JOIN players captain ON CONCAT(captain.first_name, ' ', captain.last_name) = demo_team.captain_full_name
JOIN players vice ON CONCAT(vice.first_name, ' ', vice.last_name) = demo_team.vice_full_name
WHERE NOT EXISTS (
    SELECT 1
    FROM fantasy_team_round_selections selection_existing
    WHERE selection_existing.fantasy_team_id = ft.id
      AND selection_existing.season_id = s.id
      AND selection_existing.round_number = 2
);

INSERT INTO fantasy_lineup_entries (
    round_selection_id, player_id, starter, starter_order, bench_order, created_at
)
SELECT
    selection_round2.id,
    p.id,
    lineup.starter,
    CASE WHEN lineup.starter THEN lineup.slot_order ELSE NULL END,
    CASE WHEN lineup.starter THEN NULL ELSE lineup.slot_order END,
    TIMESTAMP '2026-03-12 10:05:00'
FROM tmp_fantasy_demo_lineup lineup
JOIN users u ON u.email = lineup.email
JOIN seasons s ON s.year = 2026
JOIN fantasy_teams ft ON ft.user_id = u.id AND ft.season_id = s.id
JOIN fantasy_team_round_selections selection_round2
    ON selection_round2.fantasy_team_id = ft.id
   AND selection_round2.season_id = s.id
   AND selection_round2.round_number = 2
JOIN players p ON CONCAT(p.first_name, ' ', p.last_name) = lineup.player_full_name
WHERE NOT EXISTS (
    SELECT 1
    FROM fantasy_lineup_entries existing_entry
    WHERE existing_entry.round_selection_id = selection_round2.id
      AND existing_entry.player_id = p.id
);

INSERT INTO fantasy_team_round_selections (
    fantasy_team_id, season_id, round_number, locked_at, finalized,
    captain_player_id, vice_captain_player_id, created_at, updated_at
)
SELECT
    selection_round2.fantasy_team_id,
    selection_round2.season_id,
    3,
    (SELECT MIN(m.date_time) FROM matches m WHERE m.season_id = selection_round2.season_id AND m.round_number = 3),
    FALSE,
    selection_round2.captain_player_id,
    selection_round2.vice_captain_player_id,
    TIMESTAMP '2026-04-10 09:15:00',
    TIMESTAMP '2026-04-10 09:15:00'
FROM fantasy_team_round_selections selection_round2
JOIN seasons s ON s.id = selection_round2.season_id AND s.year = 2026
JOIN fantasy_teams ft ON ft.id = selection_round2.fantasy_team_id
JOIN users u ON u.id = ft.user_id
WHERE selection_round2.round_number = 2
  AND u.email IN ('askar.demo@kpfl.local', 'aidana.demo@kpfl.local', 'timur.demo@kpfl.local')
  AND NOT EXISTS (
      SELECT 1
      FROM fantasy_team_round_selections selection_round3
      WHERE selection_round3.fantasy_team_id = selection_round2.fantasy_team_id
        AND selection_round3.season_id = selection_round2.season_id
        AND selection_round3.round_number = 3
  );

INSERT INTO fantasy_lineup_entries (
    round_selection_id, player_id, starter, starter_order, bench_order, created_at
)
SELECT
    selection_round3.id,
    entry.player_id,
    entry.starter,
    entry.starter_order,
    entry.bench_order,
    TIMESTAMP '2026-04-10 09:20:00'
FROM fantasy_team_round_selections selection_round2
JOIN fantasy_team_round_selections selection_round3
    ON selection_round3.fantasy_team_id = selection_round2.fantasy_team_id
   AND selection_round3.season_id = selection_round2.season_id
   AND selection_round3.round_number = 3
JOIN fantasy_lineup_entries entry ON entry.round_selection_id = selection_round2.id
WHERE selection_round2.round_number = 2
  AND NOT EXISTS (
      SELECT 1
      FROM fantasy_lineup_entries existing_entry
      WHERE existing_entry.round_selection_id = selection_round3.id
        AND existing_entry.player_id = entry.player_id
  );

CREATE TEMPORARY TABLE tmp_fantasy_demo_round2_stats (
    club_abbr VARCHAR(10) NOT NULL,
    player_full_name VARCHAR(120) NOT NULL,
    minutes_played INT NOT NULL,
    goals INT NOT NULL DEFAULT 0,
    assists INT NOT NULL DEFAULT 0,
    clean_sheet BOOLEAN NOT NULL DEFAULT FALSE,
    goals_conceded INT NOT NULL DEFAULT 0,
    yellow_cards INT NOT NULL DEFAULT 0,
    red_cards INT NOT NULL DEFAULT 0,
    own_goals INT NOT NULL DEFAULT 0,
    penalties_saved INT NOT NULL DEFAULT 0,
    penalties_missed INT NOT NULL DEFAULT 0,
    saves INT NOT NULL DEFAULT 0
);

INSERT INTO tmp_fantasy_demo_round2_stats (
    club_abbr, player_full_name, minutes_played, goals, assists, clean_sheet, goals_conceded,
    yellow_cards, red_cards, own_goals, penalties_saved, penalties_missed, saves
) VALUES
('MUR', 'Aziret Ysmanaliev', 90, 0, 0, FALSE, 2, 0, 0, 0, 0, 0, 4),
('MUR', 'Sergey Nozdrin', 90, 0, 0, FALSE, 2, 0, 0, 0, 0, 0, 0),
('MUR', 'Bekzat Sydykov', 90, 1, 0, FALSE, 0, 0, 0, 0, 0, 0, 0),
('MUR', 'Emir-Khan Kydyrshaev', 90, 0, 0, FALSE, 2, 0, 0, 0, 0, 0, 0),
('ALG', 'Sultan Chomoev', 90, 0, 0, FALSE, 2, 0, 0, 0, 0, 0, 4),
('ALG', 'Insan Talantbek Uulu', 90, 0, 0, FALSE, 2, 0, 0, 0, 0, 0, 0),
('ALG', 'Kaiyr Nurmatov', 90, 1, 0, FALSE, 0, 0, 0, 0, 0, 0, 0),
('ALG', 'Azizbek Omuraliev', 90, 1, 0, FALSE, 0, 0, 0, 0, 0, 0, 0),
('DOR', 'Salim Mambetov', 90, 0, 0, TRUE, 0, 0, 0, 0, 0, 0, 0),
('DOR', 'Adil Kadyrzhanov', 90, 1, 0, TRUE, 0, 0, 0, 0, 0, 0, 0),
('DOR', 'Talgat Umetaliev', 90, 0, 1, FALSE, 0, 0, 0, 0, 0, 0, 0),
('BSC', 'Mirlan Satarov', 90, 0, 1, FALSE, 0, 0, 0, 0, 0, 0, 0),
('BSC', 'Ulanbek Sultanbekov', 90, 0, 0, TRUE, 0, 0, 0, 0, 0, 0, 0),
('BSC', 'Vladislav Mikushin', 90, 0, 0, TRUE, 0, 0, 0, 0, 0, 0, 0),
('NFK', 'Ernis Sulaimanov', 90, 1, 1, TRUE, 0, 0, 0, 0, 0, 0, 0),
('NFK', 'Raufkhon Karimov', 90, 0, 1, FALSE, 0, 0, 0, 0, 0, 0, 0),
('ASG', 'Egor Titov', 90, 0, 0, FALSE, 2, 0, 0, 0, 0, 0, 0),
('ASG', 'Aibek Tursunov', 90, 0, 0, FALSE, 2, 0, 0, 0, 0, 0, 0),
('ASG', 'Adilet Nurlan uulu', 90, 0, 0, FALSE, 2, 0, 0, 0, 0, 0, 0),
('TAL', 'Temirbek Akylov', 90, 0, 0, FALSE, 0, 0, 0, 0, 0, 0, 0),
('OSM', 'Elnurbek Baatyrov', 90, 1, 0, FALSE, 1, 0, 0, 0, 0, 0, 0),
('OSM', 'Dastan Ermatov', 90, 0, 1, FALSE, 1, 0, 0, 0, 0, 0, 0),
('OZG', 'Ibrakhim Zhetimishev', 90, 0, 0, FALSE, 1, 0, 0, 0, 0, 0, 0),
('OZG', 'Argen Osmonov', 90, 0, 1, FALSE, 1, 0, 0, 0, 0, 0, 0),
('ABD', 'Rauf Asinov', 90, 0, 0, FALSE, 1, 0, 0, 0, 0, 0, 0),
('ABD', 'Iskender Ryskulov', 90, 0, 0, FALSE, 1, 0, 0, 0, 0, 0, 0),
('ABD', 'Pavel Kireev', 90, 0, 0, FALSE, 1, 0, 0, 0, 0, 0, 0),
('ALY', 'Marat Kozubekov', 90, 1, 0, FALSE, 0, 0, 0, 0, 0, 0, 0),
('KKB', 'Ainur Aliev', 90, 1, 0, FALSE, 0, 0, 0, 0, 0, 0, 0),
('KKB', 'Nursultan Nusupov', 90, 0, 0, FALSE, 1, 0, 0, 0, 0, 0, 0),
('ATL', 'Demur Chikhladze', 90, 0, 0, FALSE, 1, 0, 0, 0, 0, 0, 0),
('ATL', 'Mykola Agapov', 90, 0, 0, FALSE, 1, 0, 0, 0, 0, 0, 0);

INSERT INTO fantasy_player_match_stats (
    player_id, match_id, minutes_played, goals, assists, clean_sheet, goals_conceded,
    yellow_cards, red_cards, own_goals, penalties_saved, penalties_missed, saves,
    started, substituted_in, substituted_out, created_at, updated_at
)
SELECT
    p.id,
    m.id,
    stat.minutes_played,
    stat.goals,
    stat.assists,
    stat.clean_sheet,
    stat.goals_conceded,
    stat.yellow_cards,
    stat.red_cards,
    stat.own_goals,
    stat.penalties_saved,
    stat.penalties_missed,
    stat.saves,
    TRUE,
    FALSE,
    FALSE,
    TIMESTAMP '2026-03-16 22:35:00',
    TIMESTAMP '2026-03-16 22:35:00'
FROM tmp_fantasy_demo_round2_stats stat
JOIN clubs c ON c.abbr = stat.club_abbr
JOIN players p ON p.club_id = c.id AND CONCAT(p.first_name, ' ', p.last_name) = stat.player_full_name
JOIN seasons s ON s.year = 2026
JOIN matches m ON m.season_id = s.id
              AND m.round_number = 2
              AND (m.home_club_id = c.id OR m.away_club_id = c.id)
WHERE NOT EXISTS (
    SELECT 1
    FROM fantasy_player_match_stats existing_stat
    WHERE existing_stat.player_id = p.id
      AND existing_stat.match_id = m.id
);

WITH stats_by_player AS (
    SELECT
        p.id AS player_id,
        SUM(
            CASE
                WHEN stat.minutes_played > 0 AND stat.minutes_played < 60 THEN 1
                WHEN stat.minutes_played >= 60 THEN 2
                ELSE 0
            END
            + (stat.goals * CASE p.position
                WHEN 'GK' THEN 10
                WHEN 'DF' THEN 6
                WHEN 'MF' THEN 5
                WHEN 'FW' THEN 4
            END)
            + (stat.assists * 3)
            + CASE
                WHEN stat.clean_sheet = TRUE AND stat.minutes_played >= 60 THEN
                    CASE p.position
                        WHEN 'GK' THEN 4
                        WHEN 'DF' THEN 4
                        WHEN 'MF' THEN 1
                        WHEN 'FW' THEN 0
                    END
                ELSE 0
            END
            - CASE
                WHEN p.position IN ('GK', 'DF') THEN FLOOR(stat.goals_conceded / 2.0)
                ELSE 0
            END
            - stat.yellow_cards
            - (stat.red_cards * 3)
            - (stat.own_goals * 2)
            - (stat.penalties_missed * 2)
            + CASE
                WHEN p.position = 'GK' THEN (stat.penalties_saved * 5) + FLOOR(stat.saves / 3.0)
                ELSE 0
            END
        )::INT AS raw_points,
        SUM(stat.minutes_played)::INT AS minutes_played
    FROM fantasy_player_match_stats stat
    JOIN players p ON p.id = stat.player_id
    JOIN matches m ON m.id = stat.match_id
    JOIN seasons s ON s.id = m.season_id
    WHERE s.year = 2026
      AND m.round_number = 2
    GROUP BY p.id
)
INSERT INTO fantasy_player_round_points (
    fantasy_team_id, season_id, round_number, player_id, raw_points, applied_points,
    starter, captain_applied, vice_captain_applied, auto_sub_applied, explanation
)
SELECT
    selection_round2.fantasy_team_id,
    selection_round2.season_id,
    2,
    lineup_entry.player_id,
    COALESCE(stats_by_player.raw_points, 0),
    CASE
        WHEN lineup_entry.starter = TRUE
         AND lineup_entry.player_id = selection_round2.captain_player_id
         AND COALESCE(stats_by_player.minutes_played, 0) > 0
            THEN COALESCE(stats_by_player.raw_points, 0) * 2
        WHEN lineup_entry.starter = TRUE
            THEN COALESCE(stats_by_player.raw_points, 0)
        ELSE 0
    END,
    lineup_entry.starter,
    (lineup_entry.starter = TRUE
        AND lineup_entry.player_id = selection_round2.captain_player_id
        AND COALESCE(stats_by_player.minutes_played, 0) > 0),
    FALSE,
    FALSE,
    CASE
        WHEN lineup_entry.starter = TRUE
         AND lineup_entry.player_id = selection_round2.captain_player_id
         AND COALESCE(stats_by_player.minutes_played, 0) > 0
            THEN 'Counted in final XI; Captain points doubled'
        WHEN lineup_entry.starter = TRUE
            THEN 'Counted in final XI'
        ELSE 'Bench points not applied'
    END
FROM fantasy_team_round_selections selection_round2
JOIN seasons s ON s.id = selection_round2.season_id AND s.year = 2026
JOIN fantasy_teams ft ON ft.id = selection_round2.fantasy_team_id
JOIN users u ON u.id = ft.user_id
JOIN fantasy_lineup_entries lineup_entry ON lineup_entry.round_selection_id = selection_round2.id
LEFT JOIN stats_by_player ON stats_by_player.player_id = lineup_entry.player_id
WHERE selection_round2.round_number = 2
  AND u.email IN ('askar.demo@kpfl.local', 'aidana.demo@kpfl.local', 'timur.demo@kpfl.local')
  AND NOT EXISTS (
      SELECT 1
      FROM fantasy_player_round_points existing_points
      WHERE existing_points.fantasy_team_id = selection_round2.fantasy_team_id
        AND existing_points.season_id = selection_round2.season_id
        AND existing_points.round_number = 2
        AND existing_points.player_id = lineup_entry.player_id
  );

WITH round_totals AS (
    SELECT
        points.fantasy_team_id,
        points.season_id,
        points.round_number,
        SUM(points.applied_points) AS total_points
    FROM fantasy_player_round_points points
    JOIN fantasy_teams ft ON ft.id = points.fantasy_team_id
    JOIN users u ON u.id = ft.user_id
    JOIN seasons s ON s.id = points.season_id
    WHERE s.year = 2026
      AND points.round_number = 2
      AND u.email IN ('askar.demo@kpfl.local', 'aidana.demo@kpfl.local', 'timur.demo@kpfl.local')
    GROUP BY points.fantasy_team_id, points.season_id, points.round_number
),
ranked_totals AS (
    SELECT
        round_totals.*,
        ROW_NUMBER() OVER (
            ORDER BY round_totals.total_points DESC, ft.name ASC
        ) AS rank_snapshot
    FROM round_totals
    JOIN fantasy_teams ft ON ft.id = round_totals.fantasy_team_id
)
INSERT INTO fantasy_team_round_scores (
    fantasy_team_id, season_id, round_number, points, transfer_penalty, final_points, rank_snapshot, calculated_at
)
SELECT
    ranked_totals.fantasy_team_id,
    ranked_totals.season_id,
    ranked_totals.round_number,
    ranked_totals.total_points,
    0,
    ranked_totals.total_points,
    ranked_totals.rank_snapshot,
    TIMESTAMP '2026-03-16 22:40:00'
FROM ranked_totals
WHERE NOT EXISTS (
    SELECT 1
    FROM fantasy_team_round_scores existing_score
    WHERE existing_score.fantasy_team_id = ranked_totals.fantasy_team_id
      AND existing_score.season_id = ranked_totals.season_id
      AND existing_score.round_number = ranked_totals.round_number
);

UPDATE fantasy_teams ft
SET total_points = scored.total_points
FROM (
    SELECT
        score.fantasy_team_id,
        SUM(score.final_points) AS total_points
    FROM fantasy_team_round_scores score
    JOIN seasons s ON s.id = score.season_id
    WHERE s.year = 2026
    GROUP BY score.fantasy_team_id
) scored
WHERE ft.id = scored.fantasy_team_id
  AND ft.user_id IN (
      SELECT u.id
      FROM users u
      WHERE u.email IN ('askar.demo@kpfl.local', 'aidana.demo@kpfl.local', 'timur.demo@kpfl.local')
  );

DROP TABLE IF EXISTS tmp_fantasy_demo_round2_stats;
DROP TABLE IF EXISTS tmp_fantasy_demo_lineup;
DROP TABLE IF EXISTS tmp_fantasy_demo_squads;
DROP TABLE IF EXISTS tmp_fantasy_demo_teams;
DROP TABLE IF EXISTS tmp_fantasy_demo_players;
