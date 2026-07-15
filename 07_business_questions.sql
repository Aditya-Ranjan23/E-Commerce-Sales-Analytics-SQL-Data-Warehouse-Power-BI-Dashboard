/*
Project: E-Commerce Analytics
Purpose: Analyst queries that answer the main business questions.
*/

USE ECommerceAnalytics;
GO

/* 1. Top 10 products by revenue */
SELECT TOP (10)
    product_id,
    product_category_name_english,
    revenue,
    units_sold,
    orders,
    average_review_score,
    revenue_rank
FROM mart.vw_product_revenue_rank
ORDER BY revenue_rank;
GO

/* 2. Overall customer repeat purchase rate */
SELECT
    COUNT(*) AS customers,
    SUM(is_repeat_customer) AS repeat_customers,
    CAST(100.0 * SUM(is_repeat_customer) / NULLIF(COUNT(*), 0) AS DECIMAL(10,2)) AS repeat_purchase_rate_pct
FROM mart.vw_customer_repeat_behavior;
GO

/* 3. Monthly revenue growth */
SELECT
    year_month,
    revenue,
    prior_month_revenue,
    revenue_change,
    revenue_growth_pct,
    orders,
    customers,
    average_order_revenue
FROM mart.vw_monthly_revenue
ORDER BY month_start_date;
GO

/* 4. Repeat customer analysis by segment */
SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(total_orders) AS orders,
    SUM(lifetime_revenue) AS revenue,
    AVG(CAST(lifetime_revenue AS DECIMAL(18,2))) AS average_lifetime_revenue,
    AVG(CAST(days_to_second_order AS DECIMAL(18,2))) AS average_days_to_second_order
FROM mart.vw_customer_repeat_behavior
GROUP BY customer_segment
ORDER BY revenue DESC;
GO

/* 5. Regional sales trends */
WITH state_month AS (
    SELECT
        customer_state,
        year_month,
        SUM(revenue) AS revenue,
        SUM(orders) AS orders,
        SUM(customers) AS customers
    FROM mart.vw_regional_sales
    GROUP BY customer_state, year_month
)
SELECT
    customer_state,
    year_month,
    revenue,
    orders,
    customers,
    DENSE_RANK() OVER (PARTITION BY year_month ORDER BY revenue DESC) AS state_rank_in_month,
    CAST(100.0 * revenue / NULLIF(SUM(revenue) OVER (PARTITION BY year_month), 0) AS DECIMAL(10,2)) AS revenue_share_pct
FROM state_month
ORDER BY year_month, state_rank_in_month;
GO

/* 6. Payment method performance */
SELECT
    payment_type,
    SUM(orders) AS orders,
    SUM(payment_value) AS payment_value,
    AVG(average_payment_value) AS average_payment_value,
    AVG(average_order_revenue) AS average_order_revenue
FROM mart.vw_payment_performance
GROUP BY payment_type
ORDER BY payment_value DESC;
GO

/* 7. Review score impact on revenue and delivery experience */
SELECT
    review_score,
    SUM(reviewed_orders) AS reviewed_orders,
    SUM(revenue) AS revenue,
    AVG(average_delivery_days) AS average_delivery_days,
    AVG(average_days_late) AS average_days_late,
    AVG(late_item_pct) AS average_late_item_pct
FROM mart.vw_review_performance
GROUP BY review_score
ORDER BY review_score;
GO

/* 8. Customer cohort retention by first purchase month */
WITH customer_orders AS (
    SELECT
        dc.customer_unique_id,
        DATEFROMPARTS(dd.calendar_year, dd.month_number, 1) AS order_month
    FROM dw.fact_orders AS fo
    INNER JOIN dw.dim_customers AS dc
        ON fo.customer_key = dc.customer_key
    INNER JOIN dw.dim_date AS dd
        ON fo.purchase_date_key = dd.date_key
    WHERE fo.order_status NOT IN ('canceled', 'unavailable')
      AND dc.customer_unique_id IS NOT NULL
    GROUP BY dc.customer_unique_id, DATEFROMPARTS(dd.calendar_year, dd.month_number, 1)
),
cohorts AS (
    SELECT
        customer_unique_id,
        MIN(order_month) AS cohort_month
    FROM customer_orders
    GROUP BY customer_unique_id
),
retention AS (
    SELECT
        c.cohort_month,
        DATEDIFF(MONTH, c.cohort_month, co.order_month) AS months_since_first_order,
        COUNT(DISTINCT co.customer_unique_id) AS active_customers
    FROM cohorts AS c
    INNER JOIN customer_orders AS co
        ON c.customer_unique_id = co.customer_unique_id
    GROUP BY c.cohort_month, DATEDIFF(MONTH, c.cohort_month, co.order_month)
)
SELECT
    cohort_month,
    months_since_first_order,
    active_customers,
    MAX(CASE WHEN months_since_first_order = 0 THEN active_customers END)
        OVER (PARTITION BY cohort_month) AS cohort_size,
    CAST(
        100.0 * active_customers
        / NULLIF(MAX(CASE WHEN months_since_first_order = 0 THEN active_customers END)
            OVER (PARTITION BY cohort_month), 0)
        AS DECIMAL(10,2)
    ) AS retention_rate_pct
FROM retention
ORDER BY cohort_month, months_since_first_order;
GO
