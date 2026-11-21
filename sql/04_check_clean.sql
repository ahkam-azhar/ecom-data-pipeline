\echo '--- Row counts (expect: customers 99441, orders 99441, items 112650, payments 103886, products 32951, sellers 3095, geolocation 19015) ---'
SELECT 'customers' AS tbl, COUNT(*) FROM clean.customers
UNION ALL SELECT 'orders', COUNT(*) FROM clean.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM clean.order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM clean.order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM clean.order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM clean.products
UNION ALL SELECT 'sellers', COUNT(*) FROM clean.sellers
UNION ALL SELECT 'geolocation', COUNT(*) FROM clean.geolocation;

\echo '--- Reviews: clean rows should equal distinct order_ids in raw ---'
SELECT (SELECT COUNT(*) FROM clean.order_reviews) AS clean_reviews,
       (SELECT COUNT(DISTINCT order_id) FROM raw.order_reviews) AS raw_distinct_orders;

\echo '--- Flags (expect 8 and 166) ---'
SELECT COUNT(*) FILTER (WHERE missing_delivery_date) AS missing_delivery_date,
       COUNT(*) FILTER (WHERE carrier_before_purchase) AS carrier_before_purchase
FROM clean.orders;

\echo '--- Products with unknown category (expect about 610) ---'
SELECT COUNT(*) FROM clean.products WHERE category = 'unknown';