/*
===============================================================================
Project: Retail Store Sales Performance Analysis
Script: 01_data_cleaning.sql

OBJECTIVE
Assess data quality and prepare retail transaction data for reliable
exploratory data analysis.

SCOPE
1. Transaction uniqueness and duplicate checks
2. Missing-value profiling
3. Standardization (Data types, Invalid-value)
5. Price_Per_Unit Column reconstruction
6. Impossible 
6. Post-cleaning validation
*/
-- ============================================================================
-- 1. INITIAL DATA PROFILING
-- ============================================================================

SELECT *
FROM retail_store_sales;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Transaction_ID) AS Unique_Transactions,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Item) AS Unique_Items
FROM retail_store_sales;
-- ============================================================================
-- 2. TRANSACTION ID UNIQUENESS CHECK
-- ============================================================================

SELECT
    Transaction_ID,
    COUNT(*) AS Transaction_Count
FROM retail_store_sales
GROUP BY Transaction_ID
HAVING COUNT(*) > 1;

-- Interpretation:
-- No returned rows means no Duplicate Transaction_ID values were found.
-- ============================================================================
-- 3. INITIAL MISSING-VALUE ASSESSMENT
-- ============================================================================

SELECT
    SUM(CASE
        WHEN Transaction_ID IS NULL
          OR TRIM(CONVERT(VARCHAR(100), Transaction_ID)) = ''
        THEN 1 ELSE 0
    END) AS Missing_Transaction_ID,

    SUM(CASE
        WHEN Transaction_Date IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Transaction_Date,

    SUM(CASE
        WHEN Customer_ID IS NULL
          OR TRIM(CONVERT(VARCHAR(100), Customer_ID)) = ''
        THEN 1 ELSE 0
    END) AS Missing_Customer_ID,

    SUM(CASE
        WHEN Item IS NULL OR TRIM(Item) = ''
        THEN 1 ELSE 0
    END) AS Missing_Item,

    SUM(CASE
        WHEN Category IS NULL OR TRIM(Category) = ''
        THEN 1 ELSE 0
    END) AS Missing_Category,

    SUM(CASE
        WHEN Quantity IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Quantity,

    SUM(CASE
        WHEN Price_Per_Unit IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Price,

    SUM(CASE
        WHEN Total_Spent IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Total_Spent

FROM retail_store_sales;


-- ============================================================================
-- 4. STANDARDIZE BLANK VALUES IN TEXT COLUMNS
-- ============================================================================

UPDATE retail_store_sales
SET Item = NULL
WHERE Item IS NOT NULL
  AND TRIM(Item) = '';

UPDATE retail_store_sales
SET Category = NULL
WHERE Category IS NOT NULL
  AND TRIM(Category) = '';

UPDATE retail_store_sales
SET Customer_ID = NULL
WHERE Customer_ID IS NOT NULL
  AND TRIM(Customer_ID) = '';

UPDATE retail_store_sales
SET Transaction_ID = NULL
WHERE Transaction_ID IS NOT NULL
  AND TRIM(Transaction_ID) = '';

UPDATE retail_store_sales
SET Payment_Method = NULL
WHERE Payment_Method IS NOT NULL
  AND TRIM(Payment_Method) = '';

UPDATE retail_store_sales
SET Location = NULL
WHERE Location IS NOT NULL
  AND TRIM(Location) = '';

  -- ============================================================================
-- 5. NORMALIZE BLANK NUMERIC VALUES BEFORE TYPE CONVERSION
-- ============================================================================

 UPDATE retail_store_sales
 SET Quantity = NULL
 WHERE TRIM(Quantity) = '';

 UPDATE retail_store_sales
 SET Total_Spent = NULL
 WHERE TRIM(Total_Spent) = '';

 UPDATE retail_store_sales
 SET Price_Per_Unit = NULL
 WHERE TRIM(Price_Per_Unit) = '';

-- ============================================================================
-- 6. STANDARDIZE DATA TYPES
-- ============================================================================

    ALTER TABLE retail_store_sales
    ALTER COLUMN Quantity DECIMAL(18,2);

    ALTER TABLE retail_store_sales
    ALTER COLUMN Total_Spent DECIMAL(18,2);

    ALTER TABLE retail_store_sales
    ALTER COLUMN Price_Per_Unit DECIMAL(18,2);

    ALTER TABLE retail_store_sales
    ALTER COLUMN Transaction_Date DATE;
-- ============================================================================
-- 7.MISSING UNIT PRICES RECONSTRUCTION
-- Total_Spent / Quantity
-- ============================================================================

SELECT
    Transaction_ID,
    Quantity,
    Total_Spent,
    Price_Per_Unit,
    CAST(
        Total_Spent / NULLIF(Quantity, 0)
        AS DECIMAL(18,2)
    ) AS Calculated_Price_Per_Unit
FROM retail_store_sales
WHERE Quantity > 0
  AND Total_Spent IS NOT NULL
  AND Price_Per_Unit IS NULL;

UPDATE retail_store_sales
SET Price_Per_Unit = CAST(
    Total_Spent / NULLIF(Quantity, 0)
    AS DECIMAL(18,2)
)
WHERE Quantity > 0
  AND Total_Spent IS NOT NULL
  AND Price_Per_Unit IS NULL;
-- ============================================================================
-- 8. VALIDATE IMPOSSIBLE OR UNUSUAL VALUES
-- Check if Quantity, Price_Per_Unit,Total_Spent Have negative values
-- ============================================================================
SELECT *
FROM retail_store_sales
WHERE Quantity < 0
   OR Price_Per_Unit < 0
   OR Total_Spent < 0;
-- ============================================================================
-- 9. POST-CLEANING VALIDATION
-- Check missing values .
-- ============================================================================
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Transaction_ID) AS Unique_Transactions,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Item) AS Unique_Items
FROM retail_store_sales;


