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

## Phase 5c — A/B Test Decision-Making (`trial_length_test`, experiment_id=2)
**Status:** Done

**Query file:** `04_ab_test.sql`

- Sample balance: Control 480 vs Treatment 477 assigned — healthy ~50/50 random split.
- **Data-quality issue found:** ~200 users had duplicate rows in `experiment_assignments`. Investigated further:
  - ~100 users were duplicated but with the **same** variant both times — harmless, deduped with `COUNT(DISTINCT variant) = 1`.
  - **~100 users received BOTH control and treatment** — a genuine "variant cross-contamination" bug. These users' outcomes can't be attributed to either variant, so they were **excluded entirely** from the final analysis using a CTE (`clean_users`).
- **Final (clean) conversion results:**

| Variant | Users | Converted | Conversion % |
|---|---|---|---|
| Control | 324 | 260 | 80.2% |
| Treatment | 307 | 250 | 81.4% |

- **Conclusion:** Only a 1.2 percentage point difference — too small to be a meaningful effect given the sample size. Recommendation: do not ship the trial-length change based on this data; the difference is likely random noise, not a real effect.

**Interview-ready takeaway:** identified and resolved a real A/B test data-integrity bug (variant cross-contamination) before drawing any conclusion — a step many candidates skip, and exactly the kind of rigor a Product Analyst is expected to show.

---

## Phase 5d — Payment Failure Recovery (BA add-on)
**Status:** Done

**Query file:** `05_payment_recovery.sql`

- 90 total failed payments, roughly evenly split across 3 reasons: `expired_card` (31), `insufficient_funds` (31), `card_declined` (28).
- **Query bug caught and fixed:** first version of the recovery-rate query used a plain `LEFT JOIN` to find a later successful payment per failed transaction — this fanned out (one failed transaction matched multiple later successful renewals), producing impossible recovery rates over 100% (151.6%, 196.8%). Fixed by switching to an `EXISTS` correlated subquery, which checks "was there any later success" per failed transaction instead of counting every match.
- **Final (correct) recovery rates:**

| Failure Reason | Failed | Recovered | Recovery % |
|---|---|---|---|
| insufficient_funds | 31 | 26 | 83.9% |
| expired_card | 31 | 24 | 77.4% |
| card_declined | 28 | 19 | 67.9% |

- **BA recommendation:** `card_declined` has the lowest recovery rate — this segment would benefit most from a "Smart Retry" feature (prompt to update payment method immediately, or an auto-retry with delay), a concrete data-backed product suggestion.

**Interview-ready takeaway:** caught a join fan-out bug producing impossible (>100%) percentages before reporting it — shows the habit of sanity-checking output, not just running queries and trusting the result.

---

## Phase 5 — Complete
All four sub-stages (funnel, cohort/retention, A/B test, payment recovery) are done. Next: package this log into a portfolio case-study write-up (problem → approach → findings → recommendations).
