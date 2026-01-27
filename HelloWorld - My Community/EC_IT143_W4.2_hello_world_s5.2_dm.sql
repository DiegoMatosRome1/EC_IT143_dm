-- Q1: What fight songs made it to the big 12 and what school are the artists from?
-- A1: Let's ask SQL Server and find out...

SELECT
    school,
    song_name,
    writers,
    year
INTO dbo.tbl_fight_songs_big12
FROM dbo.vw_fight_songs_big12;
GO