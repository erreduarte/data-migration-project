WITH ecommerce_line_items AS (
  SELECT
    id                                                                                                                 AS order_id,
    note_attributes,
    explode(from_json(line_items, schema_of_json('["str"]')))                                                          AS exploded_line_item,
    exploded_line_item:sku                                                                                             AS SKU,
    exploded_line_item:id                                                                                              AS line_item_id
  FROM {{ref('base_ecommerce_orders')}}
),

serial_exploded AS (
  SELECT
    order_id,
    line_item_id,
    sku,
    explode(from_json(note_attributes, schema_of_json('["str"]')))                                                      AS exploded_note
  FROM ecommerce_line_items
),

serial_filtered AS (
  SELECT
    order_id,
    line_item_id,
    exploded_note:value                                                                                                 AS serial_number,
    IF(split(exploded_note:name, ':')[0] RLIKE '\\d{13,}', sku, 'unknown')                                              AS updated_sku,
    IF(split(exploded_note:name, ':')[0] RLIKE '\\d{13,}', split(exploded_note:name, ':')[0], line_item_id)             AS note_line_item_id
  FROM serial_exploded
  WHERE exploded_note:name LIKE ANY ('%serial%', '%camera_sn%')
),

table_merged AS (
  SELECT
    order_id,
    COALESCE(updated_sku)                                                                                               AS sku,
    serial_number
  FROM serial_filtered a
  WHERE line_item_id = note_line_item_id
),

sales_packages AS (
  SELECT
    a.order_id                                                                                                           AS order_id,
    a.sku                                                                                                                AS SKU,
    COALESCE(b.camera_serial, a.serial_number)
  FROM
    table_merged a
  LEFT JOIN
    {{ref ('pkg_mapping') }} b on a.serial_number = b.sleeve_serial
  GROUP BY ALL
)

  SELECT * FROM sales_packages
