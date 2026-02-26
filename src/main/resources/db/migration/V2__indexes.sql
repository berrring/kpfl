INSERT INTO seasons (year, name, start_date, end_date)
VALUES (2026, 'KPFL 2026', '2026-03-01', '2026-11-30');

INSERT INTO clubs (name, abbr, city, stadium, founded_year, primary_color, logo_url, created_at) VALUES
('Dordoi Bishkek', 'DOR', 'Bishkek', 'Dolen Omurzakov', 1997, '#0033A0', NULL, NOW()),
('Alay Osh', 'ALY', 'Osh', 'Suyumbayev', 1960, '#C8102E', NULL, NOW()),
('Abdysh-Ata', 'ABD', 'Kant', 'Ouran Arena', 2000, '#006847', NULL, NOW()),
('Neftchi Kochkor-Ata', 'NFK', 'Kochkor-Ata', 'Neftchi Stadium', 1952, '#1C1C1C', NULL, NOW()),
('Ilbirs Bishkek', 'ILB', 'Bishkek', 'Futbol Borboru', 2018, '#0A3161', NULL, NOW()),
('Muras United', 'MUR', 'Jalal-Abad', 'Kurmanbek Stadium', 2023, '#F05A28', NULL, NOW()),
('Talant', 'TAL', 'Bishkek', 'Talant Arena', 2022, '#6A1B9A', NULL, NOW()),
('Alga Bishkek', 'ALG', 'Bishkek', 'Alga Stadium', 1947, '#005EB8', NULL, NOW()),
('FC OshMU', 'OSH', 'Osh', 'Osh Arena', 2021, '#8B0000', NULL, NOW()),
('Kara-Balta', 'KBT', 'Kara-Balta', 'Manas Stadium', 2010, '#2E7D32', NULL, NOW()),
('Uzgen', 'UZG', 'Uzgen', 'Uzgen Stadium', 2012, '#455A64', NULL, NOW()),
('Bishkek City', 'BSC', 'Bishkek', 'City Arena', 2019, '#D32F2F', NULL, NOW()),
('Naryn FC', 'NRN', 'Naryn', 'Naryn Central', 2015, '#1565C0', NULL, NOW()),
('Talas United', 'TLS', 'Talas', 'Talas Stadium', 2016, '#EF6C00', NULL, NOW());

