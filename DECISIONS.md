# Decisions Log

## D001: Use the Olist Brazilian e-commerce dataset
**Date:** 2026-11-03
**Context:** Needed a realistic e-commerce dataset for the pipeline.
**Options considered:**
1. Olist (multi-table, about 100k orders)
2. A single flat CSV from Kaggle
3. Scraped store data
**Decision:** Olist.
**Why:** Multiple related tables make SQL and pipeline design meaningful, and the data is real and anonymized.
**Consequences:** Dataset is non-commercial licensed, so the final product must not depend on it.

## D002: Load raw data as text, untouched
**Date:** 2026-11-03
**Context:** Needed to decide how raw CSVs enter the database.
**Options considered:**
1. Let pandas guess the column types
2. Load everything as text
**Decision:** Load everything as text into a `raw` schema.
**Why:** Keeps an exact copy of the source, so any cleaning mistakes can be undone and re-run.
**Consequences:** Types, dates, and numbers must be converted in the clean layer.

## D003: Run Postgres in Docker
**Date:** 2026-11-03
**Context:** Needed a database for the project.
**Options considered:**
1. Install Postgres directly on Windows
2. Run it in Docker
**Decision:** Docker with docker-compose.
**Why:** One command to start or reset it, and the setup is reproducible on any machine.
**Consequences:** Requires Docker Desktop to be running before the pipeline works.

## D004: Keep non-delivered orders in the clean layer, but flag them
**Date:** 2026-11-04
**Context:** 2,963 of 99,441 orders are not delivered (shipped, canceled, unavailable, invoiced, processing, created, approved).
**Options considered:**
1. Delete all non-delivered orders
2. Keep them and add an `is_delivered` flag
**Decision:** Keep them and add a flag.
**Why:** Deleting loses information (for example, cancellation rates). Delivery-time and review analyses can filter on the flag instead.
**Consequences:** Every delivery-based query must filter on `is_delivered`.

## D005: Keep one review per order (the most recently answered)
**Date:** 2026-11-04
**Context:** 547 orders have more than one review, which would duplicate orders in any join.
**Options considered:**
1. Keep the first review
2. Keep the most recent review
3. Average the scores
**Decision:** Keep the most recent review per order.
**Why:** The latest review reflects the customer's final opinion, and keeping a single row preserves one row per order.
**Consequences:** Some earlier review text is discarded in the clean layer, though it stays in `raw`.

## D006: Treat 8 delivered orders with no delivery date as data errors
**Date:** 2026-11-04
**Context:** Eight orders are marked delivered but have no delivery timestamp.
**Options considered:**
1. Delete them
2. Keep them and exclude them from delivery-time metrics only
**Decision:** Keep them, set delivery time to NULL, and exclude them from delivery-time calculations.
**Why:** Revenue and order counts are still valid for these orders. Only the delivery-time metric is unreliable.
**Consequences:** Delivery-time averages are computed on slightly fewer orders.

## D007: Fill missing product categories and translations explicitly
**Date:** 2026-11-04
**Context:** 610 products have no category, and 2 categories lack an English translation.
**Options considered:**
1. Drop those products
2. Label missing categories "unknown" and add the two missing translations manually
**Decision:** Label as "unknown" and add the two translations in the clean layer.
**Why:** Dropping products would remove their sales from revenue analysis.
**Consequences:** The "unknown" category should be mentioned in dashboard notes.

## D008: Restrict trend analysis to Jan 2017 through Aug 2018
**Date:** 2026-11-04
**Context:** Orders per month are tiny before 2017-01 and after 2018-08 (single or double digits, with a missing month in 2016).
**Options considered:**
1. Delete the sparse months
2. Keep every row, but limit trend metrics to the 20 reliable months
**Decision:** Keep every row in the clean layer, and use only 2017-01 to 2018-08 for trends and dashboard charts.
**Why:** Deleting loses data, while the sparse months would distort growth rates.
**Consequences:** Dashboards and trend queries need a date filter, which I will define once in a view.

## D009: Use customer_unique_id to identify people
**Date:** 2026-11-04
**Context:** There are 99,441 customer_id values but only 96,096 customer_unique_id values. customer_id changes per order.
**Decision:** Use customer_unique_id for anything about people (repeat purchases, retention). Keep customer_id only as the join key to orders.
**Why:** Counting customer_id would treat repeat buyers as new customers.
**Consequences:** Repeat-purchase and cohort queries must group by customer_unique_id.

## D010: Collapse geolocation to one row per zip prefix
**Date:** 2026-11-04
**Context:** 1,000,163 rows describe only 19,015 zip prefixes.
**Options considered:**
1. Keep all rows
2. Keep one row per prefix using average latitude and longitude
**Decision:** One row per prefix with averaged coordinates.
**Why:** Joining the raw table would multiply rows and inflate order counts.
**Consequences:** Coordinates are approximate (zip-prefix level), which is fine for regional analysis.

## D011: Flag impossible timestamps instead of deleting rows
**Date:** 2026-11-04
**Context:** 166 orders show a carrier hand-off before the purchase time.
**Decision:** Keep the rows and add a boolean flag `carrier_before_purchase`.
**Why:** The orders, items, and revenue are still valid, and only the timestamp is wrong.
**Consequences:** Logistics metrics that use the carrier date should exclude flagged rows.