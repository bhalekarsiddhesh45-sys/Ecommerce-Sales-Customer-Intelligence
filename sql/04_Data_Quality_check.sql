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

/*Q.1 Total Revenue */
 SELECT ROUND(SUM(Revenue),2) AS total_revenue FROM retail_clean;

/*Total Orders*/
SELECT COUNT(DISTINCT InvoiceNo) AS Total_order FROM retail_clean; 

/*Total Unique CustomerId*/
SELECT COUNT(DISTINCT CustomerID) AS total_customer FROM retail_clean;

/*Total unique product*/
SELECT COUNT(DISTINCT StockCode) AS total_product FROM retail_clean;

/* Revenue by country(top 10)*/
SELECT Country,ROUND(SUM(Revenue),2) AS revenue FROM retail_clean
GROUP BY Country ORDER BY revenue DESC LIMIT 10;

/*Ravenue By Product(top 10)*/
SELECT StockCode,Description,ROUND(SUM(Revenue),2) AS revenue FROM retail_clean
GROUP BY StockCode, Description ORDER BY revenue DESC LIMIT 10;

/*Total Quantity Sold*/
SELECT SUM(Quantity) AS total_sold_units FROM retail_clean;

/*Number of order by country*/
SELECT Country,COUNT(DISTINCT InvoiceNo) AS orders
FROM retail_clean GROUP BY Country ORDER BY orders DESC LIMIT 10;

/*Cancellation Rate*/
SELECT
	(SELECT COUNT(DISTINCT InvoiceNo) FROM retail_staging WHERE InvoiceNo LIKE 'C%' )/
    (SELECT COUNT(DISTINCT InvoiceNo) FROM retail_staging) * 100 AS Cancellation_rate;
    
/*Average unit price by product category proxy (top by avg price)*/    
SELECT StockCode,Description,ROUND(SUM(Unitprice),2)  AS avg_price
FROM retail_clean GROUP BY StockCode,Description ORDER BY avg_price DESC LIMIT 10;

/*Monthly Revenue */
SELECT DATE_FORMAT(InvoiceDate,'%Y-%m') AS year_months,ROUND(SUM(Revenue),2) AS revenue FROM retail_clean;

/*Average Order Value(AOV) overall*/
SELECT ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo),2) AS aov FROM retail_clean;

/*AOV by Country*/
SELECT Country,ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo),2) AS aov FROM retail_clean 
GROUP BY Country HAVING COUNT(DISTINCT InvoiceNo) >= 5 ORDER BY aov DESC LIMIT 10;

/*Top 10 Product by quantity Sold*/
SELECT StockCode,Description,SUM(Quantity) AS Quantity_sold FROM retail_clean 
GROUP BY StockCode,Description ORDER BY Quantity_sold DESC LIMIT 10;

/*Top 10 customer customer by revenue */
SELECT CustomerID,ROUND(SUM(Revenue),2) AS Revenue 
FROM retail_clean WHERE CustomerID IS NOT NULL
GROUP BY CustomerID ORDER BY Revenue DESC LIMIT 10;

 /*Customer pusrchase frequency(order per customer)*/
SELECT CustomerID,COUNT(DISTINCT InvoiceNo) AS ORDER_NUM
FROM retail_clean WHERE CustomerID is NOT NULL
GROUP BY CustomerID ORDER BY ORDER_NUM DESC;

