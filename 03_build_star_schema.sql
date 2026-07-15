/*
Project: E-Commerce Analytics
Purpose: Build dimensional model from raw Olist tables.

Modeling rules:
- Revenue = item price.
- Freight = delivery cost, tracked separately.
- customer_unique_id is the real customer identifier for retention analysis.
- customer_id is the order-level customer identifier used by Olist.
*/

USE ECommerceAnalytics;
GO

DROP TABLE IF EXISTS dw.fact_reviews;
DROP TABLE IF EXISTS dw.fact_payments;
DROP TABLE IF EXISTS dw.fact_order_items;
DROP TABLE IF EXISTS dw.fact_orders;
DROP TABLE IF EXISTS dw.dim_products;
DROP TABLE IF EXISTS dw.dim_customers;
DROP TABLE IF EXISTS dw.dim_date;
GO

CREATE TABLE dw.dim_date (
    date_key INT NOT NULL PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    calendar_year SMALLINT NOT NULL,
    calendar_quarter TINYINT NOT NULL,
    month_number TINYINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    year_month CHAR(7) NOT NULL,
    day_of_month TINYINT NOT NULL,
    day_of_week TINYINT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    week_of_year TINYINT NOT NULL,
    is_weekend BIT NOT NULL
);
GO

CREATE TABLE dw.dim_customers (
    customer_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    customer_id NVARCHAR(50) NOT NULL UNIQUE,
    customer_unique_id NVARCHAR(50) NULL,
    customer_zip_code_prefix NVARCHAR(20) NULL,
    customer_city NVARCHAR(100) NULL,
    customer_state NVARCHAR(10) NULL
);
GO

CREATE TABLE dw.dim_products (
    product_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    product_id NVARCHAR(50) NOT NULL UNIQUE,
    product_category_name NVARCHAR(100) NULL,
    product_category_name_english NVARCHAR(100) NULL,
    product_name_length INT NULL,
    product_description_length INT NULL,
    product_photos_qty INT NULL,
    product_weight_g DECIMAL(12,2) NULL,
    product_length_cm DECIMAL(12,2) NULL,
    product_height_cm DECIMAL(12,2) NULL,
    product_width_cm DECIMAL(12,2) NULL
);
GO

CREATE TABLE dw.fact_orders (
    order_key INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    order_id NVARCHAR(50) NOT NULL UNIQUE,
    customer_key INT NULL,
    order_status NVARCHAR(30) NULL,
    purchase_date_key INT NULL,
    approved_date_key INT NULL,
    delivered_customer_date_key INT NULL,
    estimated_delivery_date_key INT NULL,
    order_purchase_timestamp DATETIME2(0) NULL,
    order_approved_at DATETIME2(0) NULL,
    order_delivered_carrier_date DATETIME2(0) NULL,
    order_delivered_customer_date DATETIME2(0) NULL,
    order_estimated_delivery_date DATETIME2(0) NULL,
    delivery_days INT NULL,
    days_late INT NULL,
    is_delivered BIT NOT NULL,
    is_canceled BIT NOT NULL,
    CONSTRAINT FK_fact_orders_customers FOREIGN KEY (customer_key) REFERENCES dw.dim_customers(customer_key),
    CONSTRAINT FK_fact_orders_purchase_date FOREIGN KEY (purchase_date_key) REFERENCES dw.dim_date(date_key),
    CONSTRAINT FK_fact_orders_approved_date FOREIGN KEY (approved_date_key) REFERENCES dw.dim_date(date_key),
    CONSTRAINT FK_fact_orders_delivered_date FOREIGN KEY (delivered_customer_date_key) REFERENCES dw.dim_date(date_key),
    CONSTRAINT FK_fact_orders_estimated_date FOREIGN KEY (estimated_delivery_date_key) REFERENCES dw.dim_date(date_key)
);
GO

