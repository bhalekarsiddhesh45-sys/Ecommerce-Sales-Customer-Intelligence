CREATE TABLE IF NOT EXISTS retail_staging (
	InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(20),
    Qunatity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID INT NULL,
    Country VARCHAR(100)
);
ALTER TABLE retail_staging
RENAME COLUMN Qunatity TO Quantity;
SELECT * FROM retail_staging;
SELECT
    COUNT(*) AS TotalRows,
    COUNT(InvoiceDate) AS ValidDates,
    COUNT(*) - COUNT(InvoiceDate) AS NullDates,
    MIN(InvoiceDate) AS MinDate,
    MAX(InvoiceDate) AS MaxDate
FROM retail_clean;

TRUNCATE TABLE retail_staging;


