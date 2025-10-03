-- 1) Delete exactly one row: e.g. remove a specific game stat
DELETE FROM sports.GAME_STAT
WHERE game_id = 1001 AND player_id = 102;

-- 2) Delete all rows from a table: e.g. remove all games
DELETE FROM sports.GAME;
