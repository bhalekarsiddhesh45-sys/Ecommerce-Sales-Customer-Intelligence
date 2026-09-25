/* Build a clean view instead of deleting rows*/
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

/* Step 5: Star Schema (optional but recommended — shows data modeling skill)*/
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
SELECT * FROM retail_clean;

/*Fact vs Dimension:* A **fact table** holds numeric, transactional measures at the lowest grain (one row per invoice line: quantity, price, revenue) and foreign keys
 into dimensions. A **dimension table** holds descriptive attributes (product name, country, calendar attributes) that you filter and group by. This structure matters because
 it avoids repeating descriptive text millions of times, makes joins predictable, and is exactly the pattern Power BI expects for a clean data model (star schema) later.*/
