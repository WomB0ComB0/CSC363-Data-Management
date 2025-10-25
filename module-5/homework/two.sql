-- Good practice if you re-run scripts during homework
DROP TABLE IF EXISTS Fan;
DROP TABLE IF EXISTS Movie;

-- SQLite needs foreign keys turned on per connection
PRAGMA foreign_keys = ON;

-- MOVIE: composite PK (title, release_year)
CREATE TABLE Movie (
                       title           TEXT    NOT NULL,
                       release_year    INTEGER NOT NULL,
                       is_worth_seeing INTEGER NOT NULL DEFAULT 0,  -- 0/1 in SQLite
                       PRIMARY KEY (title, release_year)
);

-- FAN: holds the FK to MOVIE (mandatory favorite -> NOT NULL)
CREATE TABLE Fan (
                     fan_id   INTEGER       NOT NULL PRIMARY KEY, -- rowid alias; auto-increments
                     name     TEXT          NOT NULL,
                     address  TEXT,

                     fav_title        TEXT    NOT NULL,
                     fav_release_year INTEGER NOT NULL,

                     FOREIGN KEY (fav_title, fav_release_year)
                         REFERENCES Movie(title, release_year)
);
