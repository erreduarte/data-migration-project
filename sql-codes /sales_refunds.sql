WITH ecommerce_exploded AS (
    SELECT
        order_id,
        explode(from_json(refund_line_items, schema_of_json('["str"]')))                     AS exploded_value,
        exploded_value:line_item:sku                                                         AS SKU,
        created_at,
        exploded_value:quantity::int                                                         AS quantity
    FROM {{ref('base_ecommerce_refunds')}}
),

ecommerce_refunds AS (
    SELECT
        order_id,
        SKU,
        created_at,
        SUM(quantity)                                                                         AS quantity
    FROM ecommerce_exploded
    GROUP BY order_id, SKU, created_at
),

subscription_refunds AS (
    SELECT
        id                                                                                     AS order_id,
        created_at,
        description,
        SUBSTRING(description, CHARINDEX('#', description) + 1, LEN(description))              AS original_invoice_number,
        ABS(quantity)                                                                          AS quantity
    FROM {{ref('base_subscription_adjustments')}}
),

recurly_returns AS (
    SELECT
        a.order_id                                                                              AS order_id,
        b.line_items:data[0]:product_code                                                       AS SKU,
        a.created_at                                                                            AS created_at,
        a.quantity                                                                              AS quantity
    FROM subscription_refunds a
    JOIN {{ref('base_subscription_invoices')}} b ON b.line_items:data[0]:invoice_number = a.original_invoice_number
),

sales_refunds AS (
    SELECT
        *
    FROM ecommerce_refunds
    UNION ALL
    SELECT
        order_id, SKU, created_at, quantity
    FROM subscription_refunds
)

SELECT
    *
FROM sales_refunds;

