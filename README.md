#  Railway Data Cleaning & Exploratory Data Analysis Using SQL

A complete SQL data analytics project focused on **cleaning messy railway transaction data and performing Exploratory Data Analysis (EDA)** to uncover patterns in ticket sales, revenue, routes, journey reliability, delays, refunds, and booking behavior.

This project was built to practice a real-world SQL workflow — starting with raw and inconsistent data, cleaning and validating it, and finally using SQL to answer meaningful business questions.

---

##  Project Overview

The original railway dataset contained a variety of real-world data quality issues, including:

* Inconsistent date formats
* Inconsistent time formats
* Missing values
* Extra spaces
* Inconsistent capitalization
* Different spellings for the same category
* Abbreviated values such as `Std`
* Inconsistent payment-method names
* Inconsistent journey-status values
* Prices stored in different formats such as `35.0`, `£35.00`, and other invalid values
* Negative and missing prices
* Inconsistent boolean values such as `0`, `1`, `N`, `No`, and `FALSE`
* Duplicate transaction records
* Inconsistent station names

The goal was to transform this messy dataset into a **consistent and analysis-ready dataset** using SQL.

After cleaning the data, I performed EDA to understand railway ticket sales, revenue, customer purchasing behavior, routes, delays, cancellations, refunds, and booking patterns.

---

##  Project Objectives

The project had two main objectives:

### 1. Data Cleaning

Transform the raw railway transaction data into a reliable and consistent dataset suitable for analysis.

### 2. Exploratory Data Analysis

Use SQL to answer business-oriented questions such as:

* How many journeys were recorded?
* Which ticket classes are most popular?
* Which ticket types generate the most revenue?
* What are the busiest railway routes?
* Which routes have the highest average ticket prices?
* How reliable are the railway journeys?
* What are the major causes of delays?
* Does ticket class affect delay rates?
* How often do delayed or cancelled journeys result in refunds?
* Does booking earlier result in cheaper tickets?
* Which routes generate the most revenue?
* Which month has the highest number of journeys?
* Which month generates the most revenue?

---

#  Dataset

The dataset represents railway ticket transactions and contains information about:

| Column                | Description                            |
| --------------------- | -------------------------------------- |
| `Transaction ID`      | Unique identifier for each transaction |
| `Date of Purchase`    | Date the ticket was purchased          |
| `Time of Purchase`    | Time the ticket was purchased          |
| `Purchase Type`       | Online or Station                      |
| `Payment Method`      | Payment method used                    |
| `Railcard`            | Railcard/customer category             |
| `Ticket Class`        | Standard or First Class                |
| `Ticket Type`         | Advance, Anytime, Off-Peak             |
| `Price(GBP)`          | Ticket price in GBP                    |
| `Departure Station`   | Starting station                       |
| `Arrival Destination` | Destination station                    |
| `Date of Journey`     | Journey date                           |
| `Departure Time`      | Scheduled departure                    |
| `Arrival Time`        | Scheduled arrival                      |
| `Actual Arrival Time` | Actual arrival time                    |
| `Journey Status`      | On-Time, Delayed, or Cancelled         |
| `Reason for Delay`    | Reason for a delay                     |
| `Refund Request`      | Whether a refund was requested         |

---

# Project Workflow

```text
Raw / Messy Dataset
        ↓
Data Inspection
        ↓
Staging Tables
        ↓
Data Cleaning
        ↓
Data Validation
        ↓
Clean Dataset
        ↓
Exploratory Data Analysis
        ↓
Business Insights
```

---

#  Data Cleaning

The raw dataset was first loaded into staging tables so that the original data could be preserved while transformations were performed.

The cleaning process included several steps.

## 1. Transaction ID Cleaning

Transaction IDs contained inconsistent formatting.

I:

* Checked the structure of transaction IDs
* Identified incorrectly formatted IDs
* Added missing separators where necessary
* Converted IDs to a consistent format
* Converted values to lowercase
* Identified duplicate transaction IDs

I also used `ROW_NUMBER()` with `PARTITION BY` to identify duplicate transactions.

```sql
ROW_NUMBER() OVER(
    PARTITION BY `Transaction ID`
)
```

This helped identify records where the same transaction appeared more than once.

---

## 2. Date Cleaning

The dataset contained multiple date formats, including formats such as:

```text
01/31/2024
15/02/2024
2024-03-22
2024/03/22
January 22, 2024
```

I converted inconsistent date values into a consistent date format using functions such as:

```sql
STR_TO_DATE()
```

and regular expressions to identify particular date patterns.

This was one of the more challenging parts of the project because dates such as:

