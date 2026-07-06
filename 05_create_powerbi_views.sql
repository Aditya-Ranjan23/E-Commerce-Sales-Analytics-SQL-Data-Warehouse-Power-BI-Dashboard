/*
Project: E-Commerce Analytics
Purpose: Create Power BI-ready mart views.
*/

USE ECommerceAnalytics;
GO

CREATE OR ALTER VIEW mart.vw_sales_summary AS
SELECT
    fo.order_id,
    foi.order_item_key,
    dd.full_date AS purchase_date,
    dd.year_month,
    dd.calendar_year,
    dd.month_number,
    dc.customer_id,
    dc.customer_unique_id,
    dc.customer_city,
    dc.customer_state,
    dp.product_id,
    dp.product_category_name_english,
    fo.order_status,
    fo.is_delivered,
    fo.is_canceled,
    fo.delivery_days,
    fo.days_late,
    foi.revenue,
    foi.freight_value,
    fr.review_score
FROM dw.fact_order_items AS foi
INNER JOIN dw.fact_orders AS fo
    ON foi.order_key = fo.order_key
LEFT JOIN dw.dim_date AS dd
    ON fo.purchase_date_key = dd.date_key
LEFT JOIN dw.dim_customers AS dc
    ON fo.customer_key = dc.customer_key
LEFT JOIN dw.dim_products AS dp
    ON foi.product_key = dp.product_key
OUTER APPLY (
    SELECT TOP (1) r.review_score
    FROM dw.fact_reviews AS r
    WHERE r.order_key = fo.order_key
    ORDER BY r.review_creation_date DESC
) AS fr
WHERE fo.order_status NOT IN ('canceled', 'unavailable');
GO

CREATE OR ALTER VIEW mart.vw_monthly_revenue AS
WITH monthly AS (
    SELECT
        dd.year_month,
        MIN(dd.full_date) AS month_start_date,
        SUM(foi.revenue) AS revenue,
        SUM(foi.freight_value) AS freight_value,
        COUNT(DISTINCT fo.order_id) AS orders,
        COUNT(DISTINCT dc.customer_unique_id) AS customers,
        SUM(foi.revenue) / NULLIF(COUNT(DISTINCT fo.order_id), 0) AS average_order_revenue
    FROM dw.fact_order_items AS foi
    INNER JOIN dw.fact_orders AS fo
        ON foi.order_key = fo.order_key
    LEFT JOIN dw.dim_date AS dd
        ON fo.purchase_date_key = dd.date_key
    LEFT JOIN dw.dim_customers AS dc
        ON fo.customer_key = dc.customer_key
    WHERE fo.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY dd.year_month
)
SELECT
    year_month,
    month_start_date,
    revenue,
    freight_value,
    orders,
    customers,
    average_order_revenue,
    LAG(revenue) OVER (ORDER BY month_start_date) AS prior_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY month_start_date) AS revenue_change,
    CAST(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month_start_date))
        / NULLIF(LAG(revenue) OVER (ORDER BY month_start_date), 0)
        AS DECIMAL(10,2)
    ) AS revenue_growth_pct
FROM monthly;
GO

CREATE OR ALTER VIEW mart.vw_customer_repeat_behavior AS
WITH customer_orders AS (
    SELECT
        dc.customer_unique_id,
        fo.order_id,
        fo.order_purchase_timestamp,
        SUM(foi.revenue) AS order_revenue
    FROM dw.fact_orders AS fo
    INNER JOIN dw.dim_customers AS dc
        ON fo.customer_key = dc.customer_key
    INNER JOIN dw.fact_order_items AS foi
        ON fo.order_key = foi.order_key
    WHERE fo.order_status NOT IN ('canceled', 'unavailable')
      AND dc.customer_unique_id IS NOT NULL
    GROUP BY
        dc.customer_unique_id,
        fo.order_id,
        fo.order_purchase_timestamp
),
ranked AS (
    SELECT
        customer_unique_id,
        order_id,
        order_purchase_timestamp,
        order_revenue,
        ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY order_purchase_timestamp, order_id) AS order_number
    FROM customer_orders
)
SELECT
    customer_unique_id,
    MIN(order_purchase_timestamp) AS first_order_timestamp,
    MAX(order_purchase_timestamp) AS last_order_timestamp,
    COUNT(*) AS total_orders,
    SUM(order_revenue) AS lifetime_revenue,
    CASE WHEN COUNT(*) > 1 THEN 1 ELSE 0 END AS is_repeat_customer,
    MAX(CASE WHEN order_number = 2 THEN DATEDIFF(DAY, first_order_timestamp, order_purchase_timestamp) END) AS days_to_second_order,
    CASE
        WHEN COUNT(*) >= 4 THEN 'loyal'
        WHEN COUNT(*) >= 2 THEN 'repeat'
        ELSE 'one-time'
    END AS customer_segment