CREATE TABLE dw.fact_order_items (
    order_item_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    order_key INT NOT NULL,
    product_key INT NULL,
    order_id NVARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id NVARCHAR(50) NULL,
    seller_id NVARCHAR(50) NULL,
    shipping_limit_date DATETIME2(0) NULL,
    revenue DECIMAL(18,2) NOT NULL,
    freight_value DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_fact_order_items_orders FOREIGN KEY (order_key) REFERENCES dw.fact_orders(order_key),
    CONSTRAINT FK_fact_order_items_products FOREIGN KEY (product_key) REFERENCES dw.dim_products(product_key)
);
GO

CREATE TABLE dw.fact_payments (
    payment_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    order_key INT NOT NULL,
    order_id NVARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type NVARCHAR(40) NULL,
    payment_installments INT NULL,
    payment_value DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_fact_payments_orders FOREIGN KEY (order_key) REFERENCES dw.fact_orders(order_key)
);
GO

CREATE TABLE dw.fact_reviews (
    review_key BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    order_key INT NOT NULL,
    review_id NVARCHAR(50) NOT NULL,
    order_id NVARCHAR(50) NOT NULL,
    review_score INT NULL,
    review_comment_title NVARCHAR(500) NULL,
    review_comment_message NVARCHAR(MAX) NULL,
    review_creation_date_key INT NULL,
    review_answer_date_key INT NULL,
    review_creation_date DATETIME2(0) NULL,
    review_answer_timestamp DATETIME2(0) NULL,
    CONSTRAINT FK_fact_reviews_orders FOREIGN KEY (order_key) REFERENCES dw.fact_orders(order_key),
    CONSTRAINT FK_fact_reviews_creation_date FOREIGN KEY (review_creation_date_key) REFERENCES dw.dim_date(date_key),
    CONSTRAINT FK_fact_reviews_answer_date FOREIGN KEY (review_answer_date_key) REFERENCES dw.dim_date(date_key)
);
GO

DECLARE @min_date DATE;
DECLARE @max_date DATE;

WITH all_dates AS (
    SELECT TRY_CONVERT(DATE, order_purchase_timestamp) AS d FROM raw.orders
    UNION ALL SELECT TRY_CONVERT(DATE, order_approved_at) FROM raw.orders
    UNION ALL SELECT TRY_CONVERT(DATE, order_delivered_customer_date) FROM raw.orders
    UNION ALL SELECT TRY_CONVERT(DATE, order_estimated_delivery_date) FROM raw.orders
    UNION ALL SELECT TRY_CONVERT(DATE, review_creation_date) FROM raw.reviews
    UNION ALL SELECT TRY_CONVERT(DATE, review_answer_timestamp) FROM raw.reviews
)
SELECT
    @min_date = MIN(d),
    @max_date = MAX(d)
FROM all_dates
WHERE d IS NOT NULL;

IF @min_date IS NULL OR @max_date IS NULL
BEGIN
    THROW 50001, 'No valid dates found in raw tables. Load raw CSVs before building the star schema.', 1;
END;

WITH date_spine AS (
    SELECT @min_date AS full_date
    UNION ALL
    SELECT DATEADD(DAY, 1, full_date)
    FROM date_spine
    WHERE full_date < @max_date
)
INSERT INTO dw.dim_date (
    date_key,
    full_date,
    calendar_year,
    calendar_quarter,
    month_number,
    month_name,
    year_month,
    day_of_month,
    day_of_week,
    day_name,
    week_of_year,
    is_weekend
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), full_date, 112)) AS date_key,
    full_date,
    DATEPART(YEAR, full_date) AS calendar_year,
    DATEPART(QUARTER, full_date) AS calendar_quarter,
    DATEPART(MONTH, full_date) AS month_number,
    DATENAME(MONTH, full_date) AS month_name,
    CONVERT(CHAR(7), full_date, 120) AS year_month,
    DATEPART(DAY, full_date) AS day_of_month,
    DATEPART(WEEKDAY, full_date) AS day_of_week,
    DATENAME(WEEKDAY, full_date) AS day_name,
    DATEPART(WEEK, full_date) AS week_of_year,
    CASE WHEN DATENAME(WEEKDAY, full_date) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS is_weekend
