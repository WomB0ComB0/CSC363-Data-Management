-- Clean re-run
DROP TABLE IF EXISTS Passport;
DROP TABLE IF EXISTS Citizen;

-- Enable FK enforcement for this connection
PRAGMA foreign_keys = ON;

-- CITIZEN (strong entity)
CREATE TABLE Citizen (
                         SSN     TEXT NOT NULL,               -- e.g., 123-45-6789
                         name    TEXT NOT NULL,
                         address TEXT,
                         PRIMARY KEY (SSN),
    -- Optional format guard: 'ddd-dd-dddd'
                         CHECK (SSN GLOB '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
);

-- PASSPORT (dependent entity; exactly one per citizen)
CREATE TABLE Passport (
                          passport_id  TEXT NOT NULL,
                          issue_date   DATE NOT NULL,
                          expire_date  DATE NOT NULL,

                          owner_ssn    TEXT NOT NULL,          -- FK to Citizen

                          PRIMARY KEY (passport_id),
                          UNIQUE (owner_ssn),                   -- ensures 1:1 (one passport per citizen)
                          FOREIGN KEY (owner_ssn)
                              REFERENCES Citizen(SSN)
                              ON DELETE CASCADE                   -- optional but typical for 1:1 dependency
                              ON UPDATE CASCADE
);
