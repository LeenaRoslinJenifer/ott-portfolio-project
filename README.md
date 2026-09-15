# OTT Portfolio Project — Clean Bundle (v2, final)

This is a single clean replacement for the whole `data/` folder. Delete your old
extracted folder entirely and use this one instead — no leftover/duplicate files.

## What's inside
- `schema/schema_v2_revised.sql` — the 13-table schema. Run this after creating your database.
- `data/` — 13 CSVs, one per table, ready to import. Booleans are already `1`/`0`
  integers (not `True`/`False` text), so the import-wizard bug from before won't happen again.

## Load order (respects foreign keys)
users → content → plans → experiments → sessions → subscriptions → events →
viewing_activity → payment_transactions → marketing_spend →
experiment_assignments → experiment_exposures → cancellation_feedback

## Expected row counts (verify after import)
| table | rows |
|---|---|
| users | 1800 |
| content | 500 |
| plans | 4 |
| experiments | 3 |
| sessions | 36328 |
| subscriptions | 280 |
| events | 122254 |
| viewing_activity | 15232 |
| payment_transactions | 936 |
| marketing_spend | 3386 |
| experiment_assignments | 2785 |
| experiment_exposures | 2785 |
| cancellation_feedback | 64 |

## Two headline checks (already verified in this bundle before sending)
1. No future-dated events: `SELECT COUNT(*) FROM events WHERE event_timestamp > '2026-09-08 00:00:00';` → 0
2. No experiment leakage (assignment must happen before exposure) — 0 rows.

Blank optional fields (nullable FKs, cancellation timestamps, failure reasons) are
stored as empty strings in the CSV — run the blank-to-NULL UPDATE statements after
import if you need `IS NULL` checks to work correctly.
