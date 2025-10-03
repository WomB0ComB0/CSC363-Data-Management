CREATE SCHEMA sports;
GO

/* 1) TEAM — parent table (no FKs) */
CREATE TABLE sports.TEAM (
                             team_id     INT           NOT NULL,
                             name        VARCHAR(100)  NOT NULL,
                             city        VARCHAR(100)  NULL,
                             CONSTRAINT PK_TEAM PRIMARY KEY (team_id)
);
GO

/* 2) PLAYER — many-to-one to TEAM */
CREATE TABLE sports.PLAYER (
                               player_id   INT           NOT NULL,
                               team_id     INT           NOT NULL,
                               name        VARCHAR(100)  NOT NULL,
                               position    VARCHAR(30)   NULL,
                               CONSTRAINT PK_PLAYER PRIMARY KEY (player_id),
                               CONSTRAINT FK_PLAYER_TEAM
                                   FOREIGN KEY (team_id) REFERENCES sports.TEAM(team_id)
);
GO

/* 3) GAME — both teams reference TEAM */
CREATE TABLE sports.GAME (
                             game_id       INT          NOT NULL,
                             home_team_id  INT          NOT NULL,
                             away_team_id  INT          NOT NULL,
    [date]        DATE         NOT NULL,
                             CONSTRAINT PK_GAME PRIMARY KEY (game_id),
                             CONSTRAINT FK_GAME_HOME_TEAM
                                 FOREIGN KEY (home_team_id) REFERENCES sports.TEAM(team_id),
                             CONSTRAINT FK_GAME_AWAY_TEAM
                                 FOREIGN KEY (away_team_id) REFERENCES sports.TEAM(team_id),
    -- sane rule: a team can't play itself
                             CONSTRAINT CK_GAME_DistinctTeams CHECK (home_team_id <> away_team_id)
);
GO

/* 4) GAME_STAT — intersection: one row per player per game */
CREATE TABLE sports.GAME_STAT (
                                  game_id       INT          NOT NULL,
                                  player_id     INT          NOT NULL,
                                  points_scored INT          NOT NULL,
                                  CONSTRAINT PK_GAME_STAT PRIMARY KEY (game_id, player_id),
                                  CONSTRAINT FK_GAMESTAT_GAME
                                      FOREIGN KEY (game_id)   REFERENCES sports.GAME(game_id),
                                  CONSTRAINT FK_GAMESTAT_PLAYER
                                      FOREIGN KEY (player_id) REFERENCES sports.PLAYER(player_id),
                                  CONSTRAINT CK_GAMESTAT_NonNegativePoints CHECK (points_scored >= 0)
);
GO
