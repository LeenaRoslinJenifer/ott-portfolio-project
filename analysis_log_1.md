# OTT Portfolio Project — Analysis Log
Running documentation for portfolio + personal reference. Updated after each stage.

---

## Phase 4 — Load + Verify (MySQL `ott_portfolio_c1`)
**Status:** Done

- Loaded all 13 CSVs via `LOAD DATA LOCAL INFILE` (Workbench Import Wizard avoided — nullable DATETIME/INT columns had blank `''` values that fail in strict mode; used `SET col = NULLIF(@var, '')` instead).
- Row counts verified — all 13 tables match README expected counts exactly (0 rows lost/duplicated).
- Headline checks passed:
  - `0` future-dated events
  - `0` experiment leakage (assignment before exposure)
- Files: `00_schema.sql`, `01_load_data.sql`

---

## Phase 5a — Funnel Analysis (Signup → Trial → Paid)
**Status:** Done

**Query file:** `02_funnel_analysis.sql`

| Stage | Count | Conversion |
|---|---|---|
| Signup | 1,800 | — |
| Trial Started | 1,543 | 85.7% of signups |
| Subscribed (Paid) | 1,537 | 99.6% of trials |

**Data-quality findings during this stage:**
- 251 users had `trial_started` with **no** `app_open` event — real tracking gap (e.g. deep-link/push-notification flows skip the app_open event). Dropped `app_open` as a strict funnel gate as a result.
- 206 users (11%) subscribed with **no** trial — legitimate direct-purchase path, not a data error.
- **Known limitation:** 99.6% trial-to-paid conversion is unrealistic vs. industry benchmark (typically 20–40%). Flagged as a synthetic-data generation artifact, not a genuine product insight — called out rather than presented as a real finding.

---

## Phase 5b — Cohort / Retention Analysis
**Status:** Done

**Query file:** `03_cohort_retention.sql`

- Grouped users into 19 monthly signup cohorts (Mar 2025 – Sep 2026).
- Measured Month-1 retention (any event within 2 months of signup).
- **Pitfall caught and fixed:** initial version showed retention climbing to a flat 100% for all 2026-04+ cohorts. Root cause: **right-censoring** — cohorts whose 2-month observation window hadn't fully elapsed by the data cutoff (2026-09-08) looked falsely "fully retained." Fixed by filtering to only cohorts with a fully observed window:
  ```sql
  WHERE DATE_ADD(u.signup_timestamp, INTERVAL 2 MONTH) <= '2026-09-08'
  ```
- **Known limitation:** even after the right-censoring fix, fully-observed cohorts from Apr–Jun 2026 still show 100% retention — a second synthetic-data limitation (near-zero churn baked into recent months), not a genuine finding.

**Interview-ready takeaway from this stage:** demonstrated ability to catch two distinct data-quality issues (unrealistic conversion rate, right-censoring bias) rather than presenting raw numbers at face value.

---

## Phase 5c — A/B Test Decision-Making
**Status:** In progress

*(to be filled in as we work through it)*
