
USE [EC_IT143_DM];
GO
IF COL_LENGTH('dbo.t_w3_schools_customers', 'LastModifiedDate') IS NULL
    ALTER TABLE dbo.t_w3_schools_customers ADD LastModifiedDate DATETIME2(0) NULL;
IF COL_LENGTH('dbo.t_w3_schools_customers', 'LastModifiedBy') IS NULL
    ALTER TABLE dbo.t_w3_schools_customers ADD LastModifiedBy SYSNAME NULL;
GO

-- Initialize existing rows (optional)
UPDATE dbo.t_w3_schools_customers
SET LastModifiedDate = SYSDATETIME(),
    LastModifiedBy   = SUSER_SNAME();
