\echo '--- 1. Orders per month ---'
SELECT to_char(order_purchase_timestamp::timestamp, 'YYYY-MM') AS month,
       COUNT(*) AS orders
FROM raw.orders
GROUP BY 1
ORDER BY 1;

\echo '--- 2. Orders without items, by status ---'
SELECT o.order_status, COUNT(*) AS orders
FROM raw.orders o
LEFT JOIN raw.order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL
GROUP BY 1
ORDER BY 2 DESC;

\echo '--- 3. Non-delivered orders that HAVE a delivery date ---'
SELECT order_status, COUNT(*) AS orders
FROM raw.orders
WHERE order_status <> 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY 1;

\echo '--- 4. Shipped to carrier BEFORE purchase (impossible) ---'
SELECT COUNT(*) AS impossible_orders
FROM raw.orders
WHERE order_delivered_carrier_date::timestamp < order_purchase_timestamp::timestamp;

\echo '--- 5. Customer rows vs real people ---'
SELECT COUNT(*) AS customer_rows,
       COUNT(DISTINCT customer_unique_id) AS real_people
FROM raw.customers;

\echo '--- 6. Review score spread ---'
SELECT review_score, COUNT(*) AS reviews
FROM raw.order_reviews
GROUP BY 1
ORDER BY 1;

\echo '--- 7. Payment types and values ---'
SELECT payment_type,
       COUNT(*) AS payments,
       MIN(payment_value::numeric) AS smallest,
       MAX(payment_value::numeric) AS largest
FROM raw.order_payments
GROUP BY 1
ORDER BY 2 DESC;

\echo '--- 8. Geolocation: rows vs distinct zip prefixes ---'
SELECT COUNT(*) AS rows,
       COUNT(DISTINCT geolocation_zip_code_prefix) AS distinct_zip_prefixes
FROM raw.geolocation;

\echo '--- 9. The 5 most expensive items ---'
SELECT order_id, product_id, price, freight_value
FROM raw.order_items
ORDER BY price::numeric DESC
LIMIT 5;