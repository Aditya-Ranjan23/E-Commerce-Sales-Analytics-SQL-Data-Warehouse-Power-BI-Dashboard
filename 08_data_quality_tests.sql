/*
Project: E-Commerce Analytics
Purpose: Validation checks for raw load, star-schema build, and KPI reconciliation.
*/

USE ECommerceAnalytics;
GO

/* Raw row counts */
SELECT 'raw.customers' AS check_name, COUNT(*) AS value FROM raw.customers
UNION ALL SELECT 'raw.orders', COUNT(*) FROM raw.orders
UNION ALL SELECT 'raw.order_items', COUNT(*) FROM raw.order_items
UNION ALL SELECT 'raw.products', COUNT(*) FROM raw.products
UNION ALL SELECT 'raw.payments', COUNT(*) FROM raw.payments
UNION ALL SELECT 'raw.reviews', COUNT(*) FROM raw.reviews;
GO

/* Duplicate primary business keys in raw files */
SELECT 'duplicate raw.orders.order_id' AS check_name, COUNT(*) AS issue_count
FROM (
    SELECT order_id
    FROM raw.orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
) AS x
UNION ALL
SELECT 'duplicate raw.customers.customer_id', COUNT(*)
FROM (
    SELECT customer_id
    FROM raw.customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) AS x
UNION ALL
SELECT 'duplicate raw.products.product_id', COUNT(*)
FROM (
    SELECT product_id
    FROM raw.products
    GROUP BY product_id
    HAVING COUNT(*) > 1
) AS x;
GO

/* Star schema row counts */
SELECT 'dw.dim_customers' AS check_name, COUNT(*) AS value FROM dw.dim_customers
UNION ALL SELECT 'dw.dim_products', COUNT(*) FROM dw.dim_products
UNION ALL SELECT 'dw.fact_orders', COUNT(*) FROM dw.fact_orders
UNION ALL SELECT 'dw.fact_order_items', COUNT(*) FROM dw.fact_order_items
UNION ALL SELECT 'dw.fact_payments', COUNT(*) FROM dw.fact_payments
UNION ALL SELECT 'dw.fact_reviews', COUNT(*) FROM dw.fact_reviews;
GO

/* Orphan checks should return zero */
SELECT 'fact_order_items without order' AS check_name, COUNT(*) AS issue_count
FROM dw.fact_order_items AS foi
LEFT JOIN dw.fact_orders AS fo
    ON foi.order_key = fo.order_key
WHERE fo.order_key IS NULL
UNION ALL
SELECT 'fact_payments without order', COUNT(*)
FROM dw.fact_payments AS fp
LEFT JOIN dw.fact_orders AS fo
    ON fp.order_key = fo.order_key
WHERE fo.order_key IS NULL
UNION ALL
SELECT 'fact_reviews without order', COUNT(*)
FROM dw.fact_reviews AS fr
LEFT JOIN dw.fact_orders AS fo
    ON fr.order_key = fo.order_key
WHERE fo.order_key IS NULL;
GO

/* Revenue reconciliation between raw and modeled data for non-canceled orders */
WITH raw_revenue AS (
    SELECT
        SUM(COALESCE(TRY_CONVERT(DECIMAL(18,2), oi.price), 0.00)) AS revenue
    FROM raw.order_items AS oi
    INNER JOIN raw.orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
modeled_revenue AS (
    SELECT SUM(foi.revenue) AS revenue
    FROM dw.fact_order_items AS foi
    INNER JOIN dw.fact_orders AS fo
        ON foi.order_key = fo.order_key
    WHERE fo.order_status NOT IN ('canceled', 'unavailable')
)
SELECT
    raw_revenue.revenue AS raw_revenue,
    modeled_revenue.revenue AS modeled_revenue,
    raw_revenue.revenue - modeled_revenue.revenue AS difference
FROM raw_revenue
CROSS JOIN modeled_revenue;
GO

/* Orders excluded from revenue views */
SELECT
    order_status,
    COUNT(*) AS orders
FROM dw.fact_orders
GROUP BY order_status
ORDER BY orders DESC;
GO

/* Power BI KPI cross-check */
SELECT
    SUM(revenue) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    SUM(freight_value) AS total_freight
FROM mart.vw_sales_summary;
GO

