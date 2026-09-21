# Excel Data Cleaning & Analysis

## Dataset

Dataset used:
`Online_Retail_Cleaned_20K.xlsx`

The Excel phase was used to perform data-quality checks, cleaning, validation, and initial sales analysis.

## Data Quality Decisions

### Cancelled Transactions

Cancelled transactions were identified using the InvoiceNo field.

Rows identified as cancelled were excluded from the sales/revenue analysis because they represent cancelled transactions rather than completed sales.

Cancelled rows identified: **[ENTER COUNT]**

### Zero or Invalid Price

Transactions with zero or invalid UnitPrice were excluded from revenue analysis because they do not represent valid positive-value sales.

Rows excluded: **[ENTER COUNT]**

### Missing CustomerID

Rows with missing CustomerID were not automatically removed from the entire dataset.

They were excluded only from analyses that require customer-level identification, such as:

- Customer-level sales analysis
- Customer frequency analysis
- RFM segmentation

This preserves valid transaction-level sales information for other analyses.

Rows with missing CustomerID: **[ENTER COUNT]**

### Duplicate Records

Duplicate records were checked using the relevant transaction fields.

Duplicate rows identified: **[ENTER COUNT]**

## Monthly Revenue Analysis

A monthly revenue PivotTable and PivotChart were created to analyze revenue trends over time.

The chart screenshot is included below.

![Monthly Revenue Pivot Chart](../images/monthly-revenue-pivot-chart.png)

## Excel Workflow

The Excel analysis followed this process:

1. Data validation
2. Data-quality checks
3. Cleaning and filtering
4. Revenue calculation
5. Monthly revenue analysis
6. PivotTable creation
7. PivotChart creation