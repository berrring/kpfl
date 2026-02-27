DELETE FROM news;
DELETE FROM matches;
DELETE FROM players;
DELETE FROM clubs;
DELETE FROM seasons;

INSERT INTO seasons (id, year, name, start_date, end_date)
VALUES (1, 2026, 'KPFL 2026', '2026-03-01', '2026-11-30');

INSERT INTO clubs (
    id, name, abbr, city, stadium, founded_year, primary_color, logo_url,
    coach_name, coach_info, created_at
) VALUES
(1, 'Muras United Dzhalal-Abad', 'MUR', 'Dzhalal-Abad', NULL, NULL, NULL, NULL, 'Edmar Galovskyi', 'Ukraine/Brazil, appointed Nov 2025, contract until 2026-12-31', NOW()),
(2, 'Alga Bishkek', 'ALG', 'Bishkek', NULL, NULL, NULL, NULL, 'Maksim Lisitsyn', 'Kyrgyzstan, appointed Jul 2025', NOW()),
(3, 'Bars Karakol', 'BRS', 'Karakol', NULL, NULL, NULL, NULL, 'Francesc Bonet', 'Spain, appointed Jan 2026, contract until 2026-12-31', NOW()),
(4, 'FC Ozgon', 'OZG', 'Ozgon', NULL, NULL, NULL, NULL, 'Nadyrbek Mamadaliev', 'Kyrgyzstan', NOW()),
(5, 'FC Bishkek City', 'BSC', 'Bishkek', NULL, NULL, NULL, NULL, 'Giovanni Costantino', 'Italy, appointed May 2025', NOW()),
(6, 'Asiagoal Bishkek', 'ASG', 'Bishkek', NULL, NULL, NULL, NULL, 'Islam Akhmedov', 'Kyrgyzstan', NOW()),
(7, 'FK Dordoi Bishkek', 'DOR', 'Bishkek', NULL, NULL, NULL, NULL, 'Vladimir Salo', 'Kyrgyzstan, appointed Jun 2024, contract until 2026-12-31', NOW()),
(8, 'Talant Besh-Kungoy', 'TAL', 'Besh-Kungoy', NULL, NULL, NULL, NULL, 'Urmat Abdukaimov', 'Kyrgyzstan, appointed Dec 2022', NOW()),
(9, 'FK Abdysh-Ata Kant', 'ABD', 'Kant', NULL, NULL, NULL, NULL, 'Valery Berezovsky', 'Kyrgyzstan, re-appointed Jan 2026', NOW()),
(10, 'FK Alay Osh', 'ALY', 'Osh', NULL, NULL, NULL, NULL, 'Rustam Akhunov', 'Kyrgyzstan', NOW()),
(11, 'FK Ilbirs Bishkek', 'ILB', 'Bishkek', NULL, NULL, NULL, NULL, 'Nurbek Zholdoshov', 'Kyrgyzstan, appointed Feb 2025', NOW()),
(12, 'FC Toktogul', 'TOK', 'Toktogul', NULL, NULL, NULL, NULL, 'Sergiy Puchkov', 'Ukraine, appointed Jan 2026, contract until 2026-12-31', NOW()),
(13, 'Neftchi Kochkor-Ata', 'NFK', 'Kochkor-Ata', NULL, NULL, NULL, NULL, 'Anatoliy Vlasichev', 'Kyrgyzstan/Uzbekistan, appointed Aug 2025', NOW()),
(14, 'FC OshMU', 'OSM', 'Osh', NULL, NULL, NULL, NULL, 'Aibek Sulaimanov', 'Kyrgyzstan', NOW()),
(15, 'Kyrgyzaltyn Kara-Balta', 'KKB', 'Kara-Balta', NULL, NULL, NULL, NULL, 'Bakay Zayyrbekov', 'Kyrgyzstan, appointed Dec 2025', NOW()),
(16, 'Asia Talas', 'ATL', 'Talas', NULL, NULL, NULL, NULL, 'Maksim Shatskikh', 'Uzbekistan, appointed Nov 2025', NOW());

SELECT setval(pg_get_serial_sequence('seasons', 'id'), COALESCE((SELECT MAX(id) FROM seasons), 1), TRUE);
SELECT setval(pg_get_serial_sequence('clubs', 'id'), COALESCE((SELECT MAX(id) FROM clubs), 1), TRUE);

CREATE TEMPORARY TABLE tmp_player_seed (
    club_abbr VARCHAR(10) NOT NULL,
    position VARCHAR(10) NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    age_years INT NULL,
    market_value_eur BIGINT NULL
);

