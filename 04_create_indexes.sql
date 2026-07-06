/*
Project: E-Commerce Analytics
Purpose: Add indexes for analytical joins, filters, and Power BI refresh performance.
*/

USE ECommerceAnalytics;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_dim_customers_unique_id' AND object_id = OBJECT_ID('dw.dim_customers'))
    CREATE INDEX IX_dim_customers_unique_id ON dw.dim_customers(customer_unique_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_dim_customers_state_city' AND object_id = OBJECT_ID('dw.dim_customers'))
    CREATE INDEX IX_dim_customers_state_city ON dw.dim_customers(customer_state, customer_city);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_dim_products_category' AND object_id = OBJECT_ID('dw.dim_products'))
    CREATE INDEX IX_dim_products_category ON dw.dim_products(product_category_name_english);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_fact_orders_status_purchase_date' AND object_id = OBJECT_ID('dw.fact_orders'))
    CREATE INDEX IX_fact_orders_status_purchase_date ON dw.fact_orders(order_status, purchase_date_key) INCLUDE (customer_key, order_purchase_timestamp);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_fact_orders_customer' AND object_id = OBJECT_ID('dw.fact_orders'))
    CREATE INDEX IX_fact_orders_customer ON dw.fact_orders(customer_key, order_purchase_timestamp);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_fact_order_items_order' AND object_id = OBJECT_ID('dw.fact_order_items'))
    CREATE INDEX IX_fact_order_items_order ON dw.fact_order_items(order_key) INCLUDE (revenue, freight_value, product_key);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_fact_order_items_product' AND object_id = OBJECT_ID('dw.fact_order_items'))
    CREATE INDEX IX_fact_order_items_product ON dw.fact_order_items(product_key) INCLUDE (revenue, freight_value);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_fact_payments_order_type' AND object_id = OBJECT_ID('dw.fact_payments'))
    CREATE INDEX IX_fact_payments_order_type ON dw.fact_payments(order_key, payment_type) INCLUDE (payment_value, payment_installments);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_fact_reviews_order_score' AND object_id = OBJECT_ID('dw.fact_reviews'))
    CREATE INDEX IX_fact_reviews_order_score ON dw.fact_reviews(order_key, review_score);
GO

