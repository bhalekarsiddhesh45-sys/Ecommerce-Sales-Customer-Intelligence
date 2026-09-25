/*analysis_level1_basic*/

/* Total Revenue */
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