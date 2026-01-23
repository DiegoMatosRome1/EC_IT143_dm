
/*===============================================================================
NAME:        EC_IT143_Wk6_Answers_MatosRomero.sql
PURPOSE:     Translate user questions into SQL statements using AdventureWorks2022.

AUTHOR:      Diego Matos Romero
VERSION:     1.0
DATE:        2026-01-23
RUNTIME:     Each query typically < 3s on local SSMS; metadata queries < 1s.

NOTES:
- Target DB: AdventureWorks2022 (OLTP). Ensure you restored the .bak from Microsoft.
- Use SET NOCOUNT ON to reduce message noise in SSMS.
- Revenue uses Sales.SalesOrderDetail.LineTotal (includes UnitPriceDiscount).
- Month bucketing uses YEAR(OrderDate) and MONTH(OrderDate).
- For customer names, prefer Person.Person for individuals, Sales.Store for resellers.

REFERENCES:
- Install & restore AdventureWorks: Microsoft Learn
- INFORMATION_SCHEMA usage: Microsoft Learn
- Data dictionary / table lookups: Dataedo

===============================================================================*/
USE AdventureWorks2022;
GO
SET NOCOUNT ON;
GO

/*===============================================================================
Q1 (Marginal) — Author: Ezra
Question: "What are the top ten most expensive products by list price?"
===============================================================================*/
-- Approach: Single table (Production.Product). Order by ListPrice DESC. Handle ties deterministically with ProductID.
SELECT TOP (10)
    p.ProductID,
    p.Name,
    p.ListPrice
FROM Production.Product AS p
WHERE p.ListPrice IS NOT NULL
ORDER BY p.ListPrice DESC, p.ProductID ASC;
GO

/*===============================================================================
Q2 (Marginal) — Author: Daniel
Question: "How many employees currently hold the title 'Production Supervisor'?"
===============================================================================*/
-- Approach: Count from HumanResources.Employee. "Current" approximated by CurrentFlag = 1.
SELECT
    COUNT(*) AS ProductionSupervisorCount
FROM HumanResources.Employee AS e
WHERE e.JobTitle = N'Production Supervisor'
  AND e.CurrentFlag = 1;
GO

/*===============================================================================
Q3 (Moderate) — Author: Ezra
Question: 
"I want to see customer names and their total number of orders. 
 Please list only customers who have placed more than five orders and 
 sort the results by total orders descending."
===============================================================================*/
-- Approach:
-- 1) Start from Sales.SalesOrderHeader to count orders per CustomerID.
-- 2) Derive display name:
--    - If Customer is an individual, join to Person.Person via Sales.Customer.PersonID.
--    - If a store, join to Sales.Store via Sales.Customer.StoreID.
WITH OrdersPerCustomer AS
(
    SELECT soh.CustomerID, COUNT(*) AS OrderCount
    FROM Sales.SalesOrderHeader AS soh
    GROUP BY soh.CustomerID
    HAVING COUNT(*) > 5
)
SELECT
    opc.CustomerID,
    COALESCE(pp.FirstName + N' ' + pp.LastName, s.Name) AS CustomerName,
    opc.OrderCount
FROM OrdersPerCustomer AS opc
JOIN Sales.Customer AS c
    ON c.CustomerID = opc.CustomerID
LEFT JOIN Person.Person AS pp
    ON pp.BusinessEntityID = c.PersonID
LEFT JOIN Sales.Store AS s
    ON s.BusinessEntityID = c.StoreID
ORDER BY opc.OrderCount DESC, CustomerName ASC;
GO

/*===============================================================================
Q4 (Moderate) — Author: Daniel
Question: 
"Which salespersons generated the highest total sales in 2013? 
 Include their first name, last name, and total sales amount."
===============================================================================*/
-- Approach:
-- 1) Filter Sales.SalesOrderHeader by OrderDate in 2013 and SalesPersonID NOT NULL.
-- 2) Sum TotalDue by SalesPersonID.
-- 3) Join to Person.Person for names through BusinessEntityID.
SELECT TOP (10)  -- can remove TOP if full list desired
    sp.BusinessEntityID AS SalesPersonID,
    p.FirstName,
    p.LastName,
    SUM(soh.TotalDue) AS TotalSales2013
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesPerson AS sp
    ON sp.BusinessEntityID = soh.SalesPersonID
JOIN Person.Person AS p
    ON p.BusinessEntityID = sp.BusinessEntityID
WHERE soh.OrderDate >= '2013-01-01'
  AND soh.OrderDate <  '2014-01-01'
GROUP BY sp.BusinessEntityID, p.FirstName, p.LastName
ORDER BY TotalSales2013 DESC, SalesPersonID ASC;
GO

