-- 1) Insert into TEAM (parent)
INSERT INTO sports.TEAM (team_id, name, city) VALUES
                                                  (1, 'Dragons', 'Newark'),
                                                  (2, 'Tigers', 'Boston'),
                                                  (3, 'Wolves', 'Chicago');

-- 2) Insert into PLAYER (depends on TEAM)
INSERT INTO sports.PLAYER (player_id, team_id, name, position) VALUES
                                                                   (101, 1, 'Alice', 'Forward'),
                                                                   (102, 1, 'Bob',   'Guard'),
                                                                   (201, 2, 'Carol', 'Center');

-- 3) Insert into GAME (depends on TEAM)
INSERT INTO sports.GAME (game_id, home_team_id, away_team_id, [date]) VALUES
                                                                          (1001, 1, 2, '2025-10-05'),
                                                                          (1002, 2, 3, '2025-10-06'),
                                                                          (1003, 3, 1, '2025-10-07');

-- 4) Insert into GAME_STAT (depends on GAME and PLAYER)
INSERT INTO sports.GAME_STAT (game_id, player_id, points_scored) VALUES
                                                                     (1001, 101, 20),
                                                                     (1001, 102, 15),
                                                                     (1002, 201, 25);
