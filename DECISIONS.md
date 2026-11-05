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