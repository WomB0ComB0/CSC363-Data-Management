-- Step 1: Create the Database if it doesn't exist
USE [master];
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'MusicStreamDB')
BEGIN
    CREATE DATABASE [MusicStreamDB];
END
GO

-- Step 2: Switch to the context of your new database
USE [MusicStreamDB];
GO

-- Step 3: Create the schema if it does not exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'project')
BEGIN
    EXEC('CREATE SCHEMA project');
END
GO

-- Step 4: Create all required tables and relationships

-- Entities from the Rubric --

-- GENRE Table (New)
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'GENRE')
BEGIN
    CREATE TABLE project.GENRE (
        genre_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(255) UNIQUE NOT NULL
    );
END
GO

-- LABEL Table (New)
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'LABEL')
BEGIN
    CREATE TABLE project.LABEL (
        label_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(255) NOT NULL
    );
END
GO

-- ARTIST Table
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'ARTIST')
BEGIN
    CREATE TABLE project.ARTIST (
        artist_id INT PRIMARY KEY IDENTITY(1,1),
        name VARCHAR(255) NOT NULL,
        country VARCHAR(255)
    );
END
GO

-- RELEASE Table (Renamed from ALBUM)
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'RELEASE')
BEGIN
    CREATE TABLE project.[RELEASE] (
        release_id INT PRIMARY KEY IDENTITY(1,1),
        title VARCHAR(255) NOT NULL,
        release_date DATE,
        -- Relationship: PUBLISHES (1-to-many from LABEL to RELEASE)
        label_id INT,
        -- Relationship: PRIMARY_ARTIST (1-to-many from ARTIST to RELEASE)
        primary_artist_id INT,
        CONSTRAINT fk_release_publishes_label FOREIGN KEY (label_id) REFERENCES project.LABEL(label_id),
        CONSTRAINT fk_release_primary_artist_artist FOREIGN KEY (primary_artist_id) REFERENCES project.ARTIST(artist_id)
    );
END
GO

-- TRACK Table
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'TRACK')
BEGIN
    CREATE TABLE project.TRACK (
        track_id INT PRIMARY KEY IDENTITY(1,1),
        title VARCHAR(255) NOT NULL,
        duration_ms INT,
        explicit_flag BIT,
        -- Relationship: IS_ON (1-to-many from RELEASE to TRACK)
        release_id INT,
        CONSTRAINT fk_track_is_on_release FOREIGN KEY (release_id) REFERENCES project.[RELEASE](release_id)
    );
END
GO

-- APP_USER Table (named [USER])
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'USER')
BEGIN
    CREATE TABLE project.[USER] (
        user_id INT PRIMARY KEY IDENTITY(1,1),
        email VARCHAR(255) UNIQUE NOT NULL,
        display_name VARCHAR(255),
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- USER_PROFILE Table
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'USER_PROFILE')
BEGIN
    CREATE TABLE project.USER_PROFILE (
        user_id INT PRIMARY KEY,
        country VARCHAR(255),
        birthdate DATE,
        language VARCHAR(255),
        CONSTRAINT fk_user_profile_has_profile_user FOREIGN KEY (user_id) REFERENCES project.[USER](user_id) ON DELETE CASCADE
    );
END
GO

-- PLAYLIST Table
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'PLAYLIST')
BEGIN
    CREATE TABLE project.PLAYLIST (
        playlist_id INT PRIMARY KEY IDENTITY(1,1),
        title VARCHAR(255) NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        is_public BIT DEFAULT 1,
        -- Relationship: OWNS (1-to-many from USER to PLAYLIST)
        owner_user_id INT,
        CONSTRAINT fk_playlist_owns_user FOREIGN KEY (owner_user_id) REFERENCES project.[USER](user_id)
    );
END
GO

-- Associative Tables for Many-to-Many Relationships --

