
/*======================================================================
Script:    EC_IT143_6.3_fwt_s4_dm.sql
Author:    Diego Matos (dm)
Purpose:   Stamp LastModifiedDate & LastModifiedBy after any UPDATE
Version:   1.0   2026-02-13
======================================================================*/
USE [EC_IT143_DM];
GO
IF OBJECT_ID('dbo.trg_t_w3_schools_customers_lastmodified', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_t_w3_schools_customers_lastmodified;
GO
CREATE TRIGGER dbo.trg_t_w3_schools_customers_lastmodified
ON dbo.t_w3_schools_customers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE t
        SET t.LastModifiedDate = SYSDATETIME(),
            t.LastModifiedBy   = COALESCE(ORIGINAL_LOGIN(), SUSER_SNAME())
    FROM dbo.t_w3_schools_customers AS t
    INNER JOIN inserted AS i
        ON i.CustomerID = t.CustomerID;
END
GO
