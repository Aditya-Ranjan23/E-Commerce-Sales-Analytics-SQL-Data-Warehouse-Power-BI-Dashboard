# ER Diagram

This model uses a star-schema warehouse layer for analytics and Power BI. The raw tables land CSV data first; the `dw` schema is the trusted reporting model.

```mermaid
erDiagram
    DIM_CUSTOMERS ||--o{ FACT_ORDERS : places
    DIM_DATE ||--o{ FACT_ORDERS : purchase_date
    DIM_DATE ||--o{ FACT_ORDERS : approved_date
    DIM_DATE ||--o{ FACT_ORDERS : delivered_date
    DIM_DATE ||--o{ FACT_ORDERS : estimated_date
    FACT_ORDERS ||--o{ FACT_ORDER_ITEMS : contains
    DIM_PRODUCTS ||--o{ FACT_ORDER_ITEMS : describes
    FACT_ORDERS ||--o{ FACT_PAYMENTS : paid_by
    FACT_ORDERS ||--o{ FACT_REVIEWS : reviewed_by
    DIM_DATE ||--o{ FACT_REVIEWS : review_created

    DIM_CUSTOMERS {
        int customer_key PK
        string customer_id
        string customer_unique_id
        string customer_zip_code_prefix
        string customer_city
        string customer_state
    }

    DIM_PRODUCTS {
        int product_key PK
        string product_id
        string product_category_name
        string product_category_name_english
        int product_name_length
        int product_description_length
        int product_photos_qty
        decimal product_weight_g
        decimal product_length_cm
        decimal product_height_cm
        decimal product_width_cm
    }

    DIM_DATE {
        int date_key PK
        date full_date
        int calendar_year
        int calendar_quarter
        int month_number
        string month_name
        string year_month
        int day_of_month
        int day_of_week
        string day_name
        int week_of_year
        bool is_weekend
    }

    FACT_ORDERS {
        int order_key PK
        string order_id
        int customer_key FK
        string order_status
        int purchase_date_key FK
        int approved_date_key FK
        int delivered_customer_date_key FK
        int estimated_delivery_date_key FK
        datetime order_purchase_timestamp
        datetime order_approved_at
        datetime order_delivered_customer_date
        datetime order_estimated_delivery_date
        int delivery_days
        int days_late
        bool is_delivered
        bool is_canceled
    }

    FACT_ORDER_ITEMS {
        bigint order_item_key PK
        int order_key FK
        int product_key FK
        string order_id
        int order_item_id
        string product_id
        string seller_id
        datetime shipping_limit_date
        decimal revenue
        decimal freight_value
    }

    FACT_PAYMENTS {
        bigint payment_key PK
        int order_key FK
        string order_id
        int payment_sequential
        string payment_type
        int payment_installments
        decimal payment_value
    }

    FACT_REVIEWS {
        bigint review_key PK
        int order_key FK
        string review_id
        string order_id
        int review_score
        string review_comment_title
        string review_comment_message
        int review_creation_date_key FK
        int review_answer_date_key FK
        datetime review_creation_date
        datetime review_answer_timestamp
    }
```

## Relationship Notes

- `customer_id` is order-level in Olist. Use `customer_unique_id` for repeat purchase and retention analysis.
- `order_id` connects orders, order items, payments, and reviews in the raw source.
- `fact_order_items` is the revenue grain because one order can contain multiple products.
- `fact_payments` can have multiple rows per order due to split payment sequences.
- `fact_reviews` can contain more than one review row for an order, so reporting views select review scores carefully to avoid double-counting revenue.
- Revenue excludes freight. Freight is kept as `freight_value`.