FROM date_spine
OPTION (MAXRECURSION 0);
GO

INSERT INTO dw.dim_customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    c.customer_id,
    NULLIF(c.customer_unique_id, '') AS customer_unique_id,
    NULLIF(c.customer_zip_code_prefix, '') AS customer_zip_code_prefix,
    LOWER(NULLIF(c.customer_city, '')) AS customer_city,
    UPPER(NULLIF(c.customer_state, '')) AS customer_state
FROM raw.customers AS c
WHERE c.customer_id IS NOT NULL;
GO

INSERT INTO dw.dim_products (
    product_id,
    product_category_name,
    product_category_name_english,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    p.product_id,
    NULLIF(p.product_category_name, '') AS product_category_name,
    COALESCE(NULLIF(t.product_category_name_english, ''), NULLIF(p.product_category_name, ''), 'unknown') AS product_category_name_english,
    TRY_CONVERT(INT, p.product_name_lenght) AS product_name_length,
    TRY_CONVERT(INT, p.product_description_lenght) AS product_description_length,
    TRY_CONVERT(INT, p.product_photos_qty) AS product_photos_qty,
    TRY_CONVERT(DECIMAL(12,2), p.product_weight_g) AS product_weight_g,
    TRY_CONVERT(DECIMAL(12,2), p.product_length_cm) AS product_length_cm,
    TRY_CONVERT(DECIMAL(12,2), p.product_height_cm) AS product_height_cm,
    TRY_CONVERT(DECIMAL(12,2), p.product_width_cm) AS product_width_cm
FROM raw.products AS p
LEFT JOIN raw.product_category_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE p.product_id IS NOT NULL;
GO

WITH cleaned_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        NULLIF(o.order_status, '') AS order_status,
        TRY_CONVERT(DATETIME2(0), o.order_purchase_timestamp) AS order_purchase_timestamp,
        TRY_CONVERT(DATETIME2(0), o.order_approved_at) AS order_approved_at,
        TRY_CONVERT(DATETIME2(0), o.order_delivered_carrier_date) AS order_delivered_carrier_date,
        TRY_CONVERT(DATETIME2(0), o.order_delivered_customer_date) AS order_delivered_customer_date,
        TRY_CONVERT(DATETIME2(0), o.order_estimated_delivery_date) AS order_estimated_delivery_date
    FROM raw.orders AS o
)
INSERT INTO dw.fact_orders (
    order_id,
    customer_key,
    order_status,
    purchase_date_key,
    approved_date_key,
    delivered_customer_date_key,
    estimated_delivery_date_key,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    delivery_days,
    days_late,
    is_delivered,
    is_canceled
)
SELECT
    o.order_id,
    c.customer_key,
    o.order_status,
    CONVERT(INT, CONVERT(CHAR(8), CAST(o.order_purchase_timestamp AS DATE), 112)) AS purchase_date_key,
    CONVERT(INT, CONVERT(CHAR(8), CAST(o.order_approved_at AS DATE), 112)) AS approved_date_key,
    CONVERT(INT, CONVERT(CHAR(8), CAST(o.order_delivered_customer_date AS DATE), 112)) AS delivered_customer_date_key,
    CONVERT(INT, CONVERT(CHAR(8), CAST(o.order_estimated_delivery_date AS DATE), 112)) AS estimated_delivery_date_key,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    CASE
        WHEN o.order_purchase_timestamp IS NOT NULL
             AND o.order_delivered_customer_date IS NOT NULL
        THEN DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)
    END AS delivery_days,
    CASE
        WHEN o.order_estimated_delivery_date IS NOT NULL
             AND o.order_delivered_customer_date IS NOT NULL
        THEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date)
    END AS days_late,
    CASE WHEN o.order_status = 'delivered' THEN 1 ELSE 0 END AS is_delivered,
    CASE WHEN o.order_status IN ('canceled', 'unavailable') THEN 1 ELSE 0 END AS is_canceled
