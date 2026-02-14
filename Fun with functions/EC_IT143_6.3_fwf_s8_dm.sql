
USE [EC_IT143_DM];
GO
-- 8.1 Ad hoc for LAST name (NULL if single-word)
SELECT
    t.ContactName,
    NULLIF(SUBSTRING(LTRIM(RTRIM(t.ContactName)),
                     NULLIF(CHARINDEX(' ', LTRIM(RTRIM(t.ContactName)) + ' '), 0) + 1,
                     4000), '') AS last_name
FROM dbo.t_w3_schools_customers AS t
ORDER BY 1;

-- 8.2 Create UDF for LAST name
IF OBJECT_ID('dbo.udf_parse_last_name', 'FN') IS NOT NULL
    DROP FUNCTION dbo.udf_parse_last_name;
GO
CREATE FUNCTION dbo.udf_parse_last_name (@combined_name NVARCHAR(500))
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @n NVARCHAR(500) = LTRIM(RTRIM(@combined_name));
    IF @n IS NULL OR @n = '' RETURN NULL;

    DECLARE @pos INT = CHARINDEX(' ', @n);
    IF @pos = 0 RETURN NULL;  -- single-word => no last name

    RETURN NULLIF(LTRIM(SUBSTRING(@n, @pos + 1, 4000)), '');
END
GO

-- 8.3 Compare (expect 0 diffs)
WITH ad_hoc AS (
    SELECT
        t.CustomerID,
        t.ContactName,
        NULLIF(SUBSTRING(LTRIM(RTRIM(t.ContactName)),
                         NULLIF(CHARINDEX(' ', LTRIM(RTRIM(t.ContactName)) + ' '), 0) + 1,
                         4000), '') AS last_name_adhoc
    FROM dbo.t_w3_schools_customers AS t
),
udf AS (
    SELECT
        t.CustomerID,
        dbo.udf_parse_last_name(t.ContactName) AS last_name_udf
    FROM dbo.t_w3_schools_customers AS t
)
SELECT a.ContactName, a.last_name_adhoc, u.last_name_udf
FROM ad_hoc a
JOIN udf u ON u.CustomerID = a.CustomerID
WHERE a.last_name_adhoc <> u.last_name_udf
   OR (a.last_name_adhoc IS NULL AND u.last_name_udf IS NOT NULL)
   OR (a.last_name_adhoc IS NOT NULL AND u.last_name_udf IS NULL);
-- Expected: 0 rows