```text
01/02/2024
```

can be ambiguous depending on whether the source uses:

```text
MM/DD/YYYY
```

or

```text
DD/MM/YYYY
```

---

## 3. Time Cleaning

Time values also appeared in different formats, for example:

```text
17:42:39
4:00 PM
04:30 AM
7:15 PM
```

These values needed to be standardized before performing time-based analysis.

---

## 4. Text Standardization

Several categorical columns contained inconsistent values because of capitalization, spacing, or abbreviations.

For example:

```text
Standard
STANDARD
standard
Standard  
Std
Standrd
```

These were standardized into consistent categories.

The same approach was applied to fields such as:

* Purchase Type
* Payment Method
* Ticket Class
* Ticket Type
* Departure Station
* Arrival Destination
* Journey Status
* Railcard

Functions such as `LOWER()`, `UPPER()`, `TRIM()`, and conditional logic were useful during this process.

---

## 5. Price Cleaning

The price column contained different representations such as:

```text
35.0
£35.00
3.00 GBP
-
NULL
negative values
```

The values were cleaned and converted into a numeric format so that aggregate calculations such as:

```sql
SUM()
AVG()
MIN()
MAX()
```

could be performed reliably.

The cleaned column was renamed:

```text
Price(GBP)
```

---

## 6. Missing Values

Missing values were investigated rather than blindly replacing everything with zero.

For important numerical fields such as price, I checked whether an exact value could be inferred from matching transaction attributes.

Where an exact value could not be reliably determined, the value was left as `NULL` rather than introducing an arbitrary estimate.

This helped avoid changing the underlying meaning of the dataset.

---

## 7. Journey Status Standardization

Journey status appeared in several forms:

```text
On Time
ON TIME
OnTime
On-Time
on time
Delayed
Cancelled
Canceled
```

These were standardized into consistent categories:

```text
On-Time
Delayed
Cancelled
```

This was important because inconsistent categorical values can produce incorrect `GROUP BY` results.

---

## 8. Refund Request Standardization

Refund values were represented using different formats:

```text
0
1
N
No
FALSE
Y
TRUE
```

These were converted into a consistent representation so that refund rates could be calculated correctly.

---


#  Data Validation

After cleaning, I performed validation checks to make sure the cleaned dataset was suitable for analysis.

Some of the checks included:

* Checking duplicate transaction IDs
* Checking NULL values
* Checking distinct categorical values
* Checking invalid prices
* Checking date conversions
* Checking standardized journey statuses
* Checking station names
* Checking payment methods
* Checking ticket classes and ticket types

The final cleaned dataset was saved as:

```text
railway_cleaned.csv
```

---

##  Before & After Data Cleaning

The original dataset contained several data quality issues such as inconsistent formatting, missing values, inconsistent categorical values, invalid prices, and duplicate records.

###  Before Cleaning — Messy Data

The raw dataset contained inconsistent values such as different date formats, capitalization, abbreviations, spacing, and price formats.

| Transaction ID | Date of Purchase | Purchase Type | Ticket Class | Ticket Type | Price(GBP) | Journey Status |
| -------------- | ---------------- | ------------- | ------------ | ----------- | ---------: | -------------- |
| TR001          | 01/15/2024       | Online        | standard     | Advance     |     £35.00 | On Time        |
| tr002          | 15/02/2024       | online        | Standard     | advance     |       40.0 | On-Time        |
| TR003          | 2024/03/18       | Station       | Std          | Off Peak    |        £25 | Delayed        |
| TR004          | March 20, 2024   | Station       | FIRST CLASS  | Anytime     |        -10 | delayed        |
| TR005          | 03-25-2024       | ONLINE        | Standard     | Advance     |       NULL | Cancelled      |

> **Note:** The table above is a simplified example of the types of inconsistencies found in the original dataset.

---

###  After Cleaning — Cleaned Data

After applying SQL-based data cleaning and validation, the data was standardized into a consistent format.

| Transaction ID | Date of Purchase | Purchase Type | Ticket Class | Ticket Type | Price(GBP) | Journey Status |
| -------------- | ---------------- | ------------- | ------------ | ----------- | ---------: | -------------- |
| TR001          | 2024-01-15       | Online        | Standard     | Advance     |      35.00 | On-Time        |
| TR002          | 2024-02-15       | Online        | Standard     | Advance     |      40.00 | On-Time        |
| TR003          | 2024-03-18       | Station       | Standard     | Off-Peak    |      25.00 | Delayed        |
| TR004          | 2024-03-20       | Station       | First Class  | Anytime     |       NULL | Delayed        |
| TR005          | 2024-03-25       | Online        | Standard     | Advance     |       NULL | Cancelled      |

