/*
Project: E-Commerce Analytics
Purpose: Stored procedures for reusable KPI refresh and business extracts.
*/

USE ECommerceAnalytics;
GO

IF OBJECT_ID('mart.monthly_kpis', 'U') IS NULL
BEGIN
    CREATE TABLE mart.monthly_kpis (
        month_start_date DATE NOT NULL PRIMARY KEY,
        year_month CHAR(7) NOT NULL,
        revenue DECIMAL(18,2) NOT NULL,
        freight_value DECIMAL(18,2) NOT NULL,
        orders INT NOT NULL,
        customers INT NOT NULL,
        repeat_customers INT NOT NULL,
        average_order_revenue DECIMAL(18,2) NULL,
        revenue_growth_pct DECIMAL(10,2) NULL,
        refreshed_at DATETIME2(0) NOT NULL
    );
END;
GO

CREATE OR ALTER PROCEDURE mart.usp_refresh_monthly_kpis
AS
BEGIN
    SET NOCOUNT ON;

    WITH order_revenue AS (
        SELECT
            fo.order_key,
            fo.order_id,
            dc.customer_unique_id,
            dd.year_month,
            DATEFROMPARTS(dd.calendar_year, dd.month_number, 1) AS month_start_date,
            SUM(foi.revenue) AS revenue,
            SUM(foi.freight_value) AS freight_value
        FROM dw.fact_orders AS fo
        INNER JOIN dw.fact_order_items AS foi
            ON fo.order_key = foi.order_key
        LEFT JOIN dw.dim_date AS dd
            ON fo.purchase_date_key = dd.date_key
        LEFT JOIN dw.dim_customers AS dc
            ON fo.customer_key = dc.customer_key
        WHERE fo.order_status NOT IN ('canceled', 'unavailable')
        GROUP BY
            fo.order_key,
            fo.order_id,
            dc.customer_unique_id,
            dd.year_month,
            DATEFROMPARTS(dd.calendar_year, dd.month_number, 1)
    ),
    customer_order_rank AS (
        SELECT
            customer_unique_id,
            order_id,
            month_start_date,
            ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY month_start_date, order_id) AS order_number
        FROM order_revenue
        WHERE customer_unique_id IS NOT NULL
    ),
    monthly AS (
        SELECT
            orev.month_start_date,
            orev.year_month,
            SUM(orev.revenue) AS revenue,
            SUM(orev.freight_value) AS freight_value,
            COUNT(DISTINCT orev.order_id) AS orders,
            COUNT(DISTINCT orev.customer_unique_id) AS customers,
            COUNT(DISTINCT CASE WHEN cor.order_number > 1 THEN orev.customer_unique_id END) AS repeat_customers,
            SUM(orev.revenue) / NULLIF(COUNT(DISTINCT orev.order_id), 0) AS average_order_revenue
        FROM order_revenue AS orev
        LEFT JOIN customer_order_rank AS cor
            ON orev.customer_unique_id = cor.customer_unique_id
           AND orev.order_id = cor.order_id
        GROUP BY
            orev.month_start_date,
            orev.year_month
    ),
    monthly_with_growth AS (
        SELECT
            month_start_date,
            year_month,
            revenue,
            freight_value,
            orders,
            customers,
            repeat_customers,
            average_order_revenue,
            CAST(
                100.0 * (revenue - LAG(revenue) OVER (ORDER BY month_start_date))
                / NULLIF(LAG(revenue) OVER (ORDER BY month_start_date), 0)
                AS DECIMAL(10,2)
            ) AS revenue_growth_pct
        FROM monthly
    )
    MERGE mart.monthly_kpis AS target
    USING monthly_with_growth AS source
        ON target.month_start_date = source.month_start_date
    WHEN MATCHED THEN
        UPDATE SET
            year_month = source.year_month,
            revenue = source.revenue,
            freight_value = source.freight_value,
            orders = source.orders,
            customers = source.customers,
            repeat_customers = source.repeat_customers,
            average_order_revenue = source.average_order_revenue,
            revenue_growth_pct = source.revenue_growth_pct,
            refreshed_at = SYSDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            month_start_date,
            year_month,
            revenue,
            freight_value,
            orders,
            customers,
            repeat_customers,
            average_order_revenue,
            revenue_growth_pct,
            refreshed_at
        )
        VALUES (
            source.month_start_date,
            source.year_month,
            source.revenue,
            source.freight_value,
            source.orders,
            source.customers,
            source.repeat_customers,
            source.average_order_revenue,
            source.revenue_growth_pct,
            SYSDATETIME()
        )
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;
END;
GO

CREATE OR ALTER PROCEDURE mart.usp_get_top_products
    @TopN INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
        product_id,
        product_category_name_english,
        revenue,
        units_sold,
        orders,
        average_review_score,
        revenue_rank
    FROM mart.vw_product_revenue_rank
    ORDER BY revenue_rank;
END;
GO

EXEC mart.usp_refresh_monthly_kpis;
GO