FROM (
    SELECT
        ranked.*,
        MIN(order_purchase_timestamp) OVER (PARTITION BY customer_unique_id) AS first_order_timestamp
    FROM ranked
) AS x
GROUP BY customer_unique_id;
GO

CREATE OR ALTER VIEW mart.vw_product_revenue_rank AS
WITH product_revenue AS (
    SELECT
        dp.product_id,
        dp.product_category_name_english,
        SUM(foi.revenue) AS revenue,
        SUM(foi.freight_value) AS freight_value,
        COUNT(*) AS units_sold,
        COUNT(DISTINCT fo.order_id) AS orders,
        AVG(CAST(fr.review_score AS DECIMAL(10,2))) AS average_review_score
    FROM dw.fact_order_items AS foi
    INNER JOIN dw.fact_orders AS fo
        ON foi.order_key = fo.order_key
    LEFT JOIN dw.dim_products AS dp
        ON foi.product_key = dp.product_key
    OUTER APPLY (
        SELECT TOP (1) r.review_score
        FROM dw.fact_reviews AS r
        WHERE r.order_key = fo.order_key
        ORDER BY r.review_creation_date DESC, r.review_key DESC
    ) AS fr
    WHERE fo.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY
        dp.product_id,
        dp.product_category_name_english
)
SELECT
    product_id,
    product_category_name_english,
    revenue,
    freight_value,
    units_sold,
    orders,
    average_review_score,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM product_revenue;
GO

CREATE OR ALTER VIEW mart.vw_regional_sales AS
WITH regional_monthly AS (
    SELECT
        dc.customer_state,
        dc.customer_city,
        dd.year_month,
        MIN(dd.full_date) AS month_start_date,
        SUM(foi.revenue) AS revenue,
        SUM(foi.freight_value) AS freight_value,
        COUNT(DISTINCT fo.order_id) AS orders,
        COUNT(DISTINCT dc.customer_unique_id) AS customers
    FROM dw.fact_order_items AS foi
    INNER JOIN dw.fact_orders AS fo
        ON foi.order_key = fo.order_key
    LEFT JOIN dw.dim_customers AS dc
        ON fo.customer_key = dc.customer_key
    LEFT JOIN dw.dim_date AS dd
        ON fo.purchase_date_key = dd.date_key
    WHERE fo.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY
        dc.customer_state,
        dc.customer_city,
        dd.year_month
)
SELECT
    customer_state,
    customer_city,
    year_month,
    month_start_date,
    revenue,
    freight_value,
    orders,
    customers,
    DENSE_RANK() OVER (PARTITION BY year_month ORDER BY revenue DESC) AS regional_revenue_rank_in_month
FROM regional_monthly;
GO

CREATE OR ALTER VIEW mart.vw_review_performance AS
WITH selected_review AS (
    SELECT
        order_key,
        review_score
    FROM (
        SELECT
            order_key,
            review_score,
            ROW_NUMBER() OVER (PARTITION BY order_key ORDER BY review_creation_date DESC, review_key DESC) AS review_rank
        FROM dw.fact_reviews
    ) AS ranked_reviews
    WHERE review_rank = 1
)
SELECT
    sr.review_score,
    dp.product_category_name_english,
    COUNT(DISTINCT fo.order_id) AS reviewed_orders,
    SUM(foi.revenue) AS revenue,
    AVG(CAST(fo.delivery_days AS DECIMAL(10,2))) AS average_delivery_days,
    AVG(CAST(fo.days_late AS DECIMAL(10,2))) AS average_days_late,
    SUM(CASE WHEN fo.days_late > 0 THEN 1 ELSE 0 END) AS late_order_items,
    CAST(100.0 * SUM(CASE WHEN fo.days_late > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS DECIMAL(10,2)) AS late_item_pct
FROM selected_review AS sr
INNER JOIN dw.fact_orders AS fo
    ON sr.order_key = fo.order_key
INNER JOIN dw.fact_order_items AS foi
    ON fo.order_key = foi.order_key
LEFT JOIN dw.dim_products AS dp
    ON foi.product_key = dp.product_key
WHERE fo.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
    sr.review_score,
    dp.product_category_name_english;
GO

CREATE OR ALTER VIEW mart.vw_payment_performance AS
SELECT
    fp.payment_type,
    fp.payment_installments,
    COUNT(DISTINCT fo.order_id) AS orders,
    SUM(fp.payment_value) AS payment_value,
    AVG(CAST(fp.payment_value AS DECIMAL(18,2))) AS average_payment_value,
    AVG(CAST(foi.order_revenue AS DECIMAL(18,2))) AS average_order_revenue
FROM dw.fact_payments AS fp
INNER JOIN dw.fact_orders AS fo
    ON fp.order_key = fo.order_key
OUTER APPLY (
    SELECT SUM(foi.revenue) AS order_revenue
    FROM dw.fact_order_items AS foi
    WHERE foi.order_key = fo.order_key
) AS foi
WHERE fo.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
    fp.payment_type,
    fp.payment_installments;
GO
