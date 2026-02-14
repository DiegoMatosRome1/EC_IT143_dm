
USE [EC_IT143_DM];
GO
SELECT
    t.ContactName,
    LEFT(LTRIM(RTRIM(t.ContactName)),
         NULLIF(CHARINDEX(' ', LTRIM(RTRIM(t.ContactName)) + ' '), 0) - 1) AS first_name
FROM dbo.t_w3_schools_customers AS t
ORDER BY 1;