###  Cleaning Examples

| Data Issue     | Before       | After        |
| -------------- | ------------ | ------------ |
| Date format    | `01/15/2024` | `2024-01-15` |
| Capitalization | `online`     | `Online`     |
| Ticket class   | `Std`        | `Standard`   |
| Ticket type    | `Off Peak`   | `Off-Peak`   |
| Journey status | `On Time`    | `On-Time`    |
| Price format   | `£35.00`     | `35.00`      |
| Extra spaces   | `Standard  ` | `Standard`   |
| Invalid price  | `-10`        | `NULL`       |

The cleaned dataset was then used for the **Exploratory Data Analysis (EDA)** phase of the project.











#  Exploratory Data Analysis

After cleaning the dataset, I used SQL to explore different aspects of railway operations.

## 1. Basic Dataset Exploration

I calculated:

* Total number of journeys
* Number of unique departure stations
* Number of unique destinations
* Minimum ticket price
* Maximum ticket price
* Average ticket price
* Number of unique ticket types

Example:

```sql
SELECT COUNT(*) AS total_journeys
FROM railway_cleaned;
```

---

## 2. Customer Purchasing Behavior

I analyzed what customers were purchasing by looking at:

* Ticket Class
* Ticket Type
* Purchase Type
* Payment Method
* Railcard

For example:

```sql
SELECT
    `Ticket Class`,
    COUNT(*) AS number_of_tickets
FROM railway_cleaned
GROUP BY `Ticket Class`
ORDER BY number_of_tickets DESC;
```

This helped identify the most commonly purchased products and customer preferences.

---

#  Revenue Analysis

I analyzed revenue across different ticket types and ticket classes.

Metrics included:

* Number of tickets sold
* Total revenue
* Average ticket price
* Minimum ticket price
* Maximum ticket price

Example:

```sql
SELECT
    `Ticket Type`,
    COUNT(*) AS Number_of_Tickets,
    SUM(`Price(GBP)`) AS `Total Revenue`,
    ROUND(AVG(`Price(GBP)`), 2) AS `Average Price`
FROM railway_cleaned
GROUP BY `Ticket Type`
ORDER BY `Total Revenue` DESC;
```

---

#  Window Functions & Rolling Revenue

I used a CTE to first calculate ticket-class-level metrics and then applied a window function to calculate a rolling revenue total.

```sql
SUM(revenue) OVER(
    ORDER BY `Ticket Class`
) AS Rolling_total
```

This helped me understand how **window functions work alongside grouped results**.

---

#  Route Analysis

I created routes by combining departure and arrival stations:

```sql
CONCAT(
    `Departure Station`,
    ' -> ',
    `Arrival Destination`
)
```

I then analyzed:

* Most frequently travelled routes
* Highest-average-price routes
* Highest-revenue routes

For expensive routes, I also applied a minimum journey threshold so that a route with only a few transactions would not dominate the results.

```sql
HAVING Travelled_frequency >= 10
```

---

#  Railway Reliability Analysis

I analyzed journey performance using:

```text
On-Time
Delayed
Cancelled
```

I calculated the percentage of journeys falling into each status.

I also analyzed the major causes of delays.

Examples included:

* Weather
* Technical issues
* Signal failures
* Staff shortages

---

#  Delay Rate by Ticket Class

I compared delay rates between different ticket classes.

The calculation used conditional aggregation:

```sql
SUM(
    CASE
        WHEN `Journey Status` = 'Delayed'
        THEN 1
        ELSE 0
    END
)
```

This allowed me to calculate the number and percentage of delayed journeys for each ticket class.

---

#  Delays vs Refund Requests

I investigated whether delayed or cancelled journeys were more likely to result in refund requests.

The analysis calculated:

* Total journeys
* Number of refund requests
* Refund rate

```sql
ROUND(
    SUM(`Refund Request`) * 100 /
    COUNT(`Journey Status`),
    2
) AS `Refund Rate(%)`
```

I also analyzed refund-request rates by delay reason.

---

#  Does Booking Earlier Mean Cheaper Tickets?

One of the more interesting analyses was investigating the relationship between **booking time and ticket price**.

I calculated the number of days between:

```text
Date of Purchase
```

and

```text
Date of Journey
```

Then I grouped customers into booking windows:

| Booking Window |
| -------------- |
| 0–3 days       |
| 4–7 days       |
| 8–14 days      |
| 15–30 days     |
| 30+ days       |

I then compared the average ticket price across these groups.

This allowed me to investigate whether purchasing tickets further in advance was associated with lower prices.

