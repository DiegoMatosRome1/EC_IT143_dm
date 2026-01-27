/*****************************************************************************************************************
NAME:    Diego Matos Romero
PURPOSE: Find the Big 12 fight songs with the right information

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     01/26/2026   DMatos     1. Turn the ad hoc SQL query into a view


RUNTIME: 
3m 3s

NOTES: 
This is script helps me find the Big 12 fight songs and infers the artist’s school when the writer was a student.
 
******************************************************************************************************************/

-- Q1: What fight songs made it to the big 12 and what school are the artists from?
-- A1: Let's ask SQL Server and find out...


SELECT
    fs.school,
    fs.song_name,
    fs.writers,
    fs.year
FROM [EC_IT143_DM].[dbo].[fight-songs] AS fs
WHERE fs.conference LIKE '%Big 12%'
ORDER BY fs.school, fs.song_name;
