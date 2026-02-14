
-- Testing shape variations of ContactName using the same ad hoc logic.
USE [EC_IT143_DM];
GO
WITH s AS (
    SELECT ContactName
    FROM dbo.t_w3_schools_customers
)
SELECT
    ContactName,
    LEFT(LTRIM(RTRIM(ContactName)),
         NULLIF(CHARINDEX(' ', LTRIM(RTRIM(ContactName)) + ' '), 0) - 1) AS first_name_test
FROM s
ORDER BY 1;
