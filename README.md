OTT Subscriber Funnel & Retention Analysis

End-to-end SQL analysis on a synthetic OTT/streaming subscriber dataset — built to demonstrate the funnel, cohort-retention, A/B-test, and payment-recovery analysis skills a Product Analyst role requires, plus the data-quality judgment to catch bad numbers before reporting them.

Background

Modeled on OTT/streaming subscriber behavior (informed by FanCode/JioHotStar domain experience), this project simulates 1,800 users across an 18-month window, loaded into a 13-table MySQL schema and analyzed with SQL.

What this project covers
Phase	What it answers
Schema design	13-table relational model — users, sessions, events, subscriptions, payments, experiments
Load & verify	Full data load with integrity checks (row counts, no future-dated events, no experiment leakage)
Funnel analysis	Where do users drop off between signup, trial, and paid conversion?
Cohort / retention	Do newer signup cohorts retain better or worse than older ones?
A/B testing	Was the trial_length_test experiment worth shipping?
Payment recovery	Which failed-payment reasons recover best after retry, and where should a "Smart Retry" feature focus?
Key findings
Funnel: 85.7% of signups start a trial; of those, conversion to paid looked unrealistically high (99.6%) — flagged as a synthetic-data limitation, not a real insight.
Retention: Caught a right-censoring bias — recent cohorts falsely showed 100% retention because their observation window hadn't fully elapsed. Fixed by only comparing fully-observed cohorts.
A/B test: Found and excluded ~100 users with variant cross-contamination (assigned to both control and treatment) before trusting the result. Final read: Control 80.2% vs Treatment 81.4% — not a meaningful difference; recommend not shipping the change.
Payment recovery: Caught a join fan-out bug that produced impossible recovery rates over 100%, fixed with an EXISTS subquery. Final read: card_declined has the weakest recovery rate (67.9%) — the segment most worth a Smart Retry feature.
Tech stack

MySQL · LOAD DATA INFILE · CTEs · window functions · correlated subqueries (EXISTS) · GROUP BY / HAVING · conditional aggregation

Repo structure
schema/schema_v2_revised.sql   -- table definitions
data/                          -- 13 CSVs, one per table
00_schema.sql                  -- creates all tables
01_load_data.sql               -- loads all CSVs (LOAD DATA LOCAL INFILE)
02_funnel_analysis.sql         -- Phase 5a
03_cohort_retention.sql        -- Phase 5b
04_ab_test.sql                 -- Phase 5c
05_payment_recovery.sql        -- Phase 5d
analysis_log.md                -- full write-up of every finding and data-quality issue caught
How to run
Create the database and run 00_schema.sql
Update the file paths in 01_load_data.sql to your local data/ folder, then run it
Run 02 through 05 in order

See analysis_log.md for the full narrative — problem, approach, and reasoning behind every fix.
