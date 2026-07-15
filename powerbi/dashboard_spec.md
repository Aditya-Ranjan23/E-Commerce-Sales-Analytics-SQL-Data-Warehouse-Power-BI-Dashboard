# Power BI Dashboard Specification

## Data Connection

Connect Power BI Desktop to SQL Server:

- Server: your local SQL Server instance
- Database: `ECommerceAnalytics`
- Mode: Import for portfolio performance; DirectQuery only if required

Recommended tables:

- `dw.dim_date`
- `dw.dim_customers`
- `dw.dim_products`
- `dw.fact_orders`
- `dw.fact_order_items`
- `dw.fact_payments`
- `dw.fact_reviews`

Fast-start alternative:

- Import the `mart` views for easier dashboard building.

## Model Relationships

Use single-direction filtering from dimensions to facts:

- `dim_customers[customer_key]` to `fact_orders[customer_key]`
- `dim_date[date_key]` to `fact_orders[purchase_date_key]`
- `dim_products[product_key]` to `fact_order_items[product_key]`
- `fact_orders[order_key]` to `fact_order_items[order_key]`
- `fact_orders[order_key]` to `fact_payments[order_key]`
- `fact_orders[order_key]` to `fact_reviews[order_key]`

Mark `dim_date` as the date table using `dim_date[full_date]`.

## Report Theme

Import `power_bi_theme.json` from this folder. The theme uses a clean e-commerce palette with dark text, blue primary accents, green positive indicators, and red risk indicators.

## Page 1: Executive Overview

Purpose: Give leadership the business pulse in under 30 seconds.

Visuals:

- KPI cards: Total Revenue, Orders, Customers, Repeat Purchase Rate, Average Review Score.
- Line chart: Monthly Revenue and Orders.
- Bar chart: Top 10 Product Categories by Revenue.
- Map or filled map: Revenue by Customer State.
- Slicers: Date, State, Product Category, Payment Type.

Business questions answered:

- How much revenue did we generate?
- Is revenue growing?
- Which categories and regions matter most?
- Are customers coming back?

## Page 2: Sales & Revenue Trends

Purpose: Explain revenue movement over time.

Visuals:

- Combo chart: Revenue and Orders by Month.
- Line chart: Monthly Revenue Growth Percentage.
- Matrix: Year-Month, Revenue, Orders, Customers, Average Order Revenue.
- Waterfall chart: Revenue Change by Month.

Analyst checks:

- Revenue growth should be compared against order growth.
- AOV growth without customer growth may signal price or mix changes.

## Page 3: Customer Retention

Purpose: Show whether the business has repeat purchasing behavior.

Visuals:

- KPI cards: Repeat Customers, Repeat Purchase Rate, Average Lifetime Revenue.
- Donut chart: Customer Segment, one-time vs repeat vs loyal.
- Histogram or bar chart: Days to Second Order.
- Matrix: Customer Segment, Customers, Orders, Revenue, Average Lifetime Revenue.
- Cohort heatmap: Cohort Month by Months Since First Order, Retention Rate.

Business questions answered:

- What share of customers repeat?
- How valuable are repeat customers?
- How quickly do customers make a second purchase?

## Page 4: Product Performance

Purpose: Identify product and category revenue drivers.

Visuals:

- Bar chart: Top 10 Products by Revenue.
- Bar chart: Top Categories by Units Sold.
- Scatter plot: Revenue vs Average Review Score by Category.
- Table: Product ID, Category, Revenue, Units Sold, Orders, Review Score.
- Slicers: Category, State, Date.

Analyst checks:

- Separate high revenue due to high price from high revenue due to high volume.
- Watch for high revenue products with poor reviews.

## Page 5: Regional Performance

Purpose: Find geographic demand concentration and operational risk.

Visuals:

- Filled map: Revenue by State.
- Bar chart: Top Cities by Revenue.
- Line chart: Revenue by Month for selected state.
- Matrix: State, City, Revenue, Orders, Customers, Freight Value.
- Tooltip: Freight as percentage of revenue.

Business questions answered:

- Which regions drive demand?
- Are some regions expensive to serve?
- Where should marketing or logistics investment focus?

## Page 6: Reviews & Customer Experience

Purpose: Connect customer satisfaction with delivery and revenue.

Visuals:

- KPI cards: Average Review Score, Late Delivery Rate, Average Delivery Days.
- Column chart: Revenue by Review Score.
- Line or bar chart: Average Days Late by Review Score.
- Matrix: Category, Review Score, Revenue, Late Item Percentage.
- Table: Low-score, high-revenue categories for action.

Business questions answered:

- Are bad reviews linked to delivery delays?
- Which high-revenue categories create customer experience risk?
- Where should operations intervene?

## Dashboard QA Checklist

- Total Revenue equals SQL from `mart.vw_sales_summary`.
- Revenue excludes canceled and unavailable orders.
- Freight is not mixed into revenue.
- Repeat customer logic uses `customer_unique_id`.
- Date slicer filters all revenue and order visuals.
- State and category slicers cross-filter correctly.
- KPI card formatting uses currency, percentages, and whole-number counts appropriately.

