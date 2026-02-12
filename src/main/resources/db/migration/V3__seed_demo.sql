-- V3: demo seed

INSERT INTO seasons (year, name, start_date, end_date)
VALUES (2026, 'KPFL 2026', '2026-03-01', '2026-11-30');

-- 14 клубов (пока заглушки, ты заменишь на реальные)
INSERT INTO clubs (name, abbr, city, stadium, founded_year, primary_color, logo_url) VALUES
                                                                                         ('Club 1', 'C1', 'Bishkek', 'Stadium 1', 1990, '#111111', NULL),
                                                                                         ('Club 2', 'C2', 'Bishkek', 'Stadium 2', 1991, '#222222', NULL),
                                                                                         ('Club 3', 'C3', 'Osh',     'Stadium 3', 1992, '#333333', NULL),
                                                                                         ('Club 4', 'C4', 'Osh',     'Stadium 4', 1993, '#444444', NULL),
                                                                                         ('Club 5', 'C5', 'Karakol', 'Stadium 5', 1994, '#555555', NULL),
                                                                                         ('Club 6', 'C6', 'Tokmok',  'Stadium 6', 1995, '#666666', NULL),
                                                                                         ('Club 7', 'C7', 'Jalal-Abad','Stadium 7',1996, '#777777', NULL),
                                                                                         ('Club 8', 'C8', 'Naryn',   'Stadium 8', 1997, '#888888', NULL),
                                                                                         ('Club 9', 'C9', 'Talas',   'Stadium 9', 1998, '#999999', NULL),
                                                                                         ('Club 10','C10','Batken',  'Stadium 10',1999, '#AAAAAA', NULL),
                                                                                         ('Club 11','C11','Bishkek', 'Stadium 11',2000, '#BBBBBB', NULL),
                                                                                         ('Club 12','C12','Osh',     'Stadium 12',2001, '#CCCCCC', NULL),
                                                                                         ('Club 13','C13','Kant',    'Stadium 13',2002, '#DDDDDD', NULL),
                                                                                         ('Club 14','C14','Kemin',   'Stadium 14',2003, '#EEEEEE', NULL);

-- игроки (по 2 на клуб для примера; потом расширишь до 5-10)
INSERT INTO players (club_id, first_name, last_name, number, position, birth_date, nationality, height_cm, weight_kg) VALUES
                                                                                                                          (1, 'Aibek', 'Player1',  1, 'GK', '2000-01-10', 'KG', 188, 82),
                                                                                                                          (1, 'Ermek', 'Player2', 10, 'FW', '2002-06-21', 'KG', 178, 72),
                                                                                                                          (2, 'Timur', 'Player3',  1, 'GK', '1999-03-11', 'KG', 190, 85),
                                                                                                                          (2, 'Daniyar','Player4', 9, 'FW', '2001-09-02', 'KG', 180, 74);

-- матчи (часть finished, часть scheduled)
-- season_id = 1 (первый вставленный сезон)
INSERT INTO matches (season_id, round_number, date_time, stadium, home_club_id, away_club_id, home_goals, away_goals, status) VALUES
                                                                                                                                  (1, 1, '2026-03-05 18:00:00', 'Stadium 1', 1, 2, 2, 1, 'FINISHED'),
                                                                                                                                  (1, 1, '2026-03-06 18:00:00', 'Stadium 3', 3, 4, NULL, NULL, 'SCHEDULED');

-- новости
INSERT INTO news (title, short_text, tag, published_at, related_club_id, related_player_id) VALUES
                                                                                                ('Season kickoff', 'KPFL 2026 season starts soon.', 'league', '2026-02-10 12:00:00', NULL, NULL),
                                                                                                ('Matchday 1 preview', 'First round matches are scheduled this week.', 'matches', '2026-02-11 15:00:00', 1, NULL);

-- админ (пароль пока как строка-заглушка, ниже объясню)
INSERT INTO users (email, password_hash, role)
VALUES ('admin@kpfl.local', '{noop}admin', 'ADMIN');