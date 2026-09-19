-- 04_ab_test.sql
-- Phase 5c: A/B test decision-making -- trial_length_test (experiment_id = 2)
USE ott_portfolio_c1;

-- What experiments exist
SELECT * FROM experiments;

-- Step 1: Sample size balance check (control vs treatment)
SELECT variant, COUNT(*) AS users_assigned
FROM experiment_assignments
WHERE experiment_id = 2
GROUP BY variant;

-- Step 2: Data-quality check -- users assigned more than once
SELECT user_id, COUNT(*)
FROM experiment_assignments
WHERE experiment_id = 2
GROUP BY user_id
HAVING COUNT(*) > 1;

-- Step 3: Of those duplicates, who got DIFFERENT variants each time (contamination)?
SELECT user_id, COUNT(DISTINCT variant) AS variant_count
FROM experiment_assignments
WHERE experiment_id = 2
GROUP BY user_id
HAVING COUNT(DISTINCT variant) > 1;

-- Step 4: FINAL clean conversion rate per variant.
-- ~100 users got BOTH control and treatment (cross-contamination) -- excluded entirely,
-- since their outcome can't be attributed to either variant.
WITH clean_users AS (
    SELECT user_id
    FROM experiment_assignments
    WHERE experiment_id = 2
    GROUP BY user_id
    HAVING COUNT(DISTINCT variant) = 1
)
SELECT
    ea.variant,
    COUNT(DISTINCT ea.user_id) AS users_in_variant,
    COUNT(DISTINCT ev.user_id) AS converted,
    ROUND(COUNT(DISTINCT ev.user_id) * 100.0 / COUNT(DISTINCT ea.user_id), 1) AS conversion_pct
FROM experiment_assignments ea
JOIN clean_users cu ON ea.user_id = cu.user_id
LEFT JOIN events ev
    ON ea.user_id = ev.user_id
    AND ev.event_name = 'subscription_purchased'
    AND ev.event_timestamp >= ea.assignment_timestamp
WHERE ea.experiment_id = 2
GROUP BY ea.variant;

-- RESULT: Control 80.2% vs Treatment 81.4% -- only 1.2pp difference, too small to be
-- a meaningful effect at this sample size. Recommendation: do not ship based on this data.
