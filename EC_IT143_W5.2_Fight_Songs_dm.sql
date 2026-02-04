/*****************************************************************************************************************
NAME:    EC_IT143_W5.2_Fight_Songs_dm.sql
PURPOSE: Fight Songs Dataset Analysis - Answering 4 Community Questions
MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/04/2026   DMatos      1. Built this script for EC IT143
RUNTIME: 
15s
NOTES: 
This script answers 4 analytical questions about the Fight Songs dataset.
Includes questions from classmates and demonstrates SQL translation skills.
RUNTIME:
<fill after execution>

- Source table: [dbo].[fight_songs]
- Expected columns: school, conference, song_name, writers, year, student_writer
- Assumptions:
  * year is INT (or convertible).
  * student_writer stores 'Yes' / 'No'. Adjust CASE if different.
  * For Q2 (states), see Variant A (state inside fight_songs) or Variant B (join to a schools table).

***********************************************************************************
*******************************/


-- =========================================================
-- Q1 (Author: Diego Matos Romero)
-- Q: How do fight songs differ across athletic conferences in terms of the years they were written?
-- A1 (Intro): Summarize song "age" by conference: counts plus min/median/avg/max year and decade distribution.
-- =========================================================
;WITH base AS (
    SELECT
        conference,
        CAST(year AS INT) AS year
    FROM dbo.fight_songs
    WHERE year IS NOT NULL
),
decades AS (
    SELECT
        conference,
        (year / 10) * 10 AS decade
    FROM base
)
-- A1a. Summary by conference with key stats (incl. median via PERCENTILE_CONT)
SELECT
    b.conference,
    COUNT(*)                                  AS song_count,
    MIN(b.year)                               AS earliest_year,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY b.year) 
         OVER (PARTITION BY b.conference) AS INT) AS median_year,
    CAST(AVG(CAST(b.year AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_year,
    MAX(b.year)                               AS newest_year
FROM base AS b
GROUP BY b.conference
ORDER BY b.conference;

-- A1b. Optional: decade-level trend per conference
SELECT
    conference,
    decade,
    COUNT(*) AS songs_in_decade
FROM decades
GROUP BY conference, decade
ORDER BY conference, decade;


-- =========================================================
-- Q2 (Author: Diego Matos Romero)
-- Q: Which U.S. states have the highest number of schools with official fight songs?
--    Need school name and state to identify regional patterns.
-- A2 (Intro): Provide two variants—use the one matching your schema.
--             Variant A: state column already in fight_songs. Variant B: join to a schools dimension.
-- =========================================================

-- ---------- Variant A: state lives in fight_songs as [state] or [location_state]
-- Top states by # of schools:
SELECT TOP (10)
    fs.[state] AS state,
    COUNT(DISTINCT fs.school) AS schools_with_fight_songs
FROM dbo.fight_songs AS fs
WHERE fs.[state] IS NOT NULL
GROUP BY fs.[state]
ORDER BY schools_with_fight_songs DESC, state;

-- Detail list (state + school):
SELECT
    fs.[state] AS state,
    fs.school
FROM dbo.fight_songs AS fs
WHERE fs.[state] IS NOT NULL
GROUP BY fs.[state], fs.school
ORDER BY state, school;

-- ---------- Variant B: join to a schools lookup if fight_songs has no state column
--   Assumes: dbo.schools(school NVARCHAR, state NVARCHAR)
--   Replace table/column names if your lookup differs.
-- Top states by # of schools:
-- SELECT TOP (10)
--     s.state,
--     COUNT(DISTINCT fs.school) AS schools_with_fight_songs
-- FROM dbo.fight_songs AS fs
-- JOIN dbo.schools      AS s  ON s.school = fs.school
-- GROUP BY s.state
-- ORDER BY schools_with_fight_songs DESC, s.state;

-- Detail list (state + school):
-- SELECT
--     s.state,
--     fs.school
-- FROM dbo.fight_songs AS fs
-- JOIN dbo.schools      AS s  ON s.school = fs.school
-- GROUP BY s.state, fs.school
-- ORDER BY s.state, fs.school;


-- =========================================================
-- Q3 (Author: Diego Matos Romero)
-- Q: How many universities have fight songs written by more than one writer, and which conferences do they belong to?
--    Need writers, school, conference.
-- A3 (Intro): Estimate writer_count by counting delimiters in [writers] (commas, ' and ', '&', '/').
--             Then filter where writer_count > 1; show summary by conference and detailed rows.
-- =========================================================
;WITH writers_norm AS (
    SELECT
        school,
        conference,
        writers,
        -- Count common delimiters and add 1. Adjust if your data uses different separators.
        1
        + (LEN(writers) - LEN(REPLACE(writers, ',', '')))
        + (LEN(writers) - LEN(REPLACE(writers, ' and ', ''))) / NULLIF(LEN(' and '),0)
        + (LEN(writers) - LEN(REPLACE(writers, '&', '')))
        + (LEN(writers) - LEN(REPLACE(writers, '/', '')))
        AS writer_count_raw
    FROM dbo.fight_songs
    WHERE writers IS NOT NULL AND LTRIM(RTRIM(writers)) <> ''
),
writers_final AS (
    SELECT
        school,
        conference,
        writers,
        CASE 
            WHEN writer_count_raw < 1 THEN 1
            ELSE writer_count_raw
        END AS writer_count
    FROM writers_norm
)
-- A3a. Summary by conference
SELECT
    conference,
    COUNT(*) FILTERED_SONGS,
    SUM(CASE WHEN writer_count > 1 THEN 1 ELSE 0 END) AS songs_with_multiple_writers
FROM writers_final
GROUP BY conference
ORDER BY songs_with_multiple_writers DESC, conference;

-- A3b. Detail list of songs with multiple writers
SELECT
    conference,
    school,
    writers,
    writer_count
FROM writers_final
WHERE writer_count > 1
ORDER BY conference, school;


-- =========================================================
-- Q4 (Original author: Zachary — Other Student)
-- Q: How do fight song characteristics differ across conferences, particularly in terms of song age
--    and whether the writers were students or professionals?
--    Need conference, year, student_writer.
-- A4 (Intro): Compute age stats and student-writer share per conference.
-- =========================================================
;WITH base AS (
    SELECT
        conference,
        CAST(year AS INT) AS year,
        CASE WHEN student_writer IN ('Yes','Y','True', '1') THEN 1 ELSE 0 END AS is_student
    FROM dbo.fight_songs
    WHERE year IS NOT NULL
)
SELECT
    conference,
    COUNT(*)                         AS song_count,
    MIN(year)                        AS earliest_year,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY year) 
         OVER (PARTITION BY conference) AS INT) AS median_year,
    CAST(AVG(CAST(year AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_year,
    MAX(year)                        AS newest_year,
    -- Age vs. current year
    CAST(AVG(DATEDIFF(YEAR, DATEFROMPARTS(year,1,1), GETDATE()) * 1.0) AS DECIMAL(10,2)) AS avg_age_years,
    SUM(is_student)                                      AS student_written_count,
    CAST(100.0 * SUM(is_student) / NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS pct_student_written
FROM base
GROUP BY conference
ORDER BY conference;
``