/*Repeat Customer count and rate*/
SELECT
	SUM(CASE WHEN ORDER_NUM > 1 THEN 1 ELSE 0 END) AS REPEAT_CUSTOMERS,
    COUNT(*) AS TOTAL_CUS,
    ROUND(SUM(CASE WHEN ORDER_NUM > 1 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS REPEAT_RETE_PCT
FROM (
	SELECT CustomerID,COUNT(DISTINCT InvoiceNo) AS ORDER_NUM
    FROM retail_clean WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID) t;

/* Revenue by day of week*/
    SELECT DAYNAME(InvoiceDate) AS DAYNAME,
    ROUND(SUM(Revenue),2) AS revenue
    FROM retail_clean GROUP BY DAYNAME 
    ORDER BY revenue DESC;
/*product never by same customer(one time buy)*/
    SELECT StockCode,Description,COUNT(DISTINCT CustomerID) AS one_time_buyer
    FROM retail_clean
    WHERE CustomerID IS NOT NULL
    GROUP BY StockCode,Description
    HAVING COUNT(DISTINCT InvoiceNo) = COUNT(DISTINCT CustomerID)
    ORDER BY one_time_buyer DESC LIMIT 10;
/*Revenue contribution % by country*/
SELECT Country,ROUND(SUM(Revenue),2) AS revenue,
	ROUND(SUM(Revenue) * 100.0 / (SELECT SUM(Revenue) FROM retail_clean), 2) AS pct_of_total
FROM retail_clean GROUP BY Country ORDER BY revenue DESC LIMIT 10;

/*First and last purchase date per customer*/
SELECT CustomerID, MIN(InvoiceDate) AS first_purchase, MAX(InvoiceDate) AS last_purchase
FROM retail_clean WHERE CustomerID IS NOT NULL
GROUP BY CustomerID; 

/*Rank customers by revenue (RANK/DENSE_RANK/ROW_NUMBER)*/
WITH customer_revenue AS (
  SELECT CustomerID, SUM(Revenue) AS revenue
  FROM retail_clean WHERE CustomerID IS NOT NULL
  GROUP BY CustomerID
)
SELECT CustomerID, revenue,
  RANK()       OVER (ORDER BY revenue DESC) AS rank_std,
  DENSE_RANK() OVER (ORDER BY revenue DESC) AS dense_ranks,
  ROW_NUMBER() OVER (ORDER BY revenue DESC) AS row_num
FROM customer_revenue
ORDER BY revenue DESC LIMIT 20;

/*Running (cumulative) monthly revenue*/
WITH monthly AS (
  SELECT DATE_FORMAT(InvoiceDate,'%Y-%m') AS year_months, SUM(Revenue) AS revenue
  FROM retail_clean GROUP BY year_months
)
SELECT year_months, revenue,
  SUM(revenue) OVER (ORDER BY year_months) AS running_total
FROM monthly ORDER BY year_months;

/*Month-over-month growth %*/
WITH monthly AS (
  SELECT DATE_FORMAT(InvoiceDate,'%Y-%m') AS year_months, SUM(Revenue) AS revenue
  FROM retail_clean GROUP BY year_months
)
SELECT year_months, revenue,
  LAG(revenue) OVER (ORDER BY year_months) AS prev_month_revenue,
  ROUND((revenue - LAG(revenue) OVER (ORDER BY year_months)) / LAG(revenue) OVER (ORDER BY year_months) * 100, 2) AS mom_growth_pct
FROM monthly ORDER BY year_months;

/*Year-over-year comparison (December 2010 vs December 2011 — the only true YoY comparison this 13-month dataset supports)*/

SELECT
  SUM(CASE WHEN YEAR(InvoiceDate)=2010 AND MONTH(InvoiceDate)=12 THEN Revenue ELSE 0 END) AS dec_2010_revenue,
  SUM(CASE WHEN YEAR(InvoiceDate)=2011 AND MONTH(InvoiceDate)=12 THEN Revenue ELSE 0 END) AS dec_2011_revenue
FROM retail_clean;

/*Customer purchase interval (days between orders, using LAG on order dates)*/
WITH customer_orders AS (
  SELECT DISTINCT CustomerID, InvoiceNo, DATE(InvoiceDate) AS order_date
  FROM retail_clean WHERE CustomerID IS NOT NULL
),
ordered AS (
  SELECT CustomerID, order_date,
    LAG(order_date) OVER (PARTITION BY CustomerID ORDER BY order_date) AS prev_order_date
  FROM customer_orders
)
SELECT CustomerID, order_date, prev_order_date,
  DATEDIFF(order_date, prev_order_date) AS days_since_last_order
FROM ordered WHERE prev_order_date IS NOT NULL
ORDER BY CustomerID, order_date;

/*Top 3 products per country (window function ranking within groups)*/
WITH country_product AS (
  SELECT Country, StockCode, Description, SUM(Revenue) AS revenue
  FROM retail_clean GROUP BY Country, StockCode, Description
),
ranked AS (
  SELECT *, RANK() OVER (PARTITION BY Country ORDER BY revenue DESC) AS rnk
  FROM country_product
)
SELECT Country, StockCode, Description, revenue
FROM ranked WHERE rnk <= 3 ORDER BY Country, rnk;

/*Top customers per country*/
WITH country_customer AS (
  SELECT Country, CustomerID, SUM(Revenue) AS revenue
  FROM retail_clean WHERE CustomerID IS NOT NULL
  GROUP BY Country, CustomerID
),
ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY Country ORDER BY revenue DESC) AS rn
  FROM country_customer
)
SELECT Country, CustomerID, revenue FROM ranked WHERE rn = 1 ORDER BY revenue DESC;

