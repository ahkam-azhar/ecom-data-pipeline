import pytest

# Each query counts BAD rows, so every one of them must return 0.
MUST_BE_ZERO = {
    "duplicate order ids":
        "SELECT COUNT(*) - COUNT(DISTINCT order_id) FROM clean.orders",
    "orders with a missing key or purchase date":
        "SELECT COUNT(*) FROM clean.orders "
        "WHERE order_id IS NULL OR customer_id IS NULL OR purchased_at IS NULL",
    "orders without a customer":
        "SELECT COUNT(*) FROM clean.orders o "
        "LEFT JOIN clean.customers c ON o.customer_id = c.customer_id "
        "WHERE c.customer_id IS NULL",
    "order items without an order":
        "SELECT COUNT(*) FROM clean.order_items i "
        "LEFT JOIN clean.orders o ON i.order_id = o.order_id "
        "WHERE o.order_id IS NULL",
    "order items without a product":
        "SELECT COUNT(*) FROM clean.order_items i "
        "LEFT JOIN clean.products p ON i.product_id = p.product_id "
        "WHERE p.product_id IS NULL",
    "order items without a seller":
        "SELECT COUNT(*) FROM clean.order_items i "
        "LEFT JOIN clean.sellers s ON i.seller_id = s.seller_id "
        "WHERE s.seller_id IS NULL",
    "reviews without an order":
        "SELECT COUNT(*) FROM clean.order_reviews r "
        "LEFT JOIN clean.orders o ON r.order_id = o.order_id "
        "WHERE o.order_id IS NULL",
    "orders with more than one review":
        "SELECT COUNT(*) FROM (SELECT order_id FROM clean.order_reviews "
        "GROUP BY order_id HAVING COUNT(*) > 1) t",
    "review scores outside 1 to 5":
        "SELECT COUNT(*) FROM clean.order_reviews WHERE review_score NOT BETWEEN 1 AND 5",
    "negative prices or freight":
        "SELECT COUNT(*) FROM clean.order_items WHERE price < 0 OR freight_value < 0",
    "negative payment values":
        "SELECT COUNT(*) FROM clean.order_payments WHERE payment_value < 0",
    "delivered before purchased":
        "SELECT COUNT(*) FROM clean.orders WHERE delivered_at < purchased_at",
    "delivered orders with no date that are not flagged":
        "SELECT COUNT(*) FROM clean.orders "
        "WHERE is_delivered AND delivered_at IS NULL AND NOT missing_delivery_date",
    "products with a null category":
        "SELECT COUNT(*) FROM clean.products WHERE category IS NULL",
    "duplicate zip prefixes in geolocation":
        "SELECT COUNT(*) - COUNT(DISTINCT zip_code_prefix) FROM clean.geolocation",
}


@pytest.mark.parametrize("name,sql", MUST_BE_ZERO.items(), ids=list(MUST_BE_ZERO))
def test_no_bad_rows(scalar, name, sql):
    assert scalar(sql) == 0, f"Found rows with problem: {name}"


# The clean layer should not lose rows, except reviews (we keep one per order).
SAME_ROW_COUNT = ["customers", "orders", "order_items", "order_payments", "products", "sellers"]


@pytest.mark.parametrize("table", SAME_ROW_COUNT)
def test_clean_keeps_all_rows(scalar, table):
    raw_count = scalar(f"SELECT COUNT(*) FROM raw.{table}")
    clean_count = scalar(f"SELECT COUNT(*) FROM clean.{table}")
    assert clean_count == raw_count, f"{table}: raw {raw_count} vs clean {clean_count}"


def test_one_review_per_order(scalar):
    raw_orders = scalar("SELECT COUNT(DISTINCT order_id) FROM raw.order_reviews")
    clean_reviews = scalar("SELECT COUNT(*) FROM clean.order_reviews")
    assert clean_reviews == raw_orders