INSERT INTO tmp_player_seed (club_abbr, position, full_name, age_years, market_value_eur) VALUES
('MUR', 'GK', 'Orest Kostyk', 26, 300000),
('MUR', 'GK', 'Aziret Ysmanaliev', 20, 75000),
('MUR', 'GK', 'Alisher Zakirov', 19, NULL),
('MUR', 'DF', 'Sergey Nozdrin', 20, NULL),
('MUR', 'DF', 'Yuriy Mate', 27, 250000),
('MUR', 'DF', 'Glib Grachov', 28, 200000),
('MUR', 'DF', 'Emir-Khan Kydyrshaev', 20, 50000),
('MUR', 'DF', 'Temirlan Samat Uulu', 22, 50000),

('ALG', 'GK', 'Erzhan Tokotaev', 25, 450000),
('ALG', 'GK', 'Sultan Chomoev', 23, 150000),
('ALG', 'GK', 'Evgeniy Sitdikov', 24, NULL),
('ALG', 'GK', 'Seytek Urustamov', 20, NULL),
('ALG', 'GK', 'Artur Ismanbekov', 21, NULL),
('ALG', 'DF', 'Insan Talantbek Uulu', 19, NULL),
('ALG', 'DF', 'Volodymyr Zaimenko', 28, 200000),
('ALG', 'DF', 'Arslan Bekberdinov', 22, 200000),

('BRS', 'GK', 'Marsel Islamkulov', 31, 275000),
('BRS', 'GK', 'Ruslan Amirov', 35, 25000),
('BRS', 'DF', 'Valeriy Kichin', 33, 350000),
('BRS', 'DF', 'Aleksey Abramov', 25, 200000),
('BRS', 'DF', 'Ayzar Akmatov', 27, 175000),
('BRS', 'DF', 'Gia Chaduneli', 31, 150000),
('BRS', 'DF', 'Bekzhan Sagynbaev', 31, 175000),
('BRS', 'DF', 'Said Datsiev', 22, 300000),

('OZG', 'GK', 'Yevgen Grytsenko', 31, 250000),
('OZG', 'GK', 'Omurzak Oronbaev', 22, 125000),
('OZG', 'GK', 'Javokhir Akbarov', 17, NULL),
('OZG', 'DF', 'Narynbek Myrzabek uulu', 21, 50000),
('OZG', 'DF', 'Ibrakhim Zhetimishev', 21, NULL),
('OZG', 'DF', 'Amantur Shamurzaev', 26, 300000),
('OZG', 'DF', 'Ulanbek Sulaymanov', 23, 300000),
('OZG', 'DF', 'Cesar Benavides', 21, 150000),

('BSC', 'GK', 'Artem Pryadkin', 24, 200000),
('BSC', 'GK', 'Aleksandr Shapkarin', 17, 25000),
('BSC', 'DF', 'Ulanbek Sultanbekov', 19, NULL),
('BSC', 'DF', 'Eldiyar Ulanbek uulu', 20, NULL),
('BSC', 'DF', 'Vladislav Mikushin', 24, 125000),
('BSC', 'DF', 'Mykyta Peterman', 26, 100000),
('BSC', 'DF', 'Igor Gubanov', 34, 75000),
('BSC', 'DF', 'Timur Nabiev', 25, 50000),

('ASG', 'GK', 'Daniil Polyanskiy', 31, 75000),
('ASG', 'GK', 'Dastan Alybekov', 28, 50000),
('ASG', 'GK', 'Kutman Kadyrbekov', 28, 50000),
('ASG', 'GK', 'Azamat Sagynbekov', 21, NULL),
('ASG', 'GK', 'Bayzak Bektur uulu', 18, NULL),
('ASG', 'DF', 'Maksat Dzhakybaliev', 26, 100000),
('ASG', 'DF', 'Nikola Borisov', 25, 100000),
('ASG', 'DF', 'Adilet Nurlan uulu', 23, 25000),

('DOR', 'GK', 'Kurmanbek Nurlanbekov', 21, 150000),
('DOR', 'GK', 'Adilet Abdyrayymov', 19, 75000),
('DOR', 'DF', 'Salim Mambetov', 19, NULL),
('DOR', 'DF', 'Giorgi Gabadze', 30, 100000),
('DOR', 'DF', 'Denys Prytykovskyi', 31, NULL),
('DOR', 'DF', 'Aleksandr Mishchenko', 28, 300000),
('DOR', 'DF', 'Arystan Kuanov', 25, 10000),
('DOR', 'MF', 'Adil Kadyrzhanov', 25, 200000),

