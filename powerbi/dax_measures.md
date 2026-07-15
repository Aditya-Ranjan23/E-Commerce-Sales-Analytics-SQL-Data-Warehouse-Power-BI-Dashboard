# Power BI DAX Measures

These measures assume Power BI imports the `dw` star-schema tables.

## Base Measures

```DAX
Total Revenue =
CALCULATE (
    SUM ( fact_order_items[revenue] ),
    fact_orders[order_status] <> "canceled",
    fact_orders[order_status] <> "unavailable"
)
```

```DAX
Total Freight =
CALCULATE (
    SUM ( fact_order_items[freight_value] ),
    fact_orders[order_status] <> "canceled",
    fact_orders[order_status] <> "unavailable"
)
```

```DAX
Orders =
CALCULATE (
    DISTINCTCOUNT ( fact_orders[order_id] ),
    fact_orders[order_status] <> "canceled",
    fact_orders[order_status] <> "unavailable"
)
```

```DAX
Customers =
CALCULATE (
    DISTINCTCOUNT ( dim_customers[customer_unique_id] ),
    fact_orders[order_status] <> "canceled",
    fact_orders[order_status] <> "unavailable"
)
```

```DAX
Average Order Revenue =
DIVIDE ( [Total Revenue], [Orders] )
```

```DAX
Freight % of Revenue =
DIVIDE ( [Total Freight], [Total Revenue] )
```

## Growth Measures

```DAX
Revenue Previous Month =
CALCULATE (
    [Total Revenue],
    DATEADD ( dim_date[full_date], -1, MONTH )
)
```

```DAX
Revenue Growth =
[Total Revenue] - [Revenue Previous Month]
```

```DAX
Revenue Growth % =
DIVIDE ( [Revenue Growth], [Revenue Previous Month] )
```

```DAX
Orders Previous Month =
CALCULATE (
    [Orders],
    DATEADD ( dim_date[full_date], -1, MONTH )
)
```

```DAX
Order Growth % =
DIVIDE ( [Orders] - [Orders Previous Month], [Orders Previous Month] )
```

## Customer Measures

```DAX
Customer Order Count =
CALCULATE (
    DISTINCTCOUNT ( fact_orders[order_id] ),
    ALLEXCEPT ( dim_customers, dim_customers[customer_unique_id] ),
    fact_orders[order_status] <> "canceled",
    fact_orders[order_status] <> "unavailable"
)
```

```DAX
Repeat Customers =
COUNTROWS (
    FILTER (
        VALUES ( dim_customers[customer_unique_id] ),
        CALCULATE (
            DISTINCTCOUNT ( fact_orders[order_id] ),
            fact_orders[order_status] <> "canceled",
            fact_orders[order_status] <> "unavailable"
        ) > 1
    )
)
```

```DAX
Repeat Purchase Rate =
DIVIDE ( [Repeat Customers], [Customers] )
```

```DAX
One-Time Customers =
[Customers] - [Repeat Customers]
```

## Product Measures

```DAX
Units Sold =
CALCULATE (
    COUNTROWS ( fact_order_items ),
    fact_orders[order_status] <> "canceled",
    fact_orders[order_status] <> "unavailable"
)
```

```DAX
Revenue Rank =
RANKX (
    ALLSELECTED ( dim_products[product_category_name_english] ),
    [Total Revenue],
    ,
    DESC,
    DENSE
)
```

```DAX
Revenue per Unit =
DIVIDE ( [Total Revenue], [Units Sold] )
```

## Review And Delivery Measures

```DAX
Average Review Score =
AVERAGE ( fact_reviews[review_score] )
```

```DAX
Average Delivery Days =
AVERAGE ( fact_orders[delivery_days] )
```

```DAX
Late Orders =
CALCULATE (
    DISTINCTCOUNT ( fact_orders[order_id] ),
    fact_orders[days_late] > 0,
    fact_orders[order_status] <> "canceled",
    fact_orders[order_status] <> "unavailable"
)
```

```DAX
Late Delivery Rate =
DIVIDE ( [Late Orders], [Orders] )
```

```DAX
Average Days Late =
AVERAGE ( fact_orders[days_late] )
```

## Formatting Recommendations

- Currency: Total Revenue, Total Freight, Average Order Revenue, Revenue per Unit.
- Percent: Revenue Growth %, Repeat Purchase Rate, Freight % of Revenue, Late Delivery Rate.
- Whole number: Orders, Customers, Units Sold, Late Orders.
- Decimal: Average Review Score, Average Delivery Days, Average Days Late.