INSERT INTO players (
    club_id, first_name, last_name, jersey_number, position, birth_date, nationality,
    height_cm, weight_kg, photo_url, source_url, source_note, created_at
) VALUES
(1, 'Beknaz', 'Almazov', 1,  'GK', '1999-01-12', 'Kyrgyzstan', 188, 82, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(1, 'Mirlan', 'Sydykov', 4,  'DF', '2001-06-03', 'Kyrgyzstan', 184, 77, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(1, 'Aidar', 'Satybaldiev', 9,  'FW', '2002-09-15', 'Kyrgyzstan', 181, 74, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(2, 'Nursultan', 'Ergeshov', 1,  'GK', '1998-02-11', 'Kyrgyzstan', 190, 84, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(2, 'Baktiyar', 'Joldoshov', 5,  'DF', '2000-05-20', 'Kyrgyzstan', 186, 79, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(2, 'Ruslan', 'Kudaibergenov', 10, 'MF', '2002-03-17', 'Kyrgyzstan', 176, 70, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(3, 'Azamat', 'Sadykov', 1,  'GK', '1997-11-07', 'Kyrgyzstan', 191, 85, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(3, 'Tilek', 'Alymbekov', 6,  'DF', '2001-12-02', 'Kyrgyzstan', 183, 76, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(3, 'Samat', 'Turgunov', 11, 'FW', '2003-08-09', 'Kyrgyzstan', 179, 72, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(4, 'Kubanych', 'Mambetaliev', 1,  'GK', '1996-07-13', 'Kyrgyzstan', 189, 83, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(4, 'Islam', 'Amanov', 4,  'DF', '1999-10-30', 'Kyrgyzstan', 185, 78, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(4, 'Ulan', 'Abdyldaev', 9,  'FW', '2001-04-16', 'Kyrgyzstan', 180, 73, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(5, 'Erkin', 'Toktogulov', 1,  'GK', '2000-06-28', 'Kyrgyzstan', 187, 81, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(5, 'Aibek', 'Temirov', 3,  'DF', '2002-01-03', 'Kyrgyzstan', 182, 76, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(5, 'Marat', 'Abdurakhmanov', 8,  'MF', '2003-02-14', 'Kyrgyzstan', 177, 71, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(6, 'Adilet', 'Kubatbekov', 1,  'GK', '1998-04-21', 'Kyrgyzstan', 188, 82, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(6, 'Bakyt', 'Isakov', 2,  'DF', '2001-01-18', 'Kyrgyzstan', 184, 77, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(6, 'Eldar', 'Mederov', 10, 'FW', '2002-12-06', 'Kyrgyzstan', 181, 75, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(7, 'Nurbek', 'Kasimov', 1,  'GK', '1999-05-09', 'Kyrgyzstan', 190, 84, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(7, 'Dastan', 'Orozov', 5,  'DF', '2001-09-11', 'Kyrgyzstan', 186, 79, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(7, 'Temirlan', 'Sultanov', 9,  'FW', '2003-10-22', 'Kyrgyzstan', 180, 73, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(8, 'Aman', 'Karypov', 1,  'GK', '1997-03-01', 'Kyrgyzstan', 189, 83, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(8, 'Zhanyl', 'Boronov', 4,  'DF', '2000-11-25', 'Kyrgyzstan', 183, 77, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(8, 'Arslan', 'Ormonbekov', 8,  'MF', '2002-08-27', 'Kyrgyzstan', 178, 72, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(9, 'Samat', 'Doolatov', 1,  'GK', '1998-06-10', 'Kyrgyzstan', 188, 82, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(9, 'Nurislam', 'Kenzhebaev', 3,  'DF', '2001-04-04', 'Kyrgyzstan', 185, 78, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(9, 'Rinat', 'Alyshov', 11, 'FW', '2002-09-29', 'Kyrgyzstan', 181, 74, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(10, 'Kairat', 'Murzakulov', 1,  'GK', '1999-07-02', 'Kyrgyzstan', 187, 81, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(10, 'Aziz', 'Kudayarov', 6,  'DF', '2000-10-18', 'Kyrgyzstan', 184, 77, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(10, 'Talant', 'Aitmatov', 10, 'MF', '2003-03-12', 'Kyrgyzstan', 177, 70, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(11, 'Maksat', 'Niyazov', 1,  'GK', '1998-12-13', 'Kyrgyzstan', 190, 84, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(11, 'Amanbek', 'Ismailov', 5,  'DF', '2001-02-07', 'Kyrgyzstan', 186, 79, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(11, 'Emil', 'Japarov', 9,  'FW', '2002-11-05', 'Kyrgyzstan', 180, 74, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(12, 'Talgat', 'Turdubaev', 1,  'GK', '1997-09-08', 'Kyrgyzstan', 188, 82, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(12, 'Nurlan', 'Saparov', 4,  'DF', '2000-01-30', 'Kyrgyzstan', 183, 77, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(12, 'Meder', 'Umetaliev', 8,  'MF', '2003-06-16', 'Kyrgyzstan', 178, 71, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(13, 'Argen', 'Amanaliev', 1,  'GK', '1999-03-06', 'Kyrgyzstan', 189, 83, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(13, 'Uson', 'Kydyraliev', 2,  'DF', '2001-08-19', 'Kyrgyzstan', 185, 78, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(13, 'Argenbek', 'Moldobaev', 10, 'FW', '2002-07-14', 'Kyrgyzstan', 181, 74, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(14, 'Sanzhar', 'Bekmamatov', 1,  'GK', '1998-05-01', 'Kyrgyzstan', 188, 82, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(14, 'Askar', 'Kurmangazy', 5,  'DF', '2000-12-21', 'Kyrgyzstan', 184, 77, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW()),
(14, 'Adil', 'Akunov', 9,  'FW', '2003-04-08', 'Kyrgyzstan', 180, 73, NULL, 'https://www.instagram.com/', 'Club official roster post', NOW());

INSERT INTO matches (
    season_id, round_number, date_time, stadium, home_club_id, away_club_id,
    home_goals, away_goals, status, created_at
) VALUES
(1, 1, '2026-03-05 18:00:00', 'Dolen Omurzakov', 1, 2, 2, 1, 'FINISHED', NOW()),
(1, 1, '2026-03-06 18:00:00', 'Ouran Arena', 3, 4, 1, 1, 'FINISHED', NOW()),
(1, 1, '2026-03-06 20:00:00', 'Futbol Borboru', 5, 6, 0, 2, 'FINISHED', NOW()),
(1, 1, '2026-03-07 18:00:00', 'Talant Arena', 7, 8, NULL, NULL, 'SCHEDULED', NOW()),
(1, 1, '2026-03-07 20:00:00', 'Osh Arena', 9, 10, NULL, NULL, 'SCHEDULED', NOW()),
(1, 1, '2026-03-08 18:00:00', 'City Arena', 12, 11, NULL, NULL, 'SCHEDULED', NOW()),
(1, 1, '2026-03-08 20:00:00', 'Naryn Central', 13, 14, NULL, NULL, 'SCHEDULED', NOW()),
(1, 2, '2026-03-12 18:00:00', 'Suyumbayev', 2, 1, NULL, NULL, 'SCHEDULED', NOW()),
(1, 2, '2026-03-13 18:00:00', 'Neftchi Stadium', 4, 3, NULL, NULL, 'SCHEDULED', NOW()),
(1, 2, '2026-03-13 20:00:00', 'Kurmanbek Stadium', 6, 5, NULL, NULL, 'SCHEDULED', NOW()),
(1, 2, '2026-03-14 18:00:00', 'Alga Stadium', 8, 7, NULL, NULL, 'SCHEDULED', NOW()),
(1, 2, '2026-03-15 18:00:00', 'Manas Stadium', 10, 9, NULL, NULL, 'SCHEDULED', NOW());

INSERT INTO news (title, short_text, tag, published_at, club_id, player_id, created_at) VALUES
('Season kickoff confirmed', 'KPFL 2026 starts in early March with full match week.', 'OFFICIAL', '2026-02-20 10:00:00', NULL, NULL, NOW()),
('Dordoi wins opening game', 'Dordoi takes three points after a close 2:1 home match.', 'MATCHDAY', '2026-03-05 21:30:00', 1, NULL, NOW()),
('Round 1 draw in Kant', 'Abdysh-Ata and Neftchi share points in an even game.', 'MATCHDAY', '2026-03-06 21:00:00', 3, NULL, NOW()),
('Muras transfer update', 'Muras United adds a new forward before round 2.', 'TRANSFER', '2026-03-10 13:45:00', 6, NULL, NOW()),
('Injury report', 'One starting defender is expected to miss two weeks.', 'INJURY', '2026-03-10 18:20:00', 2, NULL, NOW()),
('Round 2 schedule', 'League publishes exact kickoff times for weekend fixtures.', 'OFFICIAL', '2026-03-11 09:15:00', NULL, NULL, NOW()),
('Coach comment after draw', 'Head coach notes better control but missed chances.', 'MATCHDAY', '2026-03-06 22:10:00', 4, NULL, NOW()),
('Youth player debut planned', 'Club plans to start academy midfielder in round 2.', 'OTHER', '2026-03-12 12:00:00', 12, NULL, NOW());

INSERT INTO users (email, password_hash, role, display_name, created_at)
VALUES ('admin@kpfl.local', '{noop}admin', 'ADMIN', 'KPFL Admin', NOW());