---

#  SQL Concepts I Learned

This project helped me practice and understand several SQL concepts in a practical context.

### Data Cleaning

* `TRIM()`
* `LOWER()`
* `UPPER()`
* `REPLACE()`
* `INSERT()`
* `REGEXP`
* `STR_TO_DATE()`
* `CAST()`
* `CASE`

### Aggregation

* `COUNT()`
* `SUM()`
* `AVG()`
* `MIN()`
* `MAX()`
* `ROUND()`

### Querying

* `WHERE`
* `GROUP BY`
* `ORDER BY`
* `HAVING`
* `LIMIT`
* `DISTINCT`

### Advanced SQL

* Common Table Expressions (`CTEs`)
* Window Functions
* `ROW_NUMBER()`
* `PARTITION BY`
* `OVER()`
* Conditional Aggregation
* Nested Queries
* Date Functions
* String Functions

---

#  What I Learned

The main purpose of this project was not only to write SQL queries but to understand how SQL can be used in an actual data-analysis workflow.

### 1. Data cleaning is often harder than analysis

Real-world data is rarely perfectly structured.

Before asking analytical questions, I learned that I need to make sure:

* values are consistent
* dates are valid
* categories are standardized
* duplicates are handled
* numerical values are actually numeric
* missing values are understood

---

### 2. Data should not be blindly modified

I learned that missing data does not always mean it should be replaced with `0` or an average.

For important values such as ticket prices, using an arbitrary replacement can create inaccurate analysis.

---

### 3. Categorical consistency matters

Values such as:

```text
Standard
standard
STANDARD
Std
```

may represent the same category, but SQL treats them as different values.

Therefore, standardization is essential before performing `GROUP BY` analysis.

---

### 4. CTEs make complex queries easier to understand

Instead of writing one extremely complicated query, I learned how a CTE can break the problem into logical steps.

```sql
WITH example AS (
    ...
)
SELECT *
FROM example;
```

---

### 5. Window functions are different from GROUP BY

I learned that `GROUP BY` reduces rows into groups, while window functions allow calculations across related rows without collapsing the result in the same way.

I practiced:

```sql
SUM() OVER()
```

and

```sql
ROW_NUMBER() OVER(
    PARTITION BY ...
)
```

---

### 6. SQL can answer business questions

Instead of only practicing isolated SQL syntax, this project helped me think in terms of questions such as:

> Which routes are busiest?

> Which ticket type generates the most revenue?

> What causes the most delays?

> Are refunds more common after disruptions?

> Does booking earlier result in cheaper tickets?

This helped me understand how SQL is actually used for data analysis.

---

#  Tools Used

* **MySQL**
* **SQL**
* **Git**
* **GitHub**
* CSV Dataset

---

#  Project Structure

```text
railway-sql-analysis/
│
├── data/
│   ├── railway_messy.csv
│   └── railway_cleaned.csv
│
├── sql/
│   ├── datacleaningsql.sql
│   └── Exploratory Data Analysis.sql
│
└── README.md
```

---

#  How to Use

### 1. Clone the repository

```bash
git clone <your-repository-url>
```

### 2. Create a MySQL database

```sql
CREATE DATABASE railway_analysis;
USE railway_analysis;
```

### 3. Load the raw dataset

Import:

```text
railway_messy.csv
```

into the database.

### 4. Run the cleaning SQL

Execute:

```text
datacleaningsql.sql
```

This creates and transforms the staging tables and produces the cleaned dataset.

### 5. Run the EDA queries

Execute:

```text
Exploratory Data Analysis.sql
```

to reproduce the analysis.

---

#  Key Takeaway

This project demonstrates a complete beginner-to-intermediate SQL analytics workflow:

**Messy Data → Cleaning → Validation → Structured Data → EDA → Business Questions**

Rather than working with an already-clean dataset, I focused on understanding the problems that occur in real-world data and using SQL to solve them before performing analysis.

This project strengthened my understanding of **SQL data cleaning, aggregation, CTEs, window functions, conditional logic, date/string manipulation, and exploratory data analysis.**

---

##  Future Improvements

Possible next steps for this project:

* Create visualizations using **Power BI / Tableau**
* Build a dashboard for railway performance
* Perform deeper statistical analysis
* Analyze price trends over time
* Analyze journey duration and delays
* Investigate customer segments
* Add more advanced SQL analysis
* Connect the cleaned dataset to a BI tool

---

##  Author

**Sushant Nepal**

Learning SQL, Data Analytics, Python, and Machine Learning.

---

 If you found this project useful, feel free to explore the SQL scripts and datasets included in the repository.