/*===============================================================================
Q5 (Increased) — Author: Ezra
Question:
"Management wants to analyze internet sales performance for 2013. 
 Create a report that shows total sales amount by month and by sales territory. 
 The report should include the territory name, order month, total sales, and number of orders."
===============================================================================*/
-- Approach:
-- 1) Internet sales = OnlineOrderFlag = 1.
-- 2) Bucket by YEAR(OrderDate), MONTH(OrderDate). Restrict to 2013.
-- 3) Join Sales.SalesTerritory for Territory Name.
SELECT
    st.Name AS TerritoryName,
    YEAR(soh.OrderDate) AS OrderYear,
    MONTH(soh.OrderDate) AS OrderMonth,
    SUM(soh.TotalDue) AS TotalSalesAmount,
    COUNT(*)           AS OrderCount
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesTerritory AS st
    ON st.TerritoryID = soh.TerritoryID
WHERE soh.OnlineOrderFlag = 1
  AND soh.OrderDate >= '2013-01-01'
  AND soh.OrderDate <  '2014-01-01'
GROUP BY st.Name, YEAR(soh.OrderDate), MONTH(soh.OrderDate)
ORDER BY st.Name ASC, OrderYear, OrderMonth;
GO

/*===============================================================================
Q6 (Increased) — Author: Daniel
Question:
"I need to analyze bicycle sales by subcategory for Q2 2013. 
 Show me subcategory name, total quantity sold, total revenue, and average discount given per order."
===============================================================================*/
-- Approach:
-- 1) Restrict to products where ProductCategory = 'Bikes'.
-- 2) Q2 2013 = 2013-04-01 thru 2013-06-30 (inclusive).
-- 3) Total revenue = SUM(LineTotal).
-- 4) "Average discount per order": first compute average line-level discount per SOH, 
--    then average that across orders within each subcategory (to avoid line bias).
WITH BikeProducts AS
(
    SELECT p.ProductID, psc.ProductSubcategoryID, psc.Name AS SubcategoryName
    FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS psc
      ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
      ON pc.ProductCategoryID = psc.ProductCategoryID
    WHERE pc.Name = N'Bikes'
),
Q2Lines AS
(
    SELECT sod.SalesOrderID, sod.ProductID, sod.OrderQty, sod.LineTotal, sod.UnitPriceDiscount
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh
      ON soh.SalesOrderID = sod.SalesOrderID
    WHERE soh.OrderDate >= '2013-04-01'
      AND soh.OrderDate <  '2013-07-01'
)
, OrderDiscountBySubcategory AS
(
    -- per order, per subcategory average discount (line-level mean)
    SELECT
        q.SalesOrderID,
        bp.ProductSubcategoryID,
        AVG(CAST(q.UnitPriceDiscount AS decimal(6,4))) AS AvgDiscountPerOrderSubcat
    FROM Q2Lines AS q
    JOIN BikeProducts AS bp
      ON bp.ProductID = q.ProductID
    GROUP BY q.SalesOrderID, bp.ProductSubcategoryID
)
SELECT
    bp.SubcategoryName,
    SUM(q.OrderQty)             AS TotalQuantitySold,
    SUM(q.LineTotal)            AS TotalRevenue,
    AVG(od.AvgDiscountPerOrderSubcat) AS AvgDiscountPerOrder  -- 0.00 .. 1.00
FROM Q2Lines AS q
JOIN BikeProducts AS bp
  ON bp.ProductID = q.ProductID
JOIN OrderDiscountBySubcategory AS od
  ON od.SalesOrderID = q.SalesOrderID
 AND od.ProductSubcategoryID = bp.ProductSubcategoryID
GROUP BY bp.SubcategoryName
ORDER BY bp.SubcategoryName ASC;
GO

/*===============================================================================
Q7 (Metadata) — Author: Ezra
Question: "Which tables in the AdventureWorks database contain a column named ProductID?"
===============================================================================*/
-- Approach: INFORMATION_SCHEMA.COLUMNS filtered by COLUMN_NAME = 'ProductID'.
SELECT DISTINCT
    c.TABLE_SCHEMA,
    c.TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS AS c
WHERE c.COLUMN_NAME = N'ProductID'
ORDER BY c.TABLE_SCHEMA, c.TABLE_NAME;
GO

/*===============================================================================
Q8 (Metadata) — Author: Daniel
Question: "List all columns in the Sales schema that have a data type of money."
===============================================================================*/
-- Approach: INFORMATION_SCHEMA.COLUMNS filtered by TABLE_SCHEMA = 'Sales' and DATA_TYPE = 'money'.
SELECT
    c.TABLE_SCHEMA,
    c.TABLE_NAME,
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS AS c
WHERE c.TABLE_SCHEMA = N'Sales'
  AND c.DATA_TYPE    = N'money'
ORDER BY c.TABLE_NAME, c.COLUMN_NAME;
GO
