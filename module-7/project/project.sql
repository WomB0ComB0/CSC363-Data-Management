-- Step 1: Create the Database if it doesn't exist.
-- The USE [master] command ensures we are connected to the system database
-- which has the permissions to create other databases.
USE [master];
GO

-- Check if a database named 'MusicStreamDB' already exists. If not, create it.
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'MusicStreamDB')
BEGIN
    CREATE DATABASE [MusicStreamDB];
END
GO

-- Step 2: Switch to the context of your newly created database.
-- All subsequent commands will now run inside MusicStreamDB.
USE [MusicStreamDB];
GO

-- Step 3: Create the schema IF IT DOES NOT EXIST.
-- The GO command separates this into its own batch, ensuring it completes
-- before the table creation statements are parsed.
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'project')
BEGIN
    EXEC('CREATE SCHEMA project');
END
GO

-- Step 4: Create all the tables within the 'project' schema.
-- Each statement is separated by GO to run in its own batch for clarity and safety.

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'PLAN')
BEGIN
    CREATE TABLE project.PLAN (
        plan_id INT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        billing_cycle VARCHAR(50),
        is_family BIT,
        CONSTRAINT chk_plan_price CHECK (price >= 0)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'USER')
BEGIN
    -- Note: [USER] is in brackets because USER is a reserved keyword in SQL.
    CREATE TABLE project.[USER] (
        user_id INT PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        display_name VARCHAR(255),
        created_at DATE,
        plan_id INT,
        CONSTRAINT fk_user_subscribes_to_plan FOREIGN KEY (plan_id) REFERENCES project.PLAN(plan_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'ARTIST')
BEGIN
    CREATE TABLE project.ARTIST (
        artist_id INT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        country VARCHAR(255)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'ALBUM')
BEGIN
    CREATE TABLE project.ALBUM (
        album_id INT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        release_date DATE,
        artist_id INT,
        CONSTRAINT fk_album_creates_artist FOREIGN KEY (artist_id) REFERENCES project.ARTIST(artist_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'TRACK')
BEGIN
    CREATE TABLE project.TRACK (
        track_id INT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        duration_ms INT,
        explicit_flag BIT,
        track_number INT,
        album_id INT,
        CONSTRAINT fk_track_contains_album FOREIGN KEY (album_id) REFERENCES project.ALBUM(album_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'PLAYLIST')
BEGIN
    CREATE TABLE project.PLAYLIST (
        playlist_id INT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        created_at DATE,
        is_public BIT,
        owner_user_id INT,
        CONSTRAINT fk_playlist_owns_user FOREIGN KEY (owner_user_id) REFERENCES project.[USER](user_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'PLAYLIST_ITEM')
BEGIN
    CREATE TABLE project.PLAYLIST_ITEM (
        playlist_id INT,
        position INT,
        track_id INT,
        added_at DATE,
        added_by_user_id INT,
        PRIMARY KEY (playlist_id, position),
        CONSTRAINT fk_playlist_item_appears_in_playlist FOREIGN KEY (playlist_id) REFERENCES project.PLAYLIST(playlist_id),
        CONSTRAINT fk_playlist_item_has_track FOREIGN KEY (track_id) REFERENCES project.TRACK(track_id),
        CONSTRAINT fk_playlist_item_added_by_user FOREIGN KEY (added_by_user_id) REFERENCES project.[USER](user_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'LISTEN')
BEGIN
    CREATE TABLE project.LISTEN (
        listen_id INT PRIMARY KEY,
        user_id INT,
        track_id INT,
        played_at DATETIME,
        ms_played INT,
        device_type VARCHAR(255),
        CONSTRAINT fk_listen_plays_user FOREIGN KEY (user_id) REFERENCES project.[USER](user_id),
        CONSTRAINT fk_listen_is_played_in_track FOREIGN KEY (track_id) REFERENCES project.TRACK(track_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'FOLLOW')
BEGIN
    CREATE TABLE project.FOLLOW (
        user_id INT,
        artist_id INT,
        followed_at DATE,
        PRIMARY KEY (user_id, artist_id),
        CONSTRAINT fk_follow_follows_user FOREIGN KEY (user_id) REFERENCES project.[USER](user_id),
        CONSTRAINT fk_follow_is_followed_by_artist FOREIGN KEY (artist_id) REFERENCES project.ARTIST(artist_id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'FRIENDSHIP')
BEGIN
    CREATE TABLE project.FRIENDSHIP (
        user_id_a INT,
        user_id_b INT,
        since DATE,
        status VARCHAR(255),
        PRIMARY KEY (user_id_a, user_id_b),
        CONSTRAINT fk_friendship_friends_user_a FOREIGN KEY (user_id_a) REFERENCES project.[USER](user_id),
        CONSTRAINT fk_friendship_friends_user_b FOREIGN KEY (user_id_b) REFERENCES project.[USER](user_id),
        CONSTRAINT chk_friendship_users CHECK (user_id_a <> user_id_b)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'USER_PROFILE')
BEGIN
    CREATE TABLE project.USER_PROFILE (
        user_id INT PRIMARY KEY,
        country VARCHAR(255),
        birthdate DATE,
        language VARCHAR(255),
        CONSTRAINT fk_user_profile_has_profile_user FOREIGN KEY (user_id) REFERENCES project.[USER](user_id)
    );
END
GO
