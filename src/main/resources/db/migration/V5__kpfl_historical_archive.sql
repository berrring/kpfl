CREATE TABLE kpfl_champion_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    season_year INT NOT NULL,
    champion VARCHAR(120) NOT NULL,
    champion_title_no INT NULL,
    runner_up VARCHAR(120) NULL,
    third_place VARCHAR(120) NULL,
    top_scorer VARCHAR(120) NULL,
    top_scorer_goals INT NULL,
    top_scorer_club VARCHAR(120) NULL,
    player_of_year VARCHAR(120) NULL,
    notes VARCHAR(255) NULL,
    CONSTRAINT uk_kpfl_champion_history_year UNIQUE (season_year)
);

CREATE TABLE kpfl_club_honours (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    club_name VARCHAR(120) NOT NULL,
    titles INT NOT NULL DEFAULT 0,
    runner_up_count INT NOT NULL DEFAULT 0,
    third_place_count INT NOT NULL DEFAULT 0,
    championship_years VARCHAR(500) NULL,
    CONSTRAINT uk_kpfl_club_honours_name UNIQUE (club_name)
);

CREATE TABLE kpfl_season_standings_archive (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    season_year INT NOT NULL,
    place_no INT NOT NULL,
    club_name VARCHAR(120) NOT NULL,
    played INT NOT NULL,
    wins INT NOT NULL,
    draws INT NOT NULL,
    losses INT NOT NULL,
    goals_for INT NOT NULL,
    goals_against INT NOT NULL,
    goal_difference INT NOT NULL,
    points INT NOT NULL,
    matches_total INT NULL,
    CONSTRAINT uk_kpfl_season_standings UNIQUE (season_year, place_no)
);

CREATE TABLE kpfl_league_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    record_key VARCHAR(120) NOT NULL,
    record_value VARCHAR(500) NOT NULL,
    source_note VARCHAR(255) NULL,
    CONSTRAINT uk_kpfl_league_records_key UNIQUE (record_key)
);

CREATE TABLE kpfl_top_scorers_all_time (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rank_no INT NOT NULL,
    player_name VARCHAR(120) NOT NULL,
    position_name VARCHAR(60) NULL,
    goals INT NOT NULL,
    matches_played INT NOT NULL,
    goals_per_match DECIMAL(5,2) NOT NULL,
    source_note VARCHAR(255) NULL,
    CONSTRAINT uk_kpfl_top_scorers_rank UNIQUE (rank_no)
);

CREATE TABLE kpfl_top_appearances_all_time (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    rank_no INT NOT NULL,
    player_name VARCHAR(120) NOT NULL,
    position_name VARCHAR(60) NULL,
    matches_played INT NOT NULL,
    goals INT NOT NULL,
    source_note VARCHAR(255) NULL,
    CONSTRAINT uk_kpfl_top_appearances_rank UNIQUE (rank_no)
);

CREATE INDEX ix_kpfl_champion_history_champion ON kpfl_champion_history(champion);
CREATE INDEX ix_kpfl_season_standings_year ON kpfl_season_standings_archive(season_year);
CREATE INDEX ix_kpfl_top_scorers_goals ON kpfl_top_scorers_all_time(goals);
CREATE INDEX ix_kpfl_top_appearances_matches ON kpfl_top_appearances_all_time(matches_played);

