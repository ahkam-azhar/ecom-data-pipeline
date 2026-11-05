\echo '--- 1. Date range of orders ---'
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM raw.orders;

\echo '--- 2. Orders by status ---'
SELECT order_status, COUNT(*) AS orders
FROM raw.orders
GROUP BY order_status
ORDER BY orders DESC;

\echo '--- 3. Missing values in orders ---'
SELECT COUNT(*) AS total_orders,
       COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS no_approved_date,
       COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS no_carrier_date,
       COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS no_delivery_date
FROM raw.orders;

\echo '--- 4. Is order_id really unique? ---'
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM raw.orders;

\echo '--- 5. Delivered orders with no delivery date ---'
SELECT COUNT(*) AS suspicious_orders
FROM raw.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

\echo '--- 6. Delivered BEFORE purchased (impossible) ---'
SELECT COUNT(*) AS impossible_orders
FROM raw.orders
WHERE order_delivered_customer_date::timestamp < order_purchase_timestamp::timestamp;

\echo '--- 7. Orders that have more than one review ---'
SELECT COUNT(*) AS orders_with_multiple_reviews
FROM (
    SELECT order_id
    FROM raw.order_reviews
    GROUP BY order_id
    HAVING COUNT(*) > 1
) t;

\echo '--- 8. Orders with no items at all ---'
SELECT COUNT(*) AS orders_without_items
FROM raw.orders o
LEFT JOIN raw.order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL;

\echo '--- 9. Products with no category ---'
SELECT COUNT(*) FILTER (WHERE product_category_name IS NULL) AS no_category,
       COUNT(*) AS total_products
FROM raw.products;

\echo '--- 10. Categories with no English translation ---'
SELECT DISTINCT p.product_category_name
FROM raw.products p
LEFT JOIN raw.product_category_name_translation t
       ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
  AND p.product_category_name IS NOT NULL;

\echo '--- 11. Price range of items ---'
SELECT MIN(price::numeric) AS cheapest,
       MAX(price::numeric) AS most_expensive,
       ROUND(AVG(price::numeric), 2) AS average
FROM raw.order_items;