('TAL', 'GK', 'Mikhail Ponomarenko', 27, 100000),
('TAL', 'GK', 'Maksym Parshykov', 22, 50000),
('TAL', 'GK', 'Roman Zhanybek Uulu', 22, NULL),
('TAL', 'DF', 'Altay Raimbekov', 20, 50000),
('TAL', 'DF', 'Valeriy Murzakov', 22, 75000),
('TAL', 'DF', 'Nemanja Rakovic', 24, 50000),
('TAL', 'DF', 'Timur Amirov', 22, 50000),
('TAL', 'DF', 'Erbol Kamchibekov', 17, NULL),

('ABD', 'GK', 'Nodari Kalichava', 25, 175000),
('ABD', 'GK', 'Sultan Beyshenaliev', 22, NULL),
('ABD', 'GK', 'Oskon Baratov', 20, NULL),
('ABD', 'DF', 'Chyngyz Subanov', 34, 50000),
('ABD', 'DF', 'Sukhrob Berdiev', 20, 50000),
('ABD', 'DF', 'Evgeniy Pleshko', 25, NULL),
('ABD', 'DF', 'Rauf Asinov', 20, NULL),
('ABD', 'DF', 'Mukhtar Ishenaliev', 20, NULL),

('ALY', 'GK', 'Mirzokhid Mamatkhonov', 31, 125000),
('ALY', 'DF', 'Mukhammadali Zairov', 22, NULL),
('ALY', 'DF', 'Jamshid Kobulov', 28, 100000),
('ALY', 'DF', 'Askarbek Saliev', 30, 75000),
('ALY', 'DF', 'Erlan Mashirapov', 26, 100000),
('ALY', 'DF', 'Amanbek Manybekov', 30, 75000),
('ALY', 'DF', 'Kamolidin Tashiev', 26, 50000),
('ALY', 'DF', 'Taimuras Mamyrbaev', 18, NULL),

('ILB', 'GK', 'Mykhaylo Gotra', 25, 100000),
('ILB', 'GK', 'Ermek Kemelbekov', 18, 25000),
('ILB', 'DF', 'Meder Tuganbaev', 19, 125000),
('ILB', 'DF', 'Aitenir Balbakov', 21, 125000),
('ILB', 'DF', 'Aktan Abdykalilov', 19, 100000),
('ILB', 'DF', 'Aidar Muratbekov', 17, 25000),
('ILB', 'DF', 'Shakhsultan Jumabaev', 18, NULL),
('ILB', 'DF', 'Ilya Bondarenko', 18, 75000),

('TOK', 'GK', 'Kalysbek Akimaliev', 33, 25000),
('TOK', 'GK', 'Adilmirza Nurzhakypov', 21, NULL),
('TOK', 'DF', 'Julio Cesar', 29, 300000),
('TOK', 'DF', 'Solomon Kvirkvelia', 34, 250000),
('TOK', 'DF', 'Sherzod Shakirov', 35, NULL),
('TOK', 'DF', 'Maksim Duvanaev', 25, NULL),
('TOK', 'DF', 'Avazbek Otkeev', 32, NULL),
('TOK', 'DF', 'Baatyrbek Bolotbek uulu', 33, NULL),

('NFK', 'GK', 'Melis Tashtanov', 22, 25000),
('NFK', 'GK', 'Artem Belyi', 28, NULL),
('NFK', 'GK', 'Uson Mamatkadyrov', 18, NULL),
('NFK', 'DF', 'Doniyorbek Makhmudov', 19, NULL),
('NFK', 'DF', 'Mederbek Kudud', 21, NULL),
('NFK', 'DF', 'Akram Umarov', 32, 125000),
('NFK', 'DF', 'Sardorbek Khursandov', 25, 125000),
('NFK', 'DF', 'Alex Baker', 24, 100000),

('OSM', 'GK', 'Maksim Vysotskiy', 31, 100000),
('OSM', 'GK', 'Sarvar Mirzaev', 24, NULL),
('OSM', 'GK', 'Bektur Almazbek uulu', 18, NULL),
('OSM', 'GK', 'Muslimbek Ismoilov', 23, NULL),
('OSM', 'DF', 'Abdufattokh Foziljonov', 22, NULL),
('OSM', 'DF', 'Bekzatbek Nasirov', 24, 125000),
('OSM', 'DF', 'Nadyrbek Baltabaev', 19, NULL),
('OSM', 'DF', 'Pulat Sharipov', 26, 75000),

