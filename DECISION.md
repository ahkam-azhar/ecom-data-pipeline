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