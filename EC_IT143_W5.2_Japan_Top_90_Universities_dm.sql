/*****************************************************************************************************************
NAME:    EC_IT143_W5.2_Japan_Top_90_Universities_dm.sql
PURPOSE: Japan Top 90 Universities Dataset Analysis - Answering 4 Community Questions
MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/04/2026   DMatos      1. Built this script for EC IT143


RUNTIME:
<fill after execution>
NOTES:
- Source table: [dbo].[universities_info]
- Key columns observed: University_Name, National_Rank, Founded_Year, Institution_Type, Region,
  Research_Impact_Score, Intl_Student_Ratio, Employment_Rate, student_staff_ratio
- Optional columns (adjust to your schema): Total_Students, Annual_Budget_USD, World_Rank


***********************************************************************************
*******************************/


-- =========================================================
-- Q1 (Author: Diego Matos Romero)
-- Q: How do student populations compare between top-ranked and mid-ranked Japanese universities?
--    Need ranking fields + number of students.
-- A1 (Intro): Bucket by rank (Top = 1–30, Mid = 31–60) and compare student counts.
--             Replace [Total_Students] with your actual column name if different.
-- =========================================================
;WITH ranked AS (
    SELECT
        University_Name,
        CAST(National_Rank AS INT) AS National_Rank,
        CAST([Total_Students] AS BIGINT) AS Total_Students, -- <-- replace if needed
        CASE 
            WHEN CAST(National_Rank AS INT) BETWEEN 1 AND 30  THEN 'Top (1–30)'
            WHEN CAST(National_Rank AS INT) BETWEEN 31 AND 60 THEN 'Mid (31–60)'
            ELSE 'Other (61–90)'
        END AS rank_bucket
    FROM dbo.universities_info
    WHERE National_Rank IS NOT NULL
      AND [Total_Students] IS NOT NULL -- remove if not available
)
SELECT
    rank_bucket,
    COUNT(*)                                AS universities,
    SUM(Total_Students)                     AS total_students,
    CAST(AVG(CAST(Total_Students AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS avg_students,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Total_Students) 
         OVER (PARTITION BY rank_bucket) AS DECIMAL(18,2))             AS median_students
FROM ranked
GROUP BY rank_bucket
ORDER BY CASE rank_bucket WHEN 'Top (1–30)' THEN 1 WHEN 'Mid (31–60)' THEN 2 ELSE 3 END;


-- =========================================================
-- Q2 (Author: Diego Matos Romero)
-- Q: Which universities achieve the highest academic ranking relative to their annual budget?
--    Need world ranking and budget fields.
-- A2 (Intro): Compute an "efficiency" metric = rank per $ million budget (lower is better).
--             Replace [World_Rank] and [Annual_Budget_USD] with your real columns.
-- =========================================================
SELECT TOP (15)
    University_Name,
    CAST([World_Rank] AS INT)               AS World_Rank,        -- <-- replace if needed; else use National_Rank
    CAST([Annual_Budget_USD] AS DECIMAL(18,2)) AS Annual_Budget_USD, -- <-- replace if needed
    CAST([Annual_Budget_USD] / 1000000.0 AS DECIMAL(18,2)) AS Budget_Million_USD,
    CAST(CAST([World_Rank] AS FLOAT) / NULLIF([Annual_Budget_USD] / 1000000.0, 0) AS DECIMAL(18,4)) AS rank_per_million_usd
FROM dbo.universities_info
WHERE [World_Rank] IS NOT NULL
  AND [Annual_Budget_USD] IS NOT NULL
ORDER BY rank_per_million_usd ASC, World_Rank ASC;

-- If you don't have World_Rank or Budget, substitute:
--  - Use National_Rank instead of World_Rank
--  - Use a per-student proxy: rank_per_student = National_Rank / NULLIF(Total_Students,0)


-- =========================================================
-- Q3 (Author: Diego Matos Romero)
-- Q: Are there meaningful differences in rankings among universities located in different regions of Japan?
--    Need Region, University_Name, National_Rank.
-- A3 (Intro): Summarize rank statistics by Region (lower ranks are better).
-- =========================================================
;WITH base AS (
    SELECT
        Region,
        University_Name,
        CAST(National_Rank AS INT) AS National_Rank
    FROM dbo.universities_info
    WHERE Region IS NOT NULL
      AND National_Rank IS NOT NULL
)
SELECT
    Region,
    COUNT(*)                                   AS universities,
    MIN(National_Rank)                         AS best_rank,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY National_Rank) 
         OVER (PARTITION BY Region) AS INT)    AS median_rank,
    CAST(AVG(CAST(National_Rank AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_rank,
    MAX(National_Rank)                         AS worst_rank
FROM base
GROUP BY Region
ORDER BY best_rank, median_rank, avg_rank;


-- =========================================================
-- Q4 (Original author: Romel — Other Student)
-- Q: How does the employment rate vary between the different types of institutions
--    that are specifically located within the Tokyo region?
--    Need Institution_Type, Region, Employment_Rate.
-- A4 (Intro): Filter Region='Tokyo', then summarize by Institution_Type.
-- =========================================================
;WITH tokyo AS (
    SELECT
        Institution_Type,
        CAST(Employment_Rate AS DECIMAL(5,2)) AS Employment_Rate
    FROM dbo.universities_info
    WHERE Region = 'Tokyo'        -- adjust if values vary by case/collation
      AND Employment_Rate IS NOT NULL
)
SELECT
    Institution_Type,
    COUNT(*) AS universities,
    CAST(AVG(Employment_Rate) AS DECIMAL(5,2)) AS avg_employment_rate,
    MIN(Employment_Rate) AS min_employment_rate,
    MAX(Employment_Rate) AS max_employment_rate,
    CAST(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Employment_Rate) 
         OVER (PARTITION BY Institution_Type) AS DECIMAL(5,2)) AS p25,
    CAST(PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY Employment_Rate) 
         OVER (PARTITION BY Institution_Type) AS DECIMAL(5,2)) AS median,
    CAST(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Employment_Rate) 
         OVER (PARTITION BY Institution_Type) AS DECIMAL(5,2)) AS p75
FROM tokyo
GROUP BY Institution_Type
ORDER BY avg_employment_rate DESC, Institution_Type;