('KKB', 'GK', 'Suliman Murtazaev', 22, 25000),
('KKB', 'GK', 'Nursultan Nusupov', 21, NULL),
('KKB', 'GK', 'Nurtaazim Kyshtobaev', 20, NULL),
('KKB', 'DF', 'Ernar Erkebekov', 21, NULL),
('KKB', 'DF', 'Daniyar Ergeshov', 20, NULL),
('KKB', 'DF', 'Ermin Imamovic', 30, 150000),
('KKB', 'DF', 'Kanat Akmatov', 29, 100000),
('KKB', 'DF', 'Asylbek Iskakov', 27, 50000),

('ATL', 'DF', 'Christian Brauzman', 22, 450000),
('ATL', 'MF', 'Demur Chikhladze', 29, 225000),
('ATL', 'FW', 'Mykola Agapov', 32, 175000);

INSERT INTO players (
    club_id, first_name, last_name, jersey_number, position, birth_date, nationality,
    height_cm, weight_kg, age_years, market_value_eur, photo_url, source_url, source_note, created_at
)
SELECT
    c.id,
    split_part(t.full_name, ' ', 1),
    CASE
        WHEN POSITION(' ' IN t.full_name) = 0 THEN 'Unknown'
        ELSE TRIM(SUBSTRING(t.full_name FROM POSITION(' ' IN t.full_name) + 1))
    END,
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
    'Roster provided for midterm dataset',
    NOW()
FROM tmp_player_seed t
JOIN clubs c ON c.abbr = t.club_abbr;

DROP TABLE IF EXISTS tmp_player_seed;

INSERT INTO matches (
    season_id, round_number, date_time, stadium, home_club_id, away_club_id,
    home_goals, away_goals, status, created_at
) VALUES
(1, 1, '2026-03-05 18:00:00', 'Dolen Omurzakov', 7, 10, 2, 1, 'FINISHED', NOW()),
(1, 1, '2026-03-06 18:00:00', 'Kant Arena', 9, 13, 1, 1, 'FINISHED', NOW()),
(1, 1, '2026-03-06 20:00:00', 'Karakol Arena', 3, 15, 3, 0, 'FINISHED', NOW()),
(1, 1, '2026-03-07 18:00:00', 'Bishkek City Arena', 5, 11, NULL, NULL, 'SCHEDULED', NOW()),
(1, 1, '2026-03-07 20:00:00', 'Muras Arena', 1, 2, NULL, NULL, 'SCHEDULED', NOW()),
(1, 1, '2026-03-08 18:00:00', 'Talas Stadium', 16, 12, NULL, NULL, 'SCHEDULED', NOW()),
(1, 1, '2026-03-08 20:00:00', 'Toktogul Stadium', 12, 8, NULL, NULL, 'SCHEDULED', NOW()),
(1, 2, '2026-03-12 18:00:00', 'Osh Arena', 10, 14, NULL, NULL, 'SCHEDULED', NOW()),
(1, 2, '2026-03-13 18:00:00', 'Kochkor-Ata Stadium', 13, 6, NULL, NULL, 'SCHEDULED', NOW()),
(1, 2, '2026-03-14 18:00:00', 'Kara-Balta Stadium', 15, 4, NULL, NULL, 'SCHEDULED', NOW());

INSERT INTO news (title, short_text, tag, published_at, club_id, player_id, created_at) VALUES
('KPFL 2026 season starts', 'League confirms opening week fixtures for all clubs.', 'OFFICIAL', '2026-02-20 10:00:00', NULL, NULL, NOW()),
('Dordoi takes first win', 'FK Dordoi Bishkek starts with a 2:1 victory.', 'MATCHDAY', '2026-03-05 21:30:00', 7, NULL, NOW()),
('Abdysh-Ata and Neftchi draw', 'Both sides share points in round one.', 'MATCHDAY', '2026-03-06 20:50:00', 9, NULL, NOW()),
('Bars Karakol wins at home', 'Bars opens campaign with confident 3:0 result.', 'MATCHDAY', '2026-03-06 22:00:00', 3, NULL, NOW()),
('Muras head coach statement', 'Edmar Galovskyi comments on pre-season preparation.', 'OFFICIAL', '2026-02-25 12:00:00', 1, NULL, NOW()),
('Alga announces squad update', 'Club updates first team roster before round two.', 'OTHER', '2026-03-10 11:00:00', 2, NULL, NOW()),
('Round two kickoff times', 'Exact match times published for second round.', 'OFFICIAL', '2026-03-11 09:20:00', NULL, NULL, NOW()),
('Asia Talas debut', 'New club enters KPFL schedule with first official fixture.', 'OFFICIAL', '2026-03-01 16:00:00', 16, NULL, NOW());
