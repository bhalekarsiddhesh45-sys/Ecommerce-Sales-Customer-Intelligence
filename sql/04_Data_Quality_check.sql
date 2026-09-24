##  DATA QUALITY CHECK
-- Missing CustomerID
SELECT COUNT(*) AS missing_customer_id FROM retail_staging WHERE CustomerID is NULL;

-- Duplicate line items (same invoice, product, date, qty, customer appearing more than once)
SELECT InvoiceNo, StockCode, InvoiceDate, Quantity, CustomerID, COUNT(*) AS cnt
FROM retail_staging
GROUP BY InvoiceNo, StockCode, InvoiceDate, Quantity, CustomerID
HAVING COUNT(*) > 1;

-- Negative quantities (returns)
SELECT COUNT(*) AS negative_qty_rows FROM retail_staging WHERE Quantity < 0;

-- Cancelled invoices
SELECT COUNT(DISTINCT InvoiceNo) AS cancelled_invoices
FROM retail_staging WHERE InvoiceNo LIKE 'C%';

-- Zero or negative price
SELECT COUNT(*) AS bad_price_rows FROM retail_staging WHERE UnitPrice <= 0;

-- Non-product stock codes (postage/fees/manual entries)
SELECT DISTINCT StockCode FROM retail_staging
WHERE StockCode IN ('POST','DOT','M','BANK CHARGES','C2','PADS','CRUK');

-- Blank descriptions
SELECT COUNT(*) AS blank_description FROM retail_staging WHERE Description IS NULL OR TRIM(Description) = '';

-- Date range validation
SELECT MIN(@InvoiceDate) AS earliest, MAX(@InvoiceDate) AS latest FROM retail_staging;

### Build a clean view instead of deleting rows
CREATE OR REPLACE VIEW retail_clean AS
SELECT
	InvoiceNo,StockCode,Description,Quantity,InvoiceDate,UnitPrice,CustomerID,Country,(Quantity*UnitPrice) AS Revenue,
    CASE WHEN InvoiceNo LIKE '%C' THEN 1 ELSE 0 END AS Iscancelled
FROM retail_staging
WHERE Quantity > 0
AND UnitPrice > 0
AND InvoiceNo NOT LIKE '%C'
AND StockCode NOT IN ('POST','DOT','M','BANK CHARGES','C2','PADS','CRUK'); 
SELECT * FROM retail_clean;

## Step 5: Star Schema (optional but recommended — shows data modeling skill)
CREATE TABLE dim_customer AS 
SELECT DISTINCT CustomerID,Country FROM retail_clean WHERE CustomerID IS NOT NULL; 
SELECT * FROM dim_customer;

CREATE TABLE dim_product AS 
SELECT DISTINCT StockCode,Description FROM retail_clean;
SELECT * FROM dim_product;

CREATE TABLE dim_date AS 
SELECT DISTINCT 
DATE(InvoiceDate) AS Datekey,
YEAR(InvoiceDate) AS Year,
  MONTH(InvoiceDate) AS Month,
  MONTHNAME(InvoiceDate) AS MonthName,
  DAY(InvoiceDate) AS Day,
  DAYNAME(InvoiceDate) AS DayName
FROM retail_clean;
SELECT * FROM dim_date;
SELECT * FROM dim_date;