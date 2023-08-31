WITH ecommerce_payments AS (
  SELECT
    id                                                  AS transaction_id,
    receipt:id                                          AS invoice_id
  FROM
    {{ref ('base_ecommerce_transactions') }}  
),

subscription_payments AS (
  SELECT
    get_json_object(transactions, '$[0].id')            AS transaction_id,
    id                                                  AS invoice_id
  FROM
    {{ref ('base_subscription_invoices') }}
  WHERE
    get_json_object(transactions, '$[0].id') is not null
),

sales_payment_invoices AS (
  SELECT * FROM ecommerce_payments
  UNION
  SELECT * FROM subscription_payments
  )

SELECT * FROM sales_payment_invoices
