--Q:What fight songs made it to the big 12 and what school are the artists from?

--A: Let's ask SQL Server and find out...

----STEPS to Answer the Question (SQL Server)
--STEP 1 — Identify which rows belong to the Big 12
--Your table has a column:
--[conference]


SELECT
    fs.school                               AS school,
    fs.song_name                            AS fight_song,
    fs.writers,
    fs.year,
    fs.student_writer,
    CASE 
        WHEN fs.student_writer = 1 THEN fs.school
        ELSE NULL
    END                                      AS artist_school_inferred
FROM [EC_IT143_DM].[dbo].[fight-songs] AS fs
WHERE fs.conference LIKE '%Big 12%'    -- handles 'Big 12', 'Big XII', etc.
ORDER BY fs.school, fs.song_name;

