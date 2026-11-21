CREATE SCHEMA IF NOT EXISTS clean;

DROP TABLE IF EXISTS clean.order_reviews;
DROP TABLE IF EXISTS clean.order_payments;
DROP TABLE IF EXISTS clean.order_items;
DROP TABLE IF EXISTS clean.orders;
DROP TABLE IF EXISTS clean.customers;
DROP TABLE IF EXISTS clean.products;
DROP TABLE IF EXISTS clean.sellers;
DROP TABLE IF EXISTS clean.geolocation;

-- customers (zip codes stay text because leading zeros matter)
CREATE TABLE clean.customers AS
SELECT customer_id,
       customer_unique_id,
       customer_zip_code_prefix AS zip_code_prefix,
       customer_city AS city,
       UPPER(customer_state) AS state
FROM raw.customers;
ALTER TABLE clean.customers ADD PRIMARY KEY (customer_id);
CREATE INDEX ON clean.customers (customer_unique_id);

-- orders (D004, D006, D011)
CREATE TABLE clean.orders AS
SELECT order_id,
       customer_id,
       order_status,
       order_purchase_timestamp::timestamp AS purchased_at,
       order_approved_at::timestamp AS approved_at,
       order_delivered_carrier_date::timestamp AS carrier_at,
       order_delivered_customer_date::timestamp AS delivered_at,
       order_estimated_delivery_date::timestamp AS estimated_delivery_at,
       (order_status = 'delivered') AS is_delivered,
       (order_status = 'delivered' AND order_delivered_customer_date IS NULL) AS missing_delivery_date,
       COALESCE(order_delivered_carrier_date::timestamp < order_purchase_timestamp::timestamp, FALSE) AS carrier_before_purchase
FROM raw.orders;
ALTER TABLE clean.orders ADD PRIMARY KEY (order_id);
CREATE INDEX ON clean.orders (customer_id);

-- order items
CREATE TABLE clean.order_items AS
SELECT order_id,
       order_item_id::int AS order_item_id,
       product_id,
       seller_id,
       shipping_limit_date::timestamp AS shipping_limit_at,
       price::numeric(10,2) AS price,
       freight_value::numeric(10,2) AS freight_value
FROM raw.order_items;
ALTER TABLE clean.order_items ADD PRIMARY KEY (order_id, order_item_id);
CREATE INDEX ON clean.order_items (product_id);
CREATE INDEX ON clean.order_items (seller_id);

-- payments (several rows per order are normal)
CREATE TABLE clean.order_payments AS
SELECT order_id,
       payment_sequential::int AS payment_sequential,
       payment_type,
       payment_installments::int AS payment_installments,
       payment_value::numeric(12,2) AS payment_value
FROM raw.order_payments;
ALTER TABLE clean.order_payments ADD PRIMARY KEY (order_id, payment_sequential);

-- reviews: keep the latest review per order (D005)
CREATE TABLE clean.order_reviews AS
SELECT DISTINCT ON (order_id)
       review_id,
       order_id,
       review_score::int AS review_score,
       review_comment_title,
       review_comment_message,
       review_creation_date::timestamp AS review_created_at,
       review_answer_timestamp::timestamp AS review_answered_at
FROM raw.order_reviews
ORDER BY order_id, review_answer_timestamp::timestamp DESC, review_id;
ALTER TABLE clean.order_reviews ADD PRIMARY KEY (order_id);

-- products with English categories (D007)
CREATE TABLE clean.products AS
SELECT p.product_id,
       COALESCE(p.product_category_name, 'unknown') AS category_pt,
       COALESCE(
           t.product_category_name_english,
           CASE p.product_category_name
               WHEN 'pc_gamer' THEN 'pc_gamer'
               WHEN 'portateis_cozinha_e_preparadores_de_alimentos'
                   THEN 'portable_kitchen_and_food_preparers'
               ELSE 'unknown'
           END
       ) AS category,
       p.product_photos_qty::int AS photos_qty,
       p.product_weight_g::numeric AS weight_g,
       p.product_length_cm::numeric AS length_cm,
       p.product_height_cm::numeric AS height_cm,
       p.product_width_cm::numeric AS width_cm
FROM raw.products p
LEFT JOIN raw.product_category_name_translation t
       ON p.product_category_name = t.product_category_name;
ALTER TABLE clean.products ADD PRIMARY KEY (product_id);

-- sellers
CREATE TABLE clean.sellers AS
SELECT seller_id,
       seller_zip_code_prefix AS zip_code_prefix,
       seller_city AS city,
       UPPER(seller_state) AS state
FROM raw.sellers;
ALTER TABLE clean.sellers ADD PRIMARY KEY (seller_id);

-- geolocation: one row per zip prefix (D010)
CREATE TABLE clean.geolocation AS
SELECT geolocation_zip_code_prefix AS zip_code_prefix,
       AVG(geolocation_lat::numeric) AS lat,
       AVG(geolocation_lng::numeric) AS lng
FROM raw.geolocation
GROUP BY 1;
ALTER TABLE clean.geolocation ADD PRIMARY KEY (zip_code_prefix);