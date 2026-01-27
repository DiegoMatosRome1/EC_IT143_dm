-- Q1: What fight songs made it to the big 12 and what school are the artists from?
-- A1: Let's ask SQL Server and find out...

DROP TABLE IF EXISTS dbo.tbl_fight_songs_big12;
GO

CREATE TABLE dbo.tbl_fight_songs_big12
(
    fight_song_id INT IDENTITY(1,1) PRIMARY KEY,
    school        VARCHAR(150) NOT NULL,
    song_name     VARCHAR(200) NOT NULL,
    writers       VARCHAR(300) NULL,
    year          INT NOT NULL DEFAULT 0
);
GO