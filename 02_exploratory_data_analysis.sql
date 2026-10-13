/*
===============================================================================
Project: Retail Store Sales Performance Analysis
Script: 02_exploratory_data_analysis.sql

OBJECTIVE
Analyze retail sales performance, customer purchasing behavior, temporal
trends, payment preferences, and patterns in incomplete transaction records.

SCOPE
1. Overall sales KPIs
2. Category and product performance
3. Location  and Payment method analysis
4. Annual and monthly trends
5. Customer spending and purchase frequency
6. MISSING transaction analysis
*/
-- ============================================================================
--  OVERALL SALES KPIs
-- ============================================================================
SELECT
COUNT(*) AS Total_Records,
COUNT(Total_Spent) AS Records_With_Sales_Amount,
COUNT(*) - COUNT(Total_Spent) AS Records_Missing_Sales_Amount,
SUM(Total_Spent) AS Total_Revenue,
AVG(Total_Spent) AS Average_Transaction_Value,
COUNT(DISTINCT Customer_ID) AS Unique_Customers
FROM retail_store_sales;

-- ============================================================================
-- CATEGORY ANALYSIS
-- ============================================================================
--Category that generated the highest revenue and sold highest quantities


SELECT
Category,
SUM(Total_Spent) AS Revenue_Amount,
SUM(Quantity) AS Total_Quantity_Sold,
COUNT(*) AS Total_Records,
COUNT(Total_Spent) AS Records_With_Sales_Amount,
CAST(100.0 * SUM(Total_Spent)/ NULLIF(SUM(SUM(Total_Spent)) OVER (), 0)AS DECIMAL(10,2)) AS Revenue_Contribution_Percent,
DENSE_RANK() OVER (ORDER BY SUM(Total_Spent) DESC) AS Revenue_Rank,
DENSE_RANK() OVER (ORDER BY SUM(Quantity) DESC) AS Quantity_Rank
FROM retail_store_sales
GROUP BY Category
ORDER BY Revenue_Amount DESC;

-- ============================================================================
--  ITEM PERFORMANCE ANALYSIS
-- ============================================================================
--Top 10 items by revenue amount
SELECT TOP (10)
Item,
Category,
SUM(Total_Spent) AS Revenue_Amount,
SUM(Quantity) AS Total_Quantity_Sold,
COUNT(*) AS Total_Records
FROM retail_store_sales
WHERE Total_Spent IS NOT NULL
GROUP BY Item, Category
ORDER BY Revenue_Amount DESC;

--Top 10 items by quantity sold

SELECT TOP (10)
Item,
Category,
SUM(Quantity) AS Total_Quantity_Sold,
SUM(Total_Spent) AS Revenue_Amount
FROM retail_store_sales
WHERE Quantity IS NOT NULL
GROUP BY Item, Category
ORDER BY Total_Quantity_Sold DESC;

-- ============================================================================
-- LOCATION PERFORMANCE
-- ============================================================================

-- Compare revenue, transaction records, and average transaction value
SELECT
Location,
SUM(Total_Spent) AS Total_Revenue,
COUNT(Total_Spent) AS Records_With_Sales_Amount,
AVG(Total_Spent) AS Average_Transaction_Value,
CAST(100.0 * SUM(Total_Spent)/ NULLIF(SUM(SUM(Total_Spent)) OVER (), 0)AS DECIMAL(10,2)) AS Revenue_Contribution_Percent,
DENSE_RANK() OVER (ORDER BY SUM(Total_Spent) DESC) AS Revenue_Rank
FROM retail_store_sales
GROUP BY Location
ORDER BY Total_Revenue DESC;

-- ============================================================================
-- PAYMENT METHOD PERFORMANCE
-- ============================================================================

-- Compare payment methods by revenue, recorded sales count, and average value
SELECT
Payment_Method,
SUM(Total_Spent) AS Total_Revenue,
COUNT(Total_Spent) AS Records_With_Sales_Amount,
AVG(Total_Spent) AS Average_Transaction_Value,
CAST(100.0 * SUM(Total_Spent)/ NULLIF(SUM(SUM(Total_Spent)) OVER (), 0)AS DECIMAL(10,2)) AS Revenue_Contribution_Percent,
DENSE_RANK() OVER (ORDER BY SUM(Total_Spent) DESC) AS Revenue_Rank
FROM retail_store_sales
GROUP BY Payment_Method
ORDER BY Total_Revenue DESC;

-- ============================================================================
-- ANNUAL SALES TRENDS
-- ============================================================================