FROM cleaned_orders AS o
LEFT JOIN dw.dim_customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_id IS NOT NULL;
GO

INSERT INTO dw.fact_order_items (
    order_key,
    product_key,
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    revenue,
    freight_value
)
SELECT
    fo.order_key,
    dp.product_key,
    oi.order_id,
    TRY_CONVERT(INT, oi.order_item_id) AS order_item_id,
    oi.product_id,
    NULLIF(oi.seller_id, '') AS seller_id,
    TRY_CONVERT(DATETIME2(0), oi.shipping_limit_date) AS shipping_limit_date,
    COALESCE(TRY_CONVERT(DECIMAL(18,2), oi.price), 0.00) AS revenue,
    COALESCE(TRY_CONVERT(DECIMAL(18,2), oi.freight_value), 0.00) AS freight_value
FROM raw.order_items AS oi
INNER JOIN dw.fact_orders AS fo
    ON oi.order_id = fo.order_id
LEFT JOIN dw.dim_products AS dp
    ON oi.product_id = dp.product_id
WHERE oi.order_id IS NOT NULL
  AND TRY_CONVERT(INT, oi.order_item_id) IS NOT NULL;
GO

INSERT INTO dw.fact_payments (
    order_key,
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    fo.order_key,
    p.order_id,
    TRY_CONVERT(INT, p.payment_sequential) AS payment_sequential,
    NULLIF(p.payment_type, '') AS payment_type,
    TRY_CONVERT(INT, p.payment_installments) AS payment_installments,
    COALESCE(TRY_CONVERT(DECIMAL(18,2), p.payment_value), 0.00) AS payment_value
FROM raw.payments AS p
INNER JOIN dw.fact_orders AS fo
    ON p.order_id = fo.order_id
WHERE p.order_id IS NOT NULL
  AND TRY_CONVERT(INT, p.payment_sequential) IS NOT NULL;
GO

INSERT INTO dw.fact_reviews (
    order_key,
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date_key,
    review_answer_date_key,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    fo.order_key,
    r.review_id,
    r.order_id,
    TRY_CONVERT(INT, r.review_score) AS review_score,
    NULL AS review_comment_title,
    NULL AS review_comment_message,
    CONVERT(INT, CONVERT(CHAR(8), CAST(TRY_CONVERT(DATETIME2(0), r.review_creation_date) AS DATE), 112)) AS review_creation_date_key,
    CONVERT(INT, CONVERT(CHAR(8), CAST(TRY_CONVERT(DATETIME2(0), r.review_answer_timestamp) AS DATE), 112)) AS review_answer_date_key,
    TRY_CONVERT(DATETIME2(0), r.review_creation_date) AS review_creation_date,
    TRY_CONVERT(DATETIME2(0), r.review_answer_timestamp) AS review_answer_timestamp
FROM raw.reviews AS r
INNER JOIN dw.fact_orders AS fo
    ON r.order_id = fo.order_id
WHERE r.order_id IS NOT NULL
  AND r.review_id IS NOT NULL;
GO

SELECT 'dw.dim_date' AS table_name, COUNT(*) AS row_count FROM dw.dim_date
UNION ALL SELECT 'dw.dim_customers', COUNT(*) FROM dw.dim_customers
UNION ALL SELECT 'dw.dim_products', COUNT(*) FROM dw.dim_products
UNION ALL SELECT 'dw.fact_orders', COUNT(*) FROM dw.fact_orders
UNION ALL SELECT 'dw.fact_order_items', COUNT(*) FROM dw.fact_order_items
UNION ALL SELECT 'dw.fact_payments', COUNT(*) FROM dw.fact_payments
UNION ALL SELECT 'dw.fact_reviews', COUNT(*) FROM dw.fact_reviews;
GO

