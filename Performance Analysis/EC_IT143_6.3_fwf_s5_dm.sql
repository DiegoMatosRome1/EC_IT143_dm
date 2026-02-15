
USE [EC_IT143_DM];
GO
DECLARE @id INT = (SELECT MIN(CustomerID) FROM dbo.t_w3_schools_customers);

-- Before
SELECT CustomerID, ContactName, LastModifiedDate, LastModifiedBy
FROM dbo.t_w3_schools_customers
WHERE CustomerID = @id;

-- Update (make a small reversible change)
UPDATE dbo.t_w3_schools_customers
SET ContactName = RTRIM(ContactName + ' ')
WHERE CustomerID = @id;

-- After
SELECT CustomerID, ContactName, LastModifiedDate, LastModifiedBy
FROM dbo.t_w3_schools_customers
WHERE CustomerID = @id;

-- Revert (cleanup)
UPDATE dbo.t_w3_schools_customers
SET ContactName = RTRIM(ContactName)
WHERE CustomerID = @id;
