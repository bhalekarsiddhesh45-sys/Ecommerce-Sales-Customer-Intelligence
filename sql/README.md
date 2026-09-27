# MySQL — E-Commerce Sales & Customer Intelligence

## 📌 Overview

This folder contains the MySQL implementation of the **E-Commerce Sales & Customer Intelligence** project.

The objective of this phase is to:

- Load the retail dataset into MySQL
- Validate data quality
- Identify missing, duplicate, cancelled and invalid records
- Create a clean analytical view
- Perform business analysis using SQL
- Apply aggregation, filtering, joins, subqueries and window functions
- Prepare structured data for the next Power BI phase

---

## 📂 SQL Files

| File | Purpose |
|---|---|
| `01_createdatabase.sql` | Creates the project database |
| `02_createtable.sql` | Creates the staging table and defines the data structure |
| `03_SqlLoad.sql` | Loads the CSV data into MySQL |
| `04_Data_Quality_check.sql` | Performs data-quality and validation checks |
| `05_createview.sql` | Creates the `retail_clean` analytical view |
| `06_analysis_level1_basic.sql` | Basic business analysis queries |
| `07_analysis_level2_intermediate.sql` | Intermediate analysis using more advanced SQL |
| `08_analysis_level3_advanced.sql` | Advanced business analysis and analytical SQL |

---

# 🔄 SQL Workflow

```text
Raw / Cleaned CSV
       ↓
01_createdatabase.sql
       ↓
02_createtable.sql
       ↓
03_SqlLoad.sql
       ↓
retail_staging
       ↓
04_Data_Quality_check.sql
       ↓
05_createview.sql
       ↓
retail_clean
       ↓
06 Basic Analysis
       ↓
07 Intermediate Analysis
       ↓
08 Advanced Analysis