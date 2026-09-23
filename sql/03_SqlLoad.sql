SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/Users/Siddhesh/Downloads/Projects/E-commerce/E-Excel/Online_Retail_Cleaned_20K.csv'
INTO TABLE retail_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    @InvoiceDate,
    UnitPrice,
    @CustomerID,
    Country
)
SET
    InvoiceDate = STR_TO_DATE(@InvoiceDate, '%Y-%m-%d %H:%i:%s'),
    CustomerID = NULLIF(@CustomerID, '');
    
SELECT COUNT(*) FROM retail_staging;
SELECT MIN(@InvoiceDate),MAX(@InvoiceDate) FROM retail_staging;

