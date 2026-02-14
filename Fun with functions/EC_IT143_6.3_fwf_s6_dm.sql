
USE [EC_IT143_DM];
GO
WITH ad_hoc AS (
    SELECT
        t.CustomerID,
        t.ContactName,
        LEFT(LTRIM(RTRIM(t.ContactName)),
             NULLIF(CHARINDEX(' ', LTRIM(RTRIM(t.ContactName)) + ' '), 0) - 1) AS first_name_adhoc
    FROM dbo.t_w3_schools_customers AS t
),
udf AS (
    SELECT
        t.CustomerID,
        dbo.udf_parse_first_name(t.ContactName) AS first_name_udf
    FROM dbo.t_w3_schools_customers AS t
)
SELECT a.ContactName, a.first_name_adhoc, u.first_name_udf
FROM ad_hoc a
JOIN udf u ON u.CustomerID = a.CustomerID
WHERE a.first_name_adhoc <> u.first_name_udf
   OR (a.first_name_adhoc IS NULL AND u.first_name_udf IS NOT NULL)
   OR (a.first_name_adhoc IS NOT NULL AND u.first_name_udf IS NULL);
-- Expected: 0 rows
``