INSERT INTO kpfl_champion_history (
    season_year, champion, champion_title_no, runner_up, third_place,
    top_scorer, top_scorer_goals, top_scorer_club, player_of_year, notes
) VALUES
(1992, 'Alga Bishkek', 1, 'SKA Dostuk Sokuluk', 'Alay Osh', 'Igor Sergeev', 26, 'SKA Dostuk Sokuluk', NULL, NULL),
(1993, 'Alga-RIIF Bishkek', 2, 'Spartak Tokmak', 'Alay Osh', 'Davron Babaev', 38, 'Dinamo Alay Osh', NULL, NULL),
(1994, 'Kant-Oyl Kant', 1, 'Semetey Kyzyl-Kiya', 'Ak-Maral Tokmak', 'Alexander Merzlikin', 25, 'Kant-Oyl Kant', NULL, NULL),
(1995, 'Kant-Oyl Kant', 2, 'AiK Bishkek', 'Semetey Kyzyl-Kiya', 'Alexander Merzlikin', 27, 'Kant-Oyl Kant', NULL, NULL),
(1996, 'Metallurg Kadamjay', 1, 'AiK Bishkek', 'Dinamo Alay Osh', 'Alexander Merzlikin', 17, 'AiK Bishkek', NULL, NULL),
(1997, 'Dinamo Bishkek', 1, 'Alga-PVO Bishkek', 'AiK Bishkek', 'Farkhat Khaitbaev', 17, 'KVT Dinamo Kara-Balta', NULL, NULL),
(1998, 'CAG-Dinamo-MVD Bishkek', 2, 'SKA-PVO Bishkek', 'Natsionalnaya Gvardiya Bishkek', 'Sergey Gayzitdinov', 23, 'Semetey Kyzyl-Kiya', NULL, NULL),
(1999, 'Dinamo Bishkek', 3, 'SKA-PVO Bishkek', 'Jashtyk Ak-Altyn Kara-Suu', 'Ismail Malikov', 16, 'Jashtyk Ak-Altyn Kara-Suu', NULL, NULL),
(2000, 'SKA-PVO Bishkek', 3, 'Dinamo Bishkek', 'Polet Bishkek', 'Valeriy Berezovsky', 32, 'SKA-PVO Bishkek', NULL, NULL),
(2001, 'SKA-PVO Bishkek', 4, 'Jashtyk Ak-Altyn Kara-Suu', 'Dordoy Naryn', 'Nurlan Radjabaliev', 28, 'Jashtyk Ak-Altyn Kara-Suu', NULL, NULL),
(2002, 'SKA-PVO Bishkek', 5, 'Jashtyk Ak-Altyn Kara-Suu', 'Dordoy Naryn', 'Evgeniy Boldygin', 19, 'Jashtyk Ak-Altyn Kara-Suu', NULL, NULL),
(2003, 'Jashtyk Ak-Altyn Kara-Suu', 1, 'SKA-PVO Bishkek', 'Dordoy Naryn', 'Roman Kornilov', 39, 'SKA-PVO Bishkek', NULL, NULL),
(2004, 'Dordoy-Dinamo Naryn', 1, 'SKA-Shoro Bishkek', 'Jashtyk Ak-Altyn Kara-Suu', 'Zamirbek Dzhumagulov', 28, 'Dordoy-Dinamo Naryn', NULL, NULL),
(2005, 'Dordoy-Dinamo Naryn', 2, 'Shoro SKA Bishkek', 'Jashtyk Ak-Altyn Kara-Suu', 'Evgeniy Boldygin', 23, 'Jashtyk Ak-Altyn Kara-Suu', NULL, NULL),
(2006, 'Dordoy-Dinamo Naryn', 3, 'Abdysh-Ata Kant', 'Jashtyk Ak-Altyn Kara-Suu', 'Vyacheslav Pryanishnikov', 24, 'Abdysh-Ata Kant', NULL, NULL),
(2007, 'Dordoy-Dinamo Naryn', 4, 'Abdysh-Ata Kant', 'Jashtyk Ak-Altyn Kara-Suu', 'Almazbek Mirzaliev', 21, 'Abdysh-Ata Kant', NULL, NULL),
(2008, 'Dordoy-Dinamo Naryn', 5, 'Abdysh-Ata Kant', 'Alay Osh', 'Khurshit Lutfullaev / David Tetteh', 13, 'Abdysh-Ata Kant / Dordoy-Dinamo Naryn', NULL, 'Shared top scorer award'),
(2009, 'Dordoy-Dinamo', 6, 'Abdysh-Ata Kant', 'Alay Osh', 'Maksim Kretov', 21, 'Dordoy-Dinamo Naryn', 'Daniel Tagoe (Dordoy-Dinamo Naryn)', NULL),
(2010, 'Neftchi Kochkor-Ata', 1, 'Dordoy-Dinamo', 'Abdysh-Ata Kant', 'Talaybek Dzhumataev', 15, 'Neftchi Kochkor-Ata', 'Azamat Baimatov (Dordoy Bishkek)', NULL),
(2011, 'Dordoy Bishkek', 7, 'Neftchi Kochkor-Ata', 'Abdysh-Ata Kant', 'Vladimir Verevkin', 12, 'Alga Bishkek', NULL, NULL),
(2012, 'Dordoy Bishkek', 8, 'Alga Bishkek', 'Alay Osh', 'Kayumzhan Sharipov', 17, 'Dordoy Bishkek', NULL, NULL),
(2013, 'Alay Osh', 1, 'Dordoy Bishkek', 'Abdysh-Ata Kant', 'Almazbek Mirzaliev', 20, 'Abdysh-Ata Kant', NULL, NULL),
(2014, 'Dordoy Bishkek', 9, 'Abdysh-Ata Kant', 'Alga Bishkek', 'Kaleemullah Khan', 18, 'Dordoy Bishkek', NULL, NULL),
(2015, 'Alay Osh', 2, 'Dordoy Bishkek', 'Abdysh-Ata Kant', 'Alia Sylla', 17, 'Alay Osh', NULL, NULL),
(2016, 'Alay Osh', 3, 'Dordoy Bishkek', 'Alga Bishkek', 'Alia Sylla', 21, 'Alay Osh', NULL, NULL),
(2017, 'Alay Osh', 4, 'Abdysh-Ata Kant', 'Dordoy Bishkek', 'Alia Sylla', 12, 'Alay Osh', NULL, NULL),
(2018, 'Dordoy Bishkek', 10, 'Alay Osh', 'Abdysh-Ata Kant', 'Joel Kojo', 26, 'Alay Osh', NULL, NULL),
(2019, 'Dordoy Bishkek', 11, 'Alay Osh', 'Alga Bishkek', 'Vakhyt Orazsakhedov', 20, 'Dordoy Bishkek', 'Gulzhigit Alykulov', NULL),
(2020, 'Dordoy Bishkek', 12, 'Alga Bishkek', 'Neftchi Kochkor-Ata', 'Mirlan Murzaev', 10, 'Dordoy Bishkek', NULL, NULL),
(2021, 'Dordoy Bishkek', 13, 'Abdysh-Ata Kant', 'Alga Bishkek', 'Mirbek Akhmataliev', 17, 'Abdysh-Ata Kant', NULL, NULL),
(2022, 'Abdysh-Ata Kant', 1, 'Alay Osh', 'Alga Bishkek', 'Emmanuel Yagr', 14, 'Alay Osh', 'Magamed Uzdenov (Abdysh-Ata Kant)', NULL),
(2023, 'Abdysh-Ata Kant', 2, 'Alay Osh', 'Dordoy Bishkek', 'Danin Talovic', 14, 'Dordoy Bishkek', NULL, NULL),
(2024, 'Abdysh-Ata Kant', 3, 'Dordoy Bishkek', 'Muras United', 'Atay Dzhumataev', 11, 'Abdysh-Ata Kant', NULL, NULL),
(2025, 'Bars Issyk-Kul', 1, 'Muras United', 'Abdysh-Ata Kant', 'Oleksiy Zinkevych', 16, 'Alay Osh', NULL, NULL);

