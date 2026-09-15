-- 03_cohort_retention.sql
-- Phase 5b: Monthly signup cohorts + Month-1 retention
USE ott_portfolio_c1;

-- How many cohorts (signup months) exist
SELECT DATE_FORMAT(signup_timestamp, '%Y-%m') AS signup_month, COUNT(*) AS num_users
FROM users
GROUP BY signup_month
ORDER BY signup_month;

-- Month-1 retention per cohort, WITH the right-censoring fix.
-- Right-censoring fix: exclude cohorts whose 2-month window hasn't fully passed yet (cutoff 2026-09-08),
-- else recent signups look falsely retained since they haven't had time to churn.
SELECT
    DATE_FORMAT(u.signup_timestamp, '%Y-%m') AS cohort_month,
    COUNT(DISTINCT u.user_id) AS cohort_size,
    COUNT(DISTINCT CASE
        WHEN e.event_timestamp > u.signup_timestamp
        AND e.event_timestamp <= DATE_ADD(u.signup_timestamp, INTERVAL 2 MONTH)
        THEN e.user_id END) AS active_month1,
    ROUND(COUNT(DISTINCT CASE
        WHEN e.event_timestamp > u.signup_timestamp
        AND e.event_timestamp <= DATE_ADD(u.signup_timestamp, INTERVAL 2 MONTH)
        THEN e.user_id END) * 100.0 / COUNT(DISTINCT u.user_id), 1) AS retention_pct
FROM users u
LEFT JOIN events e ON u.user_id = e.user_id
WHERE DATE_ADD(u.signup_timestamp, INTERVAL 2 MONTH) <= '2026-09-08'
GROUP BY cohort_month
ORDER BY cohort_month;

-- KNOWN LIMITATION: even after the right-censoring fix, fully-observed cohorts from
-- Apr-Jun 2026 still show 100% retention -- a synthetic-data limitation (near-zero churn
-- baked into recent months), not a genuine finding.
