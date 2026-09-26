/*analysis_level2_intermediate*/

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