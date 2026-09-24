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