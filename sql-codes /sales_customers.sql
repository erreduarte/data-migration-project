WITH ecommerce_customers AS (
  SELECT
    id                                                                                        AS id, 
    'ecommerce_store_name'                                                                    AS store,
    email                                                                                     AS email,
    get_json_object(addresses, '$[0].zip')                                                    AS zip_code,
    get_json_object(addresses, '$[0].address1')                                               AS street,
    get_json_object(addresses, '$[0].city')                                                   AS city,
    get_json_object(addresses, '$[0].country')                                                AS country
  FROM
    {{ref ('base_ecommerce_customers') }}
),

subscription_customers AS (
  SELECT
    a.code                                                                                    AS id, 
    'subscription_store_name'                                                                 AS store,
    a.email                                                                                   AS email,
    b.address:postal_code                                                                     AS zip_code,
    b.address:street1                                                                         AS street,
    b.address:city                                                                            AS city,
    b.address:country                                                                         AS country
  FROM
    {{ref ('base_subscription_accounts') }} a
  JOIN
    {{ref ('base_subscription_invoices') }} b 
  ON a.code = b.account:code
  GROUP BY
    1, 3, 4, 5, 6, 7
),

sales_customers AS (
  SELECT
    id,
    store,
    email,
    zip_code,
    street,
    city,
    country
  FROM
    ecommerce_customers
  UNION ALL
  SELECT
    *
  FROM
    subscription_customers
)

SELECT
  *
FROM
  sales_customers
