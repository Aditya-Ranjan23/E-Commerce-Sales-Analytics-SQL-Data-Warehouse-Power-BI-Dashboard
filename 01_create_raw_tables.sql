/*
Project: E-Commerce Analytics
Purpose: Create raw landing tables for the Olist CSV files.

Raw columns are stored as text to make CSV import resilient. Type conversion happens
in the star-schema build script with TRY_CONVERT.
*/

USE ECommerceAnalytics;
GO

DROP TABLE IF EXISTS raw.product_category_translation;
DROP TABLE IF EXISTS raw.geolocation;
DROP TABLE IF EXISTS raw.reviews;
DROP TABLE IF EXISTS raw.payments;
DROP TABLE IF EXISTS raw.order_items;
DROP TABLE IF EXISTS raw.products;
DROP TABLE IF EXISTS raw.orders;
DROP TABLE IF EXISTS raw.customers;
GO

CREATE TABLE raw.customers (
    customer_id NVARCHAR(50) NOT NULL,
    customer_unique_id NVARCHAR(50) NULL,
    customer_zip_code_prefix NVARCHAR(20) NULL,
    customer_city NVARCHAR(100) NULL,
    customer_state NVARCHAR(10) NULL
);
GO

CREATE TABLE raw.orders (
    order_id NVARCHAR(50) NOT NULL,
    customer_id NVARCHAR(50) NULL,
    order_status NVARCHAR(30) NULL,
    order_purchase_timestamp NVARCHAR(40) NULL,
    order_approved_at NVARCHAR(40) NULL,
    order_delivered_carrier_date NVARCHAR(40) NULL,
    order_delivered_customer_date NVARCHAR(40) NULL,
    order_estimated_delivery_date NVARCHAR(40) NULL
);
GO

CREATE TABLE raw.order_items (
    order_id NVARCHAR(50) NOT NULL,
    order_item_id NVARCHAR(20) NOT NULL,
    product_id NVARCHAR(50) NULL,
    seller_id NVARCHAR(50) NULL,
    shipping_limit_date NVARCHAR(40) NULL,
    price NVARCHAR(40) NULL,
    freight_value NVARCHAR(40) NULL
);
GO

CREATE TABLE raw.products (
    product_id NVARCHAR(50) NOT NULL,
    product_category_name NVARCHAR(100) NULL,
    product_name_lenght NVARCHAR(20) NULL,
    product_description_lenght NVARCHAR(20) NULL,
    product_photos_qty NVARCHAR(20) NULL,
    product_weight_g NVARCHAR(20) NULL,
    product_length_cm NVARCHAR(20) NULL,
    product_height_cm NVARCHAR(20) NULL,
    product_width_cm NVARCHAR(20) NULL
);
GO

CREATE TABLE raw.payments (
    order_id NVARCHAR(50) NOT NULL,
    payment_sequential NVARCHAR(20) NOT NULL,
    payment_type NVARCHAR(40) NULL,
    payment_installments NVARCHAR(20) NULL,
    payment_value NVARCHAR(40) NULL
);
GO

CREATE TABLE raw.reviews (
    review_id NVARCHAR(50) NOT NULL,
    order_id NVARCHAR(50) NOT NULL,
    review_score NVARCHAR(20) NULL,
    review_creation_date NVARCHAR(40) NULL,
    review_answer_timestamp NVARCHAR(40) NULL
);
GO

CREATE TABLE raw.geolocation (
    geolocation_zip_code_prefix NVARCHAR(20) NULL,
    geolocation_lat NVARCHAR(40) NULL,
    geolocation_lng NVARCHAR(40) NULL,
    geolocation_city NVARCHAR(100) NULL,
    geolocation_state NVARCHAR(10) NULL
);
GO

CREATE TABLE raw.product_category_translation (
    product_category_name NVARCHAR(100) NOT NULL,
    product_category_name_english NVARCHAR(100) NULL
);
GO

