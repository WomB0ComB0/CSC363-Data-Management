-- Make sure FKs work in this connection
PRAGMA foreign_keys = ON;

-- PERSON (strong entity)
CREATE TABLE Person (
                        ram_id   CHAR(9)  NOT NULL,
                        name     TEXT     NOT NULL,
                        address  TEXT,
                        CONSTRAINT PK_Person PRIMARY KEY (ram_id),
    -- 'R' + 8 digits (SQLite: use LIKE/GLOB in CHECK)
                        CONSTRAINT CK_Person_ram_id_Format
                            CHECK (
                                ram_id LIKE 'R________'                  -- 9 chars, starts with R
                                    AND substr(ram_id, 2) GLOB '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
                                )
);

-- PET (weak entity)
CREATE TABLE Pet (
                     adopter_id    CHAR(9)   NOT NULL,   -- FK to Person
                     name          VARCHAR(50) NOT NULL, -- partial key
                     species       VARCHAR(40) NOT NULL, -- partial key
                     color         VARCHAR(40),
                     adoption_date DATE       NOT NULL,  -- relationship attribute
                     CONSTRAINT PK_Pet PRIMARY KEY (adopter_id, name, species),
                     CONSTRAINT FK_Pet_Person
                         FOREIGN KEY (adopter_id)
                             REFERENCES Person(ram_id)
                             ON DELETE CASCADE
);
