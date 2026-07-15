# Business Insights Report

## Executive Summary

This project analyzes e-commerce performance across orders, customers, products, payments, regions, and reviews. The goal is to identify revenue drivers, repeat purchase behavior, regional opportunities, and customer experience risks.

Fill in the summary after running the SQL scripts and building the Power BI dashboard:

- Total revenue:
- Total orders:
- Total customers:
- Repeat purchase rate:
- Best revenue month:
- Top revenue state:
- Top product category:
- Average review score:

## Metric Definitions

- Revenue: Sum of item price from `fact_order_items.revenue`. Freight is excluded.
- Freight value: Sum of `fact_order_items.freight_value`.
- Order count: Distinct non-canceled, non-unavailable orders.
- Customer count: Distinct `customer_unique_id`.
- Repeat customer: Customer with more than one valid order.
- Repeat purchase rate: Repeat customers divided by all purchasing customers.
- Monthly revenue growth: Current month revenue compared with previous month revenue.
- Late delivery: Delivered date after estimated delivery date.

## Key Findings

### 1. Revenue Performance

SQL source:

```sql
SELECT *
FROM mart.vw_monthly_revenue
ORDER BY month_start_date;
```

Insert observations:

- Revenue trend:
- Highest revenue month:
- Largest month-over-month increase:
- Largest month-over-month decline:

Analyst interpretation:

Revenue movement should be explained using order volume, average order revenue, and customer count. If revenue grows but customers do not, the business may be relying on higher basket size rather than broader acquisition.

### 2. Product Performance

SQL source:

```sql
SELECT TOP (10) *
FROM mart.vw_product_revenue_rank
ORDER BY revenue_rank;
```

Insert observations:

- Top product:
- Top category:
- Category with strong revenue but weak review score:
- Category with high units sold but low average revenue:

Analyst interpretation:

High revenue products should be reviewed for margin, fulfillment reliability, and review quality. A product that sells well but receives weak reviews can become a future churn risk.

### 3. Customer Retention

SQL source:

```sql
SELECT *
FROM mart.vw_customer_repeat_behavior;
```

Insert observations:

- Repeat purchase rate:
- Average lifetime revenue for one-time customers:
- Average lifetime revenue for repeat customers:
- Average days to second order:

Analyst interpretation:

If repeat purchase rate is low, the company should focus on post-purchase campaigns, personalized offers, and category-specific reactivation. If repeat customers have much higher lifetime revenue, retention investment is easier to justify.

### 4. Regional Sales Trends

SQL source:

```sql
SELECT *
FROM mart.vw_regional_sales
ORDER BY month_start_date, regional_revenue_rank_in_month;
```

Insert observations:

- Top state:
- Fastest-growing state:
- City with concentrated demand:
- Region with high freight burden:

Analyst interpretation:

Regional concentration can guide marketing spend, warehouse planning, and delivery partnerships. High revenue with high freight may indicate margin pressure.

### 5. Payment Behavior

SQL source:

```sql
SELECT *
FROM mart.vw_payment_performance
ORDER BY payment_value DESC;
```

Insert observations:

- Most common payment type:
- Highest payment value type:
- Installment pattern:
- Average order revenue by payment method:

Analyst interpretation:

Payment preference affects checkout conversion and customer affordability. Installment-heavy categories may benefit from targeted financing offers.

### 6. Reviews And Customer Experience

SQL source:

```sql
SELECT *
FROM mart.vw_review_performance
ORDER BY review_score;
```

Insert observations:

- Average review score:
- Review score group with highest late delivery rate:
- Category with low reviews and high revenue:
- Relationship between delivery days and score:

Analyst interpretation:

Low review scores should be diagnosed against delivery timeliness and product category. If late delivery is linked to poor reviews, improving logistics can improve both customer satisfaction and repeat purchase probability.

## Recommendations

1. Protect top revenue categories with quality monitoring and fulfillment checks.
2. Build first-to-second-order campaigns for new customers within the average repurchase window.
3. Increase marketing focus in high-revenue regions, but monitor freight cost impact.
4. Investigate categories where low review scores overlap with late delivery.
5. Use preferred payment methods and installment insights to optimize checkout promotions.

## Appendix: SQL Files Used

- `sql/05_create_powerbi_views.sql`
- `sql/06_stored_procedures.sql`
- `sql/07_business_questions.sql`
- `sql/08_data_quality_tests.sql`