INSERT INTO kpfl_club_honours (
    club_name, titles, runner_up_count, third_place_count, championship_years
) VALUES
('Dordoy Bishkek', 13, 5, 5, '2004, 2005, 2006, 2007, 2008, 2009, 2011, 2012, 2014, 2018, 2019, 2020, 2021'),
('Alga Bishkek', 5, 8, 5, '1992, 1993, 2000, 2001, 2002'),
('Alay Osh', 4, 4, 5, '2013, 2015, 2016, 2017'),
('Abdysh-Ata Kant', 3, 7, 6, '2022, 2023, 2024'),
('Dinamo MVD Bishkek', 3, 1, 0, '1997, 1998, 1999'),
('Kant-Oyl', 2, 0, 0, '1994, 1995'),
('Jashtyk-Ak-Altyn Kara-Suu', 1, 2, 5, '2003'),
('Neftchi Kochkor-Ata', 1, 1, 1, '2010'),
('Metallurg Kadamjay', 1, 0, 0, '1996'),
('Bars Issyk-Kul', 1, 0, 0, '2025'),
('RUOR-Gvardiya Bishkek', 0, 2, 2, NULL),
('Ak-Maral Tokmak', 0, 1, 1, NULL),
('Muras United', 0, 1, 1, NULL),
('Shakhter Kyzyl-Kiya', 0, 1, 1, NULL),
('Orto-Nur Sokuluk', 0, 1, 0, NULL),
('Dinamo-UVD Osh', 0, 0, 1, NULL),
('Polet Bishkek', 0, 0, 1, NULL);

