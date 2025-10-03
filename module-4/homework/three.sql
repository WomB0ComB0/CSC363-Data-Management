-- 1) Update *all* rows: e.g. add a prefix to every team’s name
UPDATE sports.TEAM
SET name = 'The ' + name;

-- 2) Update one specific player: e.g. change Bob’s position
UPDATE sports.PLAYER
SET position = 'Shooting Guard'
WHERE player_id = 102;