SELECT
YEAR(Transaction_Date) AS Sales_Year,
SUM(Total_Spent) AS Total_Revenue,
SUM(Quantity) AS Total_Quantity_Sold,
COUNT(Total_Spent) AS Records_With_Sales_Amount,
AVG(Total_Spent) AS Average_Transaction_Value
FROM retail_store_sales
GROUP BY YEAR(Transaction_Date)
ORDER BY Sales_Year;

-- ============================================================================
--  MONTHLY SALES TRENDS
-- ============================================================================

-- Rank months within each year by revenue
SELECT
YEAR(Transaction_Date) AS Sales_Year,
MONTH(Transaction_Date) AS Sales_Month,
SUM(Total_Spent) AS Total_Revenue,
SUM(Quantity) AS Total_Quantity_Sold,
COUNT(Total_Spent) AS Records_With_Sales_Amount,
RANK() OVER (PARTITION BY YEAR(Transaction_Date)ORDER BY SUM(Total_Spent) DESC) AS Revenue_Rank_Within_Year
FROM retail_store_sales
GROUP BY
YEAR(Transaction_Date),
MONTH(Transaction_Date)
ORDER BY
Sales_Year,
Sales_Month;


-- ============================================================================
--  CUSTOMER SPENDING AND PURCHASE FREQUENCY
-- ============================================================================

-- Top 10 customers by recorded revenue
SELECT TOP (10)
Customer_ID,
SUM(Total_Spent) AS Total_Revenue,
COUNT(Total_Spent) AS Records_With_Sales_Amount,
AVG(Total_Spent) AS Average_Transaction_Value,
SUM(Quantity) AS Total_Quantity_Sold
FROM retail_store_sales
WHERE Customer_ID IS NOT NULL
GROUP BY Customer_ID
ORDER BY Total_Revenue DESC;

-- ============================================================================
--  MISSING TRANSACTIONS ANALYSIS
-- ============================================================================

SELECT
COUNT(*) AS Total_Records,
SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END)
AS Records_Missing_Quantity,
SUM(CASE WHEN Total_Spent IS NULL THEN 1 ELSE 0 END)
AS Records_Missing_Total_Spent,
SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) AS Missing_Both_Fields,
SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NOT NULL
THEN 1 ELSE 0
END) AS Missing_Quantity_Only,
SUM(CASE
WHEN Quantity IS NOT NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) AS Missing_Total_Spent_Only,
CAST(
100.0 * SUM(CASE
WHEN Quantity IS NULL OR Total_Spent IS NULL
THEN 1 ELSE 0
END) / NULLIF(COUNT(*), 0)
AS DECIMAL(10,2)
) AS Records_Missing_Either_Field_Percent
FROM retail_store_sales;

--MISSING BY CATEGORY
SELECT
Category,
COUNT(*) AS Total_Category_Records,
SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) AS Records_Missing_Both_Fields,
CAST(
100.0 * SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) / NULLIF(COUNT(*), 0)
AS DECIMAL(10,2)
) AS Missing_Both_Percent
FROM retail_store_sales
GROUP BY Category
ORDER BY Missing_Both_Percent DESC, Records_Missing_Both_Fields DESC;

--MISSING BY PAYMENT METHOD
SELECT
Location,
COUNT(*) AS Total_Location_Records,
SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) AS Records_Missing_Both_Fields,
CAST(
100.0 * SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) / NULLIF(COUNT(*), 0)
AS DECIMAL(10,2)
) AS Missing_Both_Percent
FROM retail_store_sales
GROUP BY Location
ORDER BY Missing_Both_Percent DESC, Records_Missing_Both_Fields DESC;
-- MISSING BY YEAR
SELECT
YEAR(Transaction_Date) AS Sales_Year,
COUNT(*) AS Total_Year_Records,
SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) AS Records_Missing_Both_Fields,
CAST(
100.0 * SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) / NULLIF(COUNT(*), 0)
AS DECIMAL(10,2)
) AS Missing_Both_Percent
FROM retail_store_sales
GROUP BY YEAR(Transaction_Date)
ORDER BY Sales_Year;



--  MISSING CUSTOMER Values

SELECT
Customer_ID,
COUNT(*) AS Total_Customer_Records,
SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) AS Records_Missing_Both_Fields,
CAST(
100.0 * SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) / NULLIF(COUNT(*), 0)
AS DECIMAL(10,2)
) AS Missing_Both_Percent
FROM retail_store_sales
GROUP BY Customer_ID
HAVING SUM(CASE
WHEN Quantity IS NULL AND Total_Spent IS NULL
THEN 1 ELSE 0
END) > 0
ORDER BY Missing_Both_Percent DESC, Records_Missing_Both_Fields DESC;