-- PERFORMED_BY Relationship (Track <-> Artist)
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'TRACK_ARTIST')
BEGIN
    CREATE TABLE project.TRACK_ARTIST (
        track_id INT,
        artist_id INT,
        PRIMARY KEY (track_id, artist_id),
        CONSTRAINT fk_trackartist_performed_by_track FOREIGN KEY (track_id) REFERENCES project.TRACK(track_id),
        CONSTRAINT fk_trackartist_performed_by_artist FOREIGN KEY (artist_id) REFERENCES project.ARTIST(artist_id)
    );
END
GO

-- MEMBER_OF Relationship (Artist <-> Artist, for bands)
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'BAND_MEMBER')
BEGIN
    CREATE TABLE project.BAND_MEMBER (
        band_artist_id INT,
        member_artist_id INT,
        PRIMARY KEY (band_artist_id, member_artist_id),
        CONSTRAINT fk_bandmember_member_of_band FOREIGN KEY (band_artist_id) REFERENCES project.ARTIST(artist_id),
        CONSTRAINT fk_bandmember_member_of_member FOREIGN KEY (member_artist_id) REFERENCES project.ARTIST(artist_id),
        CONSTRAINT chk_band_member_is_not_self CHECK (band_artist_id <> member_artist_id)
    );
END
GO

-- SAVES Relationship (User <-> Track)
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'SAVED_TRACK')
BEGIN
    CREATE TABLE project.SAVED_TRACK (
        user_id INT,
        track_id INT,
        saved_at DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (user_id, track_id),
        CONSTRAINT fk_savedtrack_saves_user FOREIGN KEY (user_id) REFERENCES project.[USER](user_id),
        CONSTRAINT fk_savedtrack_saves_track FOREIGN KEY (track_id) REFERENCES project.TRACK(track_id)
    );
END
GO

-- FOLLOWS (user/artist) Relationship
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'ARTIST_FOLLOWER')
BEGIN
    CREATE TABLE project.ARTIST_FOLLOWER (
        user_id INT,
        artist_id INT,
        followed_at DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (user_id, artist_id),
        CONSTRAINT fk_artistfollower_follows_user FOREIGN KEY (user_id) REFERENCES project.[USER](user_id),
        CONSTRAINT fk_artistfollower_follows_artist FOREIGN KEY (artist_id) REFERENCES project.ARTIST(artist_id)
    );
END
GO

-- FOLLOWS (user/playlist) Relationship (New)
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'PLAYLIST_FOLLOWER')
BEGIN
    CREATE TABLE project.PLAYLIST_FOLLOWER (
        user_id INT,
        playlist_id INT,
        followed_at DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (user_id, playlist_id),
        CONSTRAINT fk_playlistfollower_follows_user FOREIGN KEY (user_id) REFERENCES project.[USER](user_id),
        CONSTRAINT fk_playlistfollower_follows_playlist FOREIGN KEY (playlist_id) REFERENCES project.PLAYLIST(playlist_id)
    );
END
GO

-- CONTAINS Relationship (Playlist <-> Track)
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'PLAYLIST_ITEM')
BEGIN
    CREATE TABLE project.PLAYLIST_ITEM (
        playlist_id INT,
        track_id INT,
        position INT,
        added_at DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (playlist_id, track_id),
        CONSTRAINT fk_playlistitem_contains_playlist FOREIGN KEY (playlist_id) REFERENCES project.PLAYLIST(playlist_id),
        CONSTRAINT fk_playlistitem_contains_track FOREIGN KEY (track_id) REFERENCES project.TRACK(track_id)
    );
END
GO

-- TAGGED_WITH Relationship (Track <-> Genre)
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'project' AND t.name = 'TRACK_GENRE')
BEGIN
    CREATE TABLE project.TRACK_GENRE (
        track_id INT,
        genre_id INT,
        PRIMARY KEY (track_id, genre_id),
        CONSTRAINT fk_trackgenre_taggedwith_track FOREIGN KEY (track_id) REFERENCES project.TRACK(track_id),
        CONSTRAINT fk_trackgenre_taggedwith_genre FOREIGN KEY (genre_id) REFERENCES project.GENRE(genre_id)
    );
END
GO