/* Revenue contribution % per customer (window SUM as denominator)*/
SELECT CustomerID,
  SUM(Revenue) AS customer_revenue,
  ROUND(SUM(Revenue) * 100.0 / SUM(SUM(Revenue)) OVER (), 2) AS pct_of_total_revenue
FROM retail_clean WHERE CustomerID IS NOT NULL
GROUP BY CustomerID ORDER BY customer_revenue DESC LIMIT 20;

/*Pareto / 80-20 analysis — what % of customers drive 80% of revenue*/
WITH customer_revenue AS (
  SELECT CustomerID, SUM(Revenue) AS revenue
  FROM retail_clean WHERE CustomerID IS NOT NULL
  GROUP BY CustomerID
),
ranked AS ( 
  SELECT CustomerID, revenue,
    SUM(revenue) OVER (ORDER BY revenue DESC) AS running_revenue,
    SUM(revenue) OVER () AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn,
    COUNT(*) OVER () AS total_customers
  FROM customer_revenue
)
SELECT
  MIN(rn) AS customers_needed,
  MIN(rn) * 100.0 / MAX(total_customers) AS pct_of_customers
FROM ranked
WHERE running_revenue >= 0.8 * total_revenue;

/*Previous month revenue per country (LAG partitioned)*/
WITH monthly_country AS (
  SELECT Country, DATE_FORMAT(InvoiceDate,'%Y-%m') AS year_months, SUM(Revenue) AS revenue
  FROM retail_clean GROUP BY Country, year_months
)
SELECT Country, year_months, revenue,
  LAG(revenue) OVER (PARTITION BY Country ORDER BY year_months) AS prev_month_revenue
FROM monthly_country ORDER BY Country, year_months;

/*Products with declining month-over-month trend (last 3 months)*/
WITH monthly_product AS (
  SELECT StockCode, Description, DATE_FORMAT(InvoiceDate,'%Y-%m') AS year_months, SUM(Revenue) AS revenue
  FROM retail_clean GROUP BY StockCode, Description, year_months
),
recent AS (
  SELECT *, RANK() OVER (PARTITION BY StockCode ORDER BY year_months DESC) AS recency_rank
  FROM monthly_product
)
SELECT StockCode, Description, year_months, revenue
FROM recent WHERE recency_rank <= 3
ORDER BY StockCode, year_months;

/* Customer segments by order count (simple frequency tiers, precursor to RFM)*/
WITH freq AS (
  SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS orders
  FROM retail_clean WHERE CustomerID IS NOT NULL GROUP BY CustomerID
)
SELECT
  CASE WHEN orders = 1 THEN '1 order'
       WHEN orders BETWEEN 2 AND 5 THEN '2-5 orders'
       WHEN orders BETWEEN 6 AND 10 THEN '6-10 orders'
       ELSE '10+ orders' END AS order_bucket,
  COUNT(*) AS num_customers
FROM freq GROUP BY order_bucket ORDER BY num_customers DESC;

/*Average days between orders per customer (win. function + aggregation)*/
WITH customer_orders AS (
  SELECT DISTINCT CustomerID, DATE(InvoiceDate) AS order_date
  FROM retail_clean 
  WHERE CustomerID IS NOT NULL
),
gaps AS (
  SELECT CustomerID, order_date,
    DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY CustomerID ORDER BY order_date)) AS gap_days
  FROM customer_orders
)
SELECT CustomerID, ROUND(AVG(gap_days), 1) AS avg_days_between_orders
FROM gaps 
WHERE gap_days IS NOT NULL
GROUP BY CustomerID 
ORDER BY avg_days_between_orders;