INSERT INTO kpfl_season_standings_archive (
    season_year, place_no, club_name, played, wins, draws, losses,
    goals_for, goals_against, goal_difference, points, matches_total
) VALUES
(2025, 1, 'Bars Issyk-Kul', 26, 19, 4, 3, 51, 21, 30, 61, 182),
(2025, 2, 'Muras United', 26, 19, 3, 4, 59, 24, 35, 60, 182),
(2025, 3, 'Abdysh-Ata', 26, 17, 3, 6, 47, 29, 18, 54, 182),
(2025, 4, 'Dordoy Bishkek', 26, 16, 6, 4, 50, 25, 25, 54, 182),
(2025, 5, 'Alay Osh', 26, 13, 6, 7, 45, 32, 13, 45, 182),
(2025, 6, 'Neftchi Kochkor-Ata', 26, 12, 5, 9, 38, 34, 4, 41, 182),
(2025, 7, 'Talant', 26, 10, 7, 9, 35, 35, 0, 37, 182),
(2025, 8, 'Ilbirs', 26, 7, 5, 14, 28, 42, -14, 26, 182),
(2025, 9, 'Alga Bishkek', 26, 3, 4, 19, 22, 58, -36, 13, 182),
(2025, 10, 'Kara-Balta', 26, 1, 1, 24, 15, 72, -57, 4, 182);

INSERT INTO kpfl_league_records (record_key, record_value, source_note) VALUES
('league_founded_year', '1992', 'Historical overview in provided data'),
('league_alternative_name', 'Zhogorku Liga', 'Historical overview in provided data'),
('league_tier', 'Top football division in Kyrgyzstan', 'Historical overview in provided data'),
('typical_team_count', '10-16 clubs by season', 'Historical overview in provided data'),
('afc_qualification_note', 'Champion qualifies for AFC Challenge League (or current AFC slot)', 'Historical overview in provided data'),
('most_titled_club', 'Dordoy Bishkek - 13 titles', 'Historical champion table (1992-2025)'),
('most_goals_single_season_player', 'Roman Kornilov - 39 goals (2003, SKA-PVO Bishkek)', 'Historical top scorer table'),
('best_all_time_scorer', 'Almazbek Mirzaliev - 142 goals', 'Wikipedia reference in provided data');

INSERT INTO kpfl_top_scorers_all_time (
    rank_no, player_name, position_name, goals, matches_played, goals_per_match, source_note
) VALUES
(1, 'Maksat Alygulov', 'Forward', 141, 164, 0.86, 'Transfermarkt snapshot from provided data'),
(2, 'Joel Kojo', 'Forward', 86, 132, 0.65, 'Transfermarkt snapshot from provided data'),
(3, 'Atay Dzhumataev', 'Right Winger', 138, 214, 0.64, 'Transfermarkt snapshot from provided data'),
(4, 'Mirbek Akhmataliev', 'Forward', 104, 161, 0.65, 'Transfermarkt snapshot from provided data'),
(5, 'Eldar Moldozhunusov', 'Left Winger', 140, 234, 0.60, 'Transfermarkt snapshot from provided data'),
(6, 'Emmanuel Yagr', 'Forward', 72, 144, 0.50, 'Transfermarkt snapshot from provided data'),
(7, 'Ernist Batyrkanov', 'Forward', 101, 187, 0.54, 'Transfermarkt snapshot from provided data'),
(8, 'Mirlan Murzaev', 'Forward', 84, 188, 0.45, 'Transfermarkt snapshot from provided data'),
(9, 'Anton Zemlyanukhin', 'Left Midfielder', 101, 213, 0.47, 'Transfermarkt snapshot from provided data'),
(10, 'Marlen Murzakhmatov', 'Forward', 104, 237, 0.44, 'Transfermarkt snapshot from provided data');

INSERT INTO kpfl_top_appearances_all_time (
    rank_no, player_name, position_name, matches_played, goals, source_note
) VALUES
(1, 'Eldar Moldozhunusov', 'Left Winger', 147, 47, 'Transfermarkt snapshot from provided data'),
(2, 'Esenbek Uson uulu', 'Left Back', 146, 8, 'Transfermarkt snapshot from provided data'),
(3, 'Suyuntbek Mamyraliev', 'Right Winger', 146, 17, 'Transfermarkt snapshot from provided data'),
(4, 'Maksat Alygulov', 'Forward', 142, 61, 'Transfermarkt snapshot from provided data'),
(5, 'Atay Dzhumataev', 'Right Winger', 138, 50, 'Transfermarkt snapshot from provided data'),
(6, 'Azamat Omuraliev', 'Right Winger', 137, 13, 'Transfermarkt snapshot from provided data'),
(7, 'Magamed Uzdenov', 'Central Midfielder', 135, 16, 'Transfermarkt snapshot from provided data'),
(8, 'Manas Karipov', 'Central Midfielder', 134, 10, 'Transfermarkt snapshot from provided data'),
(9, 'Argen Dzhumataev', 'Central Midfielder', 133, 11, 'Transfermarkt snapshot from provided data'),
(10, 'Aleksandr Mishchenko', 'Right Back', 131, 0, 'Transfermarkt snapshot from provided data');
