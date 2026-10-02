# Python Analysis Report

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Dataset Overview](#2-dataset-overview)
3. [Data Cleaning](#3-data-cleaning)
4. [Exploratory Data Analysis](#4-exploratory-data-analysis)
5. [Statistical Analysis](#5-statistical-analysis)
6. [Customer Analysis — RFM](#6-customer-analysis--rfm)
7. [RFM Scoring](#7-rfm-scoring)
8. [Customer Segmentation](#8-customer-segmentation)
9. [Product Analysis](#9-product-analysis)
10. [Time-Series Analysis](#10-time-series-analysis)
11. [Key Business Insights](#11-key-business-insights)
12. [Python and SQL Validation](#12-python-and-sql-validation)
13. [Python Project Files](#13-python-project-files)
14. [Conclusion](#14-conclusion)

---

## 1. Project Overview

This report documents the Python-based analysis performed for the **E-commerce Sales & Customer Intelligence** project.

The Python phase focuses on exploratory data analysis, statistical analysis, customer segmentation, product analysis, and time-series analysis.

### Objectives

- Analyze the cleaned e-commerce transaction data
- Understand sales distributions and patterns
- Identify important geographic revenue markets
- Analyze customer purchasing behavior using RFM
- Identify important and declining products
- Analyze monthly revenue and growth trends
- Generate business-oriented insights from the data

### Python Libraries Used

- Pandas
- NumPy
- Matplotlib
- Seaborn
- OpenPyXL
- Jupyter Notebook

---

## 2. Dataset Overview

The dataset contains transaction-level e-commerce sales data.

### Main Columns

| Column      | Description                  |
| ----------- | ---------------------------- |
| InvoiceNo   | Unique invoice/order number  |
| StockCode   | Product code                 |
| Description | Product description          |
| Quantity    | Number of units purchased    |
| InvoiceDate | Date and time of transaction |
| UnitPrice   | Price per unit               |
| CustomerID  | Customer identifier          |
| Country     | Customer country             |

### Derived Features

The following features were created during the Python analysis:

- `Revenue`
- `Year`
- `Month`
- `YearMonth`
- `IsCancelled`

Revenue was calculated as:

```text
Revenue = Quantity × UnitPrice
```

---

## 3. Data Cleaning

The Python cleaning process was designed to maintain consistency with the cleaned dataset used in the SQL phase.

### Cleaning Steps

1. Checked missing values.
2. Checked duplicate records.
3. Removed duplicate records.
4. Converted `InvoiceDate` to datetime format.
5. Converted `CustomerID` to nullable integer format.
6. Created the `Revenue` column.
7. Created Year, Month and YearMonth features.
8. Identified cancelled transactions.
9. Removed transactions with invalid quantity.
10. Removed transactions with invalid or zero unit price.
11. Removed non-product/service stock codes from the analytical dataset.
12. Retained missing `CustomerID` transactions for overall sales analysis.
13. Excluded missing `CustomerID` records from customer-level RFM analysis.

### Data Quality Summary

| Data Quality Check          |  Result |
| --------------------------- | ------: |
| Cancelled transactions      |     344 |
| Invalid/zero UnitPrice rows |     100 |
| Missing CustomerID          |   4,935 |
| Duplicate rows              |      10 |

### Important CustomerID Consideration

Transactions with missing `CustomerID` were **not** removed from the overall sales analysis.

However, they were excluded from RFM analysis because customer-level analysis requires a valid customer identifier.

---

## 4. Exploratory Data Analysis

Exploratory Data Analysis was performed to understand the distribution, relationships and trends present in the cleaned transaction data.

The analysis included:

- Distribution analysis
- Country-level revenue analysis
- Monthly revenue analysis
- Quantity versus revenue analysis
- Daily and weekly revenue analysis

### 4.1 Distribution Analysis

The distributions of Quantity, UnitPrice and Revenue were analyzed using histograms.

![Quantity, UnitPrice and Revenue Distributions](images/python_distribution_analysis.png)

**Interpretation**

The distributions are heavily right-skewed. Most transactions have relatively small values, while a smaller number of transactions have substantially larger values.

Because of this skewness, median and percentile-based measures are useful alongside the mean when describing typical transaction behavior.

### 4.2 Revenue by Country

Revenue was aggregated by country to identify the major geographic markets.

![Top 10 Countries by Revenue](images/top_10_countries_revenue.png)

**Interpretation**

The chart shows the countries contributing the highest revenue to the cleaned dataset.

This analysis can support geographic market analysis, regional sales planning and identification of important customer markets.

### 4.3 Monthly Revenue Trend

Monthly revenue was calculated using the `YearMonth` feature.

![Monthly Revenue Trend](images/monthly_revenue_trend.png)

**Interpretation**

The monthly revenue trend shows a clear increase in activity during November 2011.

November shows a noticeable revenue spike, which is consistent with increased pre-Christmas ordering activity.

Revenue declines in December after the middle of the month. This should be interpreted carefully because the available dataset ends around the middle of December, so December does not represent a complete month.

The summer months are comparatively quieter.

### 4.4 Quantity vs Revenue

A sampled scatter plot was used to examine the relationship between quantity purchased and transaction revenue.

![Quantity vs Revenue](images/quantity_vs_revenue.png)

**Interpretation**

The scatter plot helps identify the relationship between the quantity purchased and revenue generated by individual transactions.

A sample of transactions was used to reduce overplotting and make the relationship easier to visualize.

---

## 5. Statistical Analysis

The transaction data contains highly skewed distributions. Therefore, the analysis does not rely only on the mean.

The following statistical measures were considered:

- Mean
- Median
- Standard deviation
- Interquartile range (IQR)
- Percentiles

### Why Median and IQR?

The median is less affected by extreme values than the mean.

The IQR describes the spread of the middle 50% of observations and is useful when the distribution contains large outliers.

A coefficient of variation can also be used to describe the relative volatility of monthly revenue.

Formal statistical tests were not added unless they answer a specific business question.

---

## 6. Customer Analysis — RFM

RFM analysis was performed to understand customer purchasing behavior.

### RFM Metrics

| Metric    | Meaning                                                  |
| --------- | -------------------------------------------------------- |
| Recency   | Number of days since the customer's most recent purchase |
| Frequency | Number of distinct orders placed by the customer         |
| Monetary  | Total revenue generated by the customer                  |

The RFM snapshot date was defined as one day after the maximum transaction date in the cleaned dataset.

---

## 7. RFM Scoring

Customers were scored from 1 to 5 using quintile-based scoring.

### Recency

Customers with more recent purchases receive higher Recency scores.

### Frequency

Customers with more orders receive higher Frequency scores.

Because Frequency contains many tied values, `rank(method='first')` was applied before `qcut`.

This allows the frequency values to be divided into quintiles without the duplicate-bin problem that can occur when many customers have the same frequency.

### Monetary

Customers generating higher total revenue receive higher Monetary scores.

The three scores were combined into a single RFM score.

Example:

```text
555
```

---

## 8. Customer Segmentation

Customers were grouped into business-oriented segments using their RFM scores.

| Segment             | Business Meaning                                          |
| ------------------- | --------------------------------------------------------- |
| Champions           | Highly recent, frequent and valuable customers            |
| Loyal Customers     | Customers with strong purchasing relationships            |
| Potential Loyalists | Customers showing potential for stronger loyalty          |
| New Customers       | Recently acquired customers with limited purchase history |
| At Risk             | Previously active customers showing weaker recency        |
| Lost Customers      | Customers with low recency and lower purchasing activity  |
| Needs Attention     | Customers with mixed RFM signals                          |

### RFM Segment Distribution

![RFM Segment Distribution](images/rfm_segment_distribution.png)

### Business Actions

| Segment             | Suggested Action                                   |
| ------------------- | -------------------------------------------------- |
| Champions           | Reward with early access and loyalty perks         |
| Loyal Customers     | Upsell, cross-sell and encourage reviews/referrals |
| Potential Loyalists | Use targeted offers to increase frequency          |
| New Customers       | Focus on onboarding and second-purchase incentives |
| At Risk             | Use win-back campaigns                             |
| Lost Customers      | Use low-cost reactivation campaigns                |
| Needs Attention     | Investigate and monitor behavior                   |

### RFM Coverage Limitation

RFM analysis only includes transactions with a valid `CustomerID`.

Therefore, RFM revenue should not be treated as the total revenue of the complete cleaned dataset.

The difference represents revenue from transactions where customer identification was unavailable.

The final revenue coverage percentage should be taken directly from the RFM notebook results.

---

## 9. Product Analysis

Product-level analysis was performed using:

- StockCode
- Description
- Revenue
- Quantity
- Orders

### Objectives

- Identify high-revenue products
- Identify products with high sales volume
- Compare products by number of orders
- Identify products showing declining revenue trends

The product analysis also compares monthly product revenue across the latest three available months to identify consecutive revenue declines.

### Top Products by Revenue

![Top Products by Revenue](images/top_products_revenue.png)

**Interpretation**

The chart shows the products contributing the highest revenue in the cleaned dataset.

These products can be further investigated based on revenue, quantity and order frequency.

---

## 10. Time-Series Analysis

Monthly revenue was analyzed to understand changes in sales performance over time.

Month-over-month revenue growth was calculated as:

```text
MoM Growth % = ((Current Month Revenue - Previous Month Revenue) / Previous Month Revenue) × 100
```

![Month-over-Month Revenue Growth](images/mom_revenue_growth.png)

The Python MoM calculation should be cross-checked against SQL Q25.

---

## 11. Key Business Insights

### Sales

- Transaction values are heavily right-skewed.
- A relatively small number of high-value transactions can influence the average revenue.
- Median and percentile-based measures are useful for describing typical transaction behavior.

### Seasonality

- November 2011 shows a clear revenue spike.
- The November increase is consistent with pre-Christmas ordering activity.
- December revenue decreases after the middle of the month because the dataset does not contain a complete December.
- Summer months are comparatively quieter.

### Customers

- RFM analysis provides a structured way to understand customer purchasing behavior.
- Customer segments can be used to support targeted retention and reactivation strategies.
- RFM analysis is limited to transactions with available CustomerID values.

### Products

- Product analysis identifies high-revenue products.
- Comparing recent monthly product revenue can identify products with declining performance.

### Time Series

- Monthly revenue and MoM growth provide a view of changes in business performance over time.
- Python time-series results should be validated against the SQL analysis.

---

## 12. Python and SQL Validation

Python results were cross-checked with the SQL analysis where applicable.

The following metrics should be consistent between the two phases:

- Clean row count
- Total clean revenue
- Monthly revenue
- Month-over-month growth
- Customer-level revenue where applicable

If differences occur, the following areas should be checked:

- Duplicate removal
- Cancelled transaction filtering
- Quantity filtering
- UnitPrice filtering
- Non-product stock-code filtering
- Missing CustomerID handling

---

## 13. Python Project Files

```text
python/
├── 01_Data_Loading.ipynb
├── 02_Data_Cleaning.ipynb
├── 03_eda.ipynb
├── 04_customer_analysis_rfm.ipynb
├── 05_product_analysis.ipynb
└── 06_time_series_analysis.ipynb

report/
├── Python_Analysis_Report.md
├── rfm.csv
└── images/
    ├── python_distribution_analysis.png
    ├── top_10_countries_revenue.png
    ├── monthly_revenue_trend.png
    ├── quantity_vs_revenue.png
    ├── rfm_segment_distribution.png
    ├── top_products_revenue.png
    └── mom_revenue_growth.png
```

---

## 14. Conclusion

The Python phase extends the SQL analysis by providing statistical exploration, visualization, customer segmentation, product analysis and time-series analysis.

The analysis highlights important sales patterns, including skewed transaction distributions, increased November activity, an incomplete December period and comparatively quieter summer months.

RFM analysis provides a customer-focused view, while product and time-series analysis provide additional perspectives on business performance.

The Python results can now be used as inputs for the Power BI dashboard and final business documentation.
