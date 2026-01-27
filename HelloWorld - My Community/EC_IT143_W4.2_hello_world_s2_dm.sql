--Q:What fight songs made it to the big 12 and what school are the artists from?

--A: Let's ask SQL Server and find out...

----STEPS to Answer the Question (SQL Server)
--STEP 1 — Identify which rows belong to the Big 12
--Your table has a column:[conference]

--Filter all rows where the school belongs to the Big 12:
--SQLWHERE conference LIKE '%Big 12%'Show more lines
--This gives you only the fight songs from Big 12 schools.

--STEP 2 — Identify the fight songs
--The column for the song name is: [song_name]

--So we select the fight songs along with the school:
--SQLSELECT school, song_nameShow more lines

--STEP 3 — Determine “what school the artists are from”
--Your table has a column:
--[writers]          -- writer names
--[student_writer]   -- 1 = writer was a student of the school

--STEP 4 — Select all required columns together
--Combine all of the above to return:

--the school
--the fight song
--the writers
--the artist’s school (inferred)