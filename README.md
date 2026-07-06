# E-Commerce Sales Analytics: SQL Data Warehouse & Power BI Dashboard

## Overview

This project demonstrates the complete lifecycle of building a modern data warehouse and interactive business intelligence dashboard using the Olist Brazilian E-Commerce dataset.

The project follows industry-standard data warehousing practices by implementing an ETL pipeline, designing a Star Schema, creating optimized SQL views, and developing interactive Power BI dashboards for business analysis.

The objective is to transform raw transactional data into meaningful business insights that support decision-making in areas such as sales performance, customer behavior, product performance, logistics, and customer satisfaction.

---

## Project Objectives

- Design a SQL Server Data Warehouse using Star Schema architecture.
- Build an ETL pipeline to load and transform raw data.
- Create Dimension and Fact tables for analytical reporting.
- Optimize database performance using indexes.
- Develop SQL Views for Power BI reporting.
- Build interactive dashboards for business stakeholders.
- Perform business analysis using SQL and Power BI.

---

## Dataset

Dataset: Olist Brazilian E-Commerce Public Dataset

The dataset contains information about:

- Customers
- Orders
- Order Items
- Payments
- Products
- Product Categories
- Reviews
- Sellers
- Geolocation

Source:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

## Tech Stack

### Database

- Microsoft SQL Server
- SQL Server Express

### ETL

- SQL Scripts
- BULK INSERT
- Data Cleaning using Python (Pandas)

### Programming

- SQL
- Python

### Data Processing

- Pandas

### Business Intelligence

- Microsoft Power BI

---

# Project Architecture

```
Raw CSV Files
       │
       ▼
Raw Tables
       │
       ▼
Data Cleaning & Transformation
       │
       ▼
Star Schema
       │
       ▼
Fact Tables
Dimension Tables
       │
       ▼
Views (Reporting Layer)
       │
       ▼
Power BI Dashboard
```

---

# Database Architecture

## Raw Schema

Stores data exactly as received from the CSV files.

Tables:

- customers
- orders
- order_items
- payments
- products
- reviews
- geolocation
- product_category_translation

---

## Data Warehouse (DW)

### Dimension Tables

- dim_customers
- dim_products
- dim_date

### Fact Tables

- fact_orders
- fact_order_items
- fact_payments
- fact_reviews

---

## Reporting Layer

Power BI connects to SQL Views instead of directly accessing Fact tables.

Main View:

```
mart.vw_sales_summary
```

This view combines data from multiple fact and dimension tables to simplify reporting.

---

# ETL Workflow

## Step 1

Create Database

```
00_create_database.sql
```

---

## Step 2

Create Raw Tables

```
01_create_raw_tables.sql
```

---

## Step 3

Load CSV Files

```
02_load_raw_csvs.sql
```

---

## Step 4

Build Star Schema

```
03_build_star_schema.sql
```

---

## Step 5

Create Indexes

```
04_create_indexes.sql
```

---

## Step 6

Create Reporting Views

```
05_create_powerbi_views.sql
```

---

## Step 7

Stored Procedures

```
06_stored_procedures.sql
```

---

## Step 8

Business Questions

```
07_business_questions.sql
```

Contains analytical SQL queries used to answer business questions.

---

## Step 9

Data Quality Validation

```
08_data_quality_tests.sql
```

Used to validate:

- Row counts
- Duplicate records
- Missing values
- Data consistency

---

# Power BI Dashboard

The dashboard provides interactive insights into:

## Sales Analysis

- Total Revenue
- Total Orders
- Average Order Value
- Monthly Sales Trend
- Yearly Sales Trend

## Customer Analysis

- Total Customers
- Customer Distribution
- Top Customer States
- Customer Growth

## Product Analysis

- Revenue by Product Category
- Top Selling Products
- Product Performance

## Delivery Analysis

- Average Delivery Time
- Late Deliveries
- Order Status Distribution

## Review Analysis

- Average Review Score
- Review Distribution
- Customer Satisfaction

---

# Key Features

- End-to-End Data Warehouse
- Star Schema Design
- ETL Pipeline
- SQL Server Integration
- Power BI Dashboard
- Optimized SQL Queries
- Indexed Tables
- Business KPI Reporting
- Data Validation

---

# Folder Structure

```
E-Commerce Analytics
│
├── data/
│   └── olist/
│
├── 00_create_database.sql
├── 01_create_raw_tables.sql
├── 02_load_raw_csvs.sql
├── 03_build_star_schema.sql
├── 04_create_indexes.sql
├── 05_create_powerbi_views.sql
├── 06_stored_procedures.sql
├── 07_business_questions.sql
├── 08_data_quality_tests.sql
│
├── Power BI Dashboard.pbix
│
├── README.md
```

---

# Learning Outcomes

This project demonstrates practical experience with:

- SQL Server
- Database Design
- Data Warehousing
- Star Schema Modeling
- ETL Development
- Data Cleaning
- SQL Query Optimization
- Power BI Dashboard Development
- Business Intelligence
- Data Analytics

---

# Future Improvements

- Automate ETL using SQL Server Integration Services (SSIS)
- Schedule incremental data refresh
- Implement Slowly Changing Dimensions (SCD)
- Deploy the database to Azure SQL Database
- Publish dashboards to Power BI Service
- Add predictive analytics using Python or Machine Learning
- Build real-time dashboards

---

# Author

**Aditya Ranjan**

Data Analytics | SQL | Power BI | Python | Business Intelligence

GitHub:
https://github.com/Aditya-Ranjan23

LinkedIn:
https://www.linkedin.com/in/aditya-ranjan23/

---

# License

This project is intended for educational and portfolio purposes. The dataset belongs to Olist and is publicly available for learning and research.
