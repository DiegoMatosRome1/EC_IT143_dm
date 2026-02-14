
USE [EC_IT143_DM];
GO
WITH s AS (
    SELECT
        t.CustomerID,
        t.ContactName,
        LEFT(LTRIM(RTRIM(t.ContactName)),
             NULLIF(CHARINDEX(' ', LTRIM(RTRIM(t.ContactName)) + ' '), 0) - 1) AS first_name_adhoc,
        dbo.udf_parse_first_name(t.ContactName) AS first_name_udf
    FROM dbo.t_w3_schools_customers AS t
)
SELECT *
FROM s
WHERE first_name_adhoc <> first_name_udf
   OR (first_name_adhoc IS NULL AND first_name_udf IS NOT NULL)
   OR (first_name_adhoc IS NOT NULL AND first_name_udf IS NULL);
-- Expected: 0 rows
