# Project 1: E-Commerce Analytics With SQL Server + Power BI

This is a portfolio-grade analytics project built around the public Olist Brazilian E-Commerce dataset:

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The project is designed as if a senior data analyst were guiding an intern through a real e-commerce analytics assignment. It covers raw data loading, star-schema modeling, advanced SQL, Power BI dashboard planning, and business insight reporting.

## Business Goal

Analyze e-commerce orders, customers, products, payments, and reviews to identify revenue drivers, customer retention patterns, regional sales trends, and customer experience issues.

Revenue is defined as product item price only. Freight is tracked separately as delivery cost.

## Folder Structure

```text
outputs/
  README.md
  sql/
    00_create_database.sql
    01_create_raw_tables.sql
    02_load_raw_csvs.sql
    03_build_star_schema.sql
    04_create_indexes.sql
    05_create_powerbi_views.sql
    06_stored_procedures.sql
    07_business_questions.sql
    08_data_quality_tests.sql
  docs/
    er_diagram.md
    intern_work_plan.md
    business_insights_report.md
  powerbi/
    dashboard_spec.md
    dax_measures.md
    power_bi_theme.json
```

## Recommended Run Order

1. Download the Olist CSV files from Kaggle.
2. Place the CSV files in a local folder such as `C:\data\olist`.
3. Open SQL Server Management Studio.
4. Run the SQL files in this order:
   - `sql/00_create_database.sql`
   - `sql/01_create_raw_tables.sql`
   - `sql/02_load_raw_csvs.sql`
   - `sql/03_build_star_schema.sql`
   - `sql/04_create_indexes.sql`
   - `sql/05_create_powerbi_views.sql`
   - `sql/06_stored_procedures.sql`
   - `sql/08_data_quality_tests.sql`
   - `sql/07_business_questions.sql`
5. Connect Power BI Desktop to the `ECommerceAnalytics` database.
6. Use either the `dw` star-schema tables or the `mart` views as the reporting layer.

## Deliverables Included

- SQL Server scripts for raw load, dimensional modeling, views, indexes, procedures, and QA tests.
- Mermaid ER diagram for documentation.
- Power BI dashboard specification with page-level visual guidance.
- DAX measure library for Power BI.
- Business insights report template with analyst-style recommendations.
- Intern work plan with checkpoints and review questions.

## SQL Concepts Demonstrated

- CTEs
- Window functions
- Views
- Stored procedures
- Indexing
- Star-schema modeling
- Data quality validation
- KPI reconciliation

## Notes For The Intern

Treat this as an analyst project, not just a SQL exercise. Every metric should answer a business question, and every dashboard page should make a decision easier.

