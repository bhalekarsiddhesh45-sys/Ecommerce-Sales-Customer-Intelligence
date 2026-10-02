# Python — EDA, Statistics & RFM Customer Segmentation

## 📌 Overview

This phase uses Python to perform:

* Data loading and validation
* Data cleaning
* Feature engineering
* Exploratory Data Analysis (EDA)
* Statistical analysis
* Customer-level RFM analysis
* Customer segmentation
* Product analysis
* Time-series analysis

Python is used alongside MySQL rather than repeating the same SQL analysis. SQL is mainly used for structured querying and aggregation, while Python is used for visualization, statistical distributions, iterative analysis, and multi-step customer segmentation logic.

---

## 🛠️ Tools & Libraries

* Python
* Pandas
* NumPy
* Matplotlib
* Seaborn
* Jupyter Notebook
* OpenPyXL

Install the required libraries:

```bash
pip install pandas numpy matplotlib seaborn jupyter openpyxl
```

Save the installed dependencies:

```bash
pip freeze > requirements.txt
```

---

## 📂 Notebook Structure

```text
python/
│
├── 01_Data_Loading.ipynb
├── 02_Data_Cleaning.ipynb
├── 03_eda.ipynb
├── 04_customer_analysis_rfm.ipynb
├── 05_product_analysis.ipynb
└── 06_time_series_analysis.ipynb
```

---

# 01 — Data Loading

The raw Online Retail Excel dataset is loaded using Pandas.

Main activities:

* Import Excel data
* Check dataset dimensions
* Inspect column data types
* Preview the first records
* Validate the row count against Excel and MySQL

Example:

```python
import pandas as pd

df = pd.read_excel("../data/raw/Online_Retail_Raw.xlsx")

print(df.shape)
df.info()
df.head()
```

---

# 02 — Data Cleaning

The cleaning notebook prepares the dataset for analysis.

### Main steps

1. Check missing values
2. Identify and remove duplicate records
3. Convert `InvoiceDate` to datetime
4. Convert `CustomerID` to nullable integer
5. Create `Revenue`
6. Create date-related features
7. Identify cancelled invoices
8. Remove invalid transactions
9. Create the final `df_clean` DataFrame

### Revenue

```text
Revenue = Quantity × UnitPrice
```

### Important cleaning rules

* Quantity must be greater than 0
* UnitPrice must be greater than 0
* Cancelled invoices are excluded
* Non-product StockCodes are excluded according to the project cleaning rules

The cleaned dataset is exported as:

```text
data/retail_clean.csv
```

---

# 03 — Exploratory Data Analysis

EDA is used to understand the distribution and behavior of the cleaned retail data.

### Analysis performed

* Quantity distribution
* Unit price distribution
* Revenue distribution
* Revenue by country
* Monthly revenue trend
* Quantity vs Revenue relationship
* Daily revenue
* Weekly revenue

### Key statistical considerations

The transaction-level distributions are right-skewed. Therefore, median and IQR are considered alongside the mean when describing typical transaction/order values.

The analysis also examines monthly revenue volatility using measures such as coefficient of variation where appropriate.

Formal statistical tests are only used when they answer a specific business question.

---

# 04 — Customer Analysis & RFM

RFM stands for:

| Metric    | Meaning                                       |
| --------- | --------------------------------------------- |
| Recency   | How recently the customer purchased           |
| Frequency | How many distinct orders the customer placed  |
| Monetary  | How much total revenue the customer generated |

### RFM Calculation

The reference date is defined as one day after the latest transaction date in the cleaned dataset.

```python
snapshot_date = df_clean['InvoiceDate'].max() + dt.timedelta(days=1)
```

Customer-level metrics are then calculated using:

```python
df_clean.groupby('CustomerID')
```

### RFM Scoring

Each RFM metric is converted into a score from 1 to 5 using quintile-based scoring.

* Recency: lower number of days = better score
* Frequency: higher number of orders = better score
* Monetary: higher revenue = better score

Frequency uses:

```python
rank(method='first')
```

before `qcut()` because many customers have tied frequency values.

---

## Customer Segments

The RFM scores are converted into business-oriented customer segments.

| Segment             | Business Meaning                                                 |
| ------------------- | ---------------------------------------------------------------- |
| Champions           | Highly recent, frequent and valuable customers                   |
| Loyal Customers     | Customers with relatively strong recency and frequency           |
| Potential Loyalists | Customers with potential to become more loyal                    |
| New Customers       | Recent customers with relatively low purchase frequency          |
| At Risk             | Previously active customers whose purchases are no longer recent |
| Lost Customers      | Customers with low recency and frequency                         |
| Needs Attention     | Customers with mixed RFM signals                                 |

The segmentation thresholds are a project-defined framework and can be tuned depending on business requirements.

---

# 05 — Product Analysis

Product-level analysis evaluates:

* Total revenue by product
* Total quantity sold
* Number of unique orders
* Products showing declining revenue trends

The analysis also compares product revenue across the most recent three months to identify continuously declining products.

---

# 06 — Time-Series Analysis

The time-series notebook analyzes monthly revenue and Month-over-Month (MoM) growth.

```python
monthly_rev = df_clean.groupby('YearMonth')['Revenue'].sum()

mom_growth = monthly_rev.pct_change() * 100
```

The Python MoM calculation is cross-checked against the corresponding SQL analysis.

---

# 📁 Project Outputs

The Python analysis outputs are kept in the project's separate `images/` folder.

```text
images/
├── python_distribution_analysis.png
├── top_10_countries_revenue.png
├── monthly_revenue_trend.png
├── quantity_vs_revenue.png
├── rfm_segment_distribution.png
├── top_products_revenue.png
└── mom_revenue_growth.png
```

The complete written Python analysis is kept separately in:

```text
report/
└── Python_Analysis_Report.md
```

The RFM analysis remains in `python/04_customer_analysis_rfm.ipynb`.

No separate `rfm.csv` output is required for this project.

---

# 📊 Business Insights

The Python phase is intended to convert raw transaction data into business insights such as:

* Customer purchasing behavior
* High-value customer groups
* Recently inactive customers
* Customer loyalty patterns
* Product performance
* Revenue trends
* Monthly revenue growth
* Potential customer retention opportunities

The final notebook cells should summarize these findings in plain business language rather than only displaying code output.

---

# ⚠️ RFM Data Coverage

RFM analysis is performed only for customers with a non-null `CustomerID`.

Therefore, RFM revenue coverage should be compared with total clean revenue.

The difference represents revenue associated with transactions where `CustomerID` is missing.

This limitation should be clearly disclosed when presenting the analysis.

---

# 🎯 Portfolio Value

This Python phase demonstrates practical skills in:

* Python
* Pandas
* Data Cleaning
* Feature Engineering
* Exploratory Data Analysis
* Data Visualization
* Statistics
* Customer Segmentation
* RFM Analysis
* Business Interpretation

It also provides a Python-based cross-check of important analysis already performed using MySQL.
