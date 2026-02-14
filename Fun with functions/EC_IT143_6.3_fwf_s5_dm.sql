
/*======================================================================
Script:    EC_IT143_6.3_fwf_s5_dm.sql
Author:    Diego Matos (dm)
Purpose:   UDF to parse FIRST name from ContactName
Version:   1.0   2026-02-13
Notes:
- Returns NULL for NULL/empty input.
- If no space is found, returns full trimmed value.
======================================================================*/
USE [EC_IT143_DM];
GO
IF OBJECT_ID('dbo.udf_parse_first_name', 'FN') IS NOT NULL
    DROP FUNCTION dbo.udf_parse_first_name;
GO
CREATE FUNCTION dbo.udf_parse_first_name (@combined_name NVARCHAR(500))
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @n NVARCHAR(500) = LTRIM(RTRIM(@combined_name));
    IF @n IS NULL OR @n = '' RETURN NULL;

    DECLARE @pos INT = CHARINDEX(' ', @n + ' ');  -- guarantees a space
    RETURN LEFT(@n, @pos - 1);
END
GO
