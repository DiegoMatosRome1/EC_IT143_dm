/*****************************************************************************************************************
NAME:    Diego Matos Romero
PURPOSE: Find the Big 12 fight songs with the right information

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     01/26/2026   DMatos     1. Built this script for EC IT440


RUNTIME: 
3m 3s

NOTES: 
This is script helps me find the Big 12 fight songs and infers the artist’s school when the writer was a student.
 
******************************************************************************************************************/

-- Q1: What fight songs made it to the big 12 and what school are the artists from?
-- A1: Let's ask SQL Server and find out...

TRUNCATE TABLE dbo.tbl_fight_songs_big12;
GO

INSERT INTO dbo.tbl_fight_songs_big12
(
    school,
    song_name,
    writers,
    year
)
SELECT
    school,
    song_name,
    writers,
    year
FROM dbo.vw_fight_songs_big12;
GO