/*
Project: E-Commerce Analytics
Purpose: Load Olist CSV files into raw tables.

Instructions:
1. Download the Olist dataset from Kaggle:
   https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
2. Extract all CSV files to one folder, for example:
   C:\data\olist
3. In SQL Server Management Studio, enable SQLCMD Mode.
4. Change DataPath below if your folder is different.
5. Run this script after 01_create_raw_tables.sql.
*/

:setvar DataPath "D:\.Study\Projects\E-commerece Analytics\data\olist"

USE ECommerceAnalytics;
GO

TRUNCATE TABLE raw.customers;
TRUNCATE TABLE raw.orders;
TRUNCATE TABLE raw.order_items;
TRUNCATE TABLE raw.products;
TRUNCATE TABLE raw.payments;
TRUNCATE TABLE raw.reviews;
TRUNCATE TABLE raw.geolocation;
TRUNCATE TABLE raw.product_category_translation;
GO

BULK INSERT raw.customers
FROM '$(DataPath)\olist_customers_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

BULK INSERT raw.orders
FROM '$(DataPath)\olist_orders_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

BULK INSERT raw.order_items
FROM '$(DataPath)\olist_order_items_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

BULK INSERT raw.products
FROM '$(DataPath)\olist_products_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

BULK INSERT raw.payments
FROM '$(DataPath)\olist_order_payments_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

TRUNCATE TABLE raw.reviews;
GO

BULK INSERT raw.reviews
FROM '$(DataPath)\olist_order_reviews_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
GO

BULK INSERT raw.geolocation
FROM '$(DataPath)\olist_geolocation_dataset.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

BULK INSERT raw.product_category_translation
FROM '$(DataPath)\product_category_name_translation.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM raw.customers
UNION ALL SELECT 'orders', COUNT(*) FROM raw.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM raw.order_items
UNION ALL SELECT 'products', COUNT(*) FROM raw.products
UNION ALL SELECT 'payments', COUNT(*) FROM raw.payments
UNION ALL SELECT 'reviews', COUNT(*) FROM raw.reviews
UNION ALL SELECT 'geolocation', COUNT(*) FROM raw.geolocation
UNION ALL SELECT 'product_category_translation', COUNT(*) FROM raw.product_category_translation;
GO
