WITH ecommerce_orders AS (
    SELECT
        id,
        created_at,
        customer:default_address:customer_id                                                           AS customer_id,
        'store_name'                                                                                   AS store,
        source_name                                                                                    AS sales_channel,
        from_json(fulfillments, schema_of_json('["str"]'))[0]:shipment_status                          AS shipping_status,
        financial_status,
        COALESCE(fulfillment_status, 'unfulfilled')                                                    AS status,
        total_price::float                                                                             AS total_price,
        subtotal_price::float                                                                          AS subtotal_price,
        total_tax::float                                                                               AS taxes,
        total_discounts::float                                                                         AS discounts,
        total_shipping_price_set:presentment_money:amount::float                                       AS shipping_cost,
        currency
    FROM
        {{ref('base_e_commerce')}}
),

subscription_orders AS (
    SELECT
        uuid                                                                                           AS id,
        created_at,
        account_code                                                                                   AS customer_id,
        'other_ecommerce'                                                                              AS store,
        NULL                                                                                           AS sales_channel,
        NULL                                                                                           AS shipping_status,
        NULL                                                                                           AS financial_status,
        NULL                                                                                           AS status,
        paid_value                                                                                     AS total_price,
        subtotal                                                                                       AS subtotal_price,
        us_tax                                                                                         AS taxes,
        NULL                                                                                           AS discounts,
        NULL                                                                                           AS shipping,
        NULL                                                                                           AS currency
    FROM
        {{ref('base_other_ecommerce')}}
),


sales_orders AS (
    SELECT * FROM ecommerce_orders
    UNION
    SELECT * FROM subscription_orders
)


SELECT * FROM sales_orders;
