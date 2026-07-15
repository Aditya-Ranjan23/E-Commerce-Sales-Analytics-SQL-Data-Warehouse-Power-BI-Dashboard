# Intern Work Plan

## Objective

Build a complete e-commerce analytics case study using SQL Server and Power BI. The intern should be able to explain the data model, defend metric definitions, answer business questions in SQL, and present recommendations from a dashboard.

## Phase 1: Dataset Understanding

Tasks:

- Download the Olist CSV files from Kaggle.
- Inspect each file before loading:
  - row count
  - column names
  - null-heavy fields
  - duplicate business keys
  - date ranges
  - order status distribution
- Write short notes explaining what each table represents.

Review questions:

- Why is `customer_unique_id` more useful than `customer_id` for retention?
- Which table should define revenue, and why?
- Which order statuses should be excluded from revenue reporting?

## Phase 2: SQL Server Load

Tasks:

- Run `00_create_database.sql`.
- Run `01_create_raw_tables.sql`.
- Update the path in `02_load_raw_csvs.sql`.
- Enable SQLCMD Mode in SQL Server Management Studio.
- Run `02_load_raw_csvs.sql`.
- Confirm all raw row counts look reasonable.

Checkpoint:

- No raw table should be empty after load.
- `orders`, `customers`, `products`, `order_items`, `payments`, and `reviews` must all be present.

## Phase 3: Data Modeling

Tasks:

- Run `03_build_star_schema.sql`.
- Review the ER diagram in `er_diagram.md`.
- Confirm that fact tables have valid foreign keys.
- Run `08_data_quality_tests.sql`.

Checkpoint:

- Revenue reconciliation should show zero or near-zero difference.
- Orphan checks should return zero.
- Modeled row counts should align with raw row counts where expected.

## Phase 4: Business SQL

Tasks:

- Run `05_create_powerbi_views.sql`.
- Run `06_stored_procedures.sql`.
- Run `07_business_questions.sql`.
- Export or screenshot key query outputs for the business report.

Expected analysis:

- Top 10 products by revenue.
- Overall repeat purchase rate.
- Monthly revenue growth.
- Customer segment comparison.
- Regional sales trends.
- Payment method performance.
- Review score impact on revenue and delivery experience.

Senior analyst guidance:

- Do not stop at "Product X is highest." Explain whether the product is high because of unit volume, price, repeat demand, or regional concentration.
- For retention, separate "repeat purchase rate" from true cohort retention.
- For reviews, check whether low ratings correlate with late delivery or product categories.

## Phase 5: Power BI Dashboard

Tasks:

- Connect Power BI Desktop to SQL Server.
- Import the `dw` tables or the `mart` views.
- Create DAX measures from `powerbi/dax_measures.md`.
- Build pages according to `powerbi/dashboard_spec.md`.
- Cross-check dashboard totals against `08_data_quality_tests.sql`.

Checkpoint:

- Total revenue in Power BI must equal SQL revenue from `mart.vw_sales_summary`.
- KPI cards should not include canceled or unavailable orders.
- Slicers should filter all relevant visuals.

## Phase 6: Business Report

Tasks:

- Fill in `business_insights_report.md` with actual numbers from SQL and Power BI.
- Add 3 to 5 recommendations.
- Keep recommendations tied to evidence.

Good recommendations sound like:

- "Prioritize retention campaigns for first-time customers in high-revenue states because repeat customers have higher lifetime revenue."
- "Investigate late delivery in categories with low review scores because review score appears connected to delivery delays."
- "Promote high-conversion payment options while monitoring installment behavior and payment value."

## Final Review Checklist

- SQL scripts run in order without errors.
- ERD matches the modeled tables.
- Power BI dashboard has all required pages.
- Business report includes numbers, interpretation, and actions.
- README explains how to reproduce the project.

