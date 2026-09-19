-- 02_funnel_analysis.sql
-- Phase 5a: Signup -> Trial -> Paid funnel
USE ott_portfolio_c1;

-- Distinct event types available in the data
SELECT DISTINCT event_name FROM events;

-- Data-quality check: users with trial_started but no app_open (tracking gap)
SELECT COUNT(DISTINCT e1.user_id)
FROM events e1
WHERE e1.event_name = 'trial_started'
AND e1.user_id NOT IN (
    SELECT user_id FROM events WHERE event_name = 'app_open'
);

-- Data-quality check: users with subscription_purchased but no trial_started (direct purchase path)
SELECT COUNT(DISTINCT e1.user_id)
FROM events e1
WHERE e1.event_name = 'subscription_purchased'
AND e1.user_id NOT IN (
    SELECT user_id FROM events WHERE event_name = 'trial_started'
);

-- Final funnel: Signup -> Trial Started -> Subscribed, with conversion percentages
-- NOTE: app_open dropped as a strict funnel gate (251 users started trial with no app_open logged,
-- a tracking gap not a real blocker).
SELECT
    (SELECT COUNT(*) FROM users) AS signups,
    (SELECT COUNT(DISTINCT user_id) FROM events WHERE event_name = 'trial_started') AS trial_started,
    (SELECT COUNT(DISTINCT user_id) FROM events WHERE event_name = 'subscription_purchased') AS subscribed,
    ROUND((SELECT COUNT(DISTINCT user_id) FROM events WHERE event_name = 'trial_started') * 100.0
        / (SELECT COUNT(*) FROM users), 1) AS signup_to_trial_pct,
    ROUND((SELECT COUNT(DISTINCT user_id) FROM events WHERE event_name = 'subscription_purchased') * 100.0
        / (SELECT COUNT(DISTINCT user_id) FROM events WHERE event_name = 'trial_started'), 1) AS trial_to_paid_pct,
    ROUND((SELECT COUNT(DISTINCT user_id) FROM events WHERE event_name = 'subscription_purchased') * 100.0
        / (SELECT COUNT(*) FROM users), 1) AS overall_signup_to_paid_pct;

-- KNOWN LIMITATION: trial_to_paid_pct comes out to 99.6%, unrealistic vs industry benchmark
-- (typically 20-40%). Flagged as a synthetic-data generation artifact, not a genuine insight.
