WITH ecommerce_invoices AS (
  SELECT
    a.receipt:id                                                       AS invoice_id,
    a.order_id                                                         AS order_id,
    a.created_at                                                       AS created_at,
    a.status                                                           AS status,
    CASE
      WHEN kind = 'refund' THEN amount * -1::float
      ELSE amount::float
    END                                                               AS total_price,
    CASE
      WHEN kind = 'refund' THEN b.subtotal_price * -1::float
      ELSE b.subtotal_price::float
    END                                                               AS subtotal_price,
    CASE
      WHEN kind = 'refund' THEN b.total_tax * -1::float
      ELSE b.total_tax::float
    END                                                               AS taxes
  FROM
    {{ref('base_ecommerce_transactions')}} a
  JOIN
    {{ref('base_ecommerce_orders')}} b 
    ON a.order_id = b.id
),

subscription_invoices AS (
  SELECT
    ID                                                                AS invoice_id,
    NULL                                                              AS order_id,
    created_at,
    state                                                             AS status,
    total::float                                                      AS total_price,
    subtotal::float                                                   AS subtotal_price,
    tax::float                                                        AS taxes,
    NULL                                                              AS shipping_cost
  FROM
    {{ref('base_subscription_invoices')}}
),

sales_invoices AS (
  SELECT * FROM ecommerce_invoices
  UNION ALL
  SELECT * FROM subscription_invoices
)

SELECT * FROM sales_invoices;

