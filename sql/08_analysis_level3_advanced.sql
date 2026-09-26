/*analysis_level3_advanced*/

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
