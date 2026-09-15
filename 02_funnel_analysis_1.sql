use ott_portfolio_c1;

/* SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'content', COUNT(*) FROM content
UNION ALL SELECT 'plans', COUNT(*) FROM plans
UNION ALL SELECT 'experiments', COUNT(*) FROM experiments
UNION ALL SELECT 'sessions', COUNT(*) FROM sessions
UNION ALL SELECT 'subscriptions', COUNT(*) FROM subscriptions
UNION ALL SELECT 'events', COUNT(*) FROM events
UNION ALL SELECT 'viewing_activity', COUNT(*) FROM viewing_activity
UNION ALL SELECT 'payment_transactions', COUNT(*) FROM payment_transactions
UNION ALL SELECT 'marketing_spend', COUNT(*) FROM marketing_spend
UNION ALL SELECT 'experiment_assignments', COUNT(*) FROM experiment_assignments
UNION ALL SELECT 'experiment_exposures', COUNT(*) FROM experiment_exposures
UNION ALL SELECT 'cancellation_feedback', COUNT(*) FROM cancellation_feedback;

SELECT COUNT(*) FROM events WHERE event_timestamp > '2026-09-08 00:00:00';

SELECT COUNT(*) AS leakage_count
FROM experiment_exposures ee
JOIN experiment_assignments ea ON ee.assignment_id = ea.assignment_id
WHERE ee.exposure_timestamp < ea.assignment_timestamp;

SELECT DISTINCT event_name FROM events; */
-- SELECT COUNT(*) FROM users;
-- SELECT * FROM events;
-- SELECT DISTINCT event_name FROM events;

-- query check ---
select count( distinct e1.user_id)
from events e1
where e1.event_name = 'trial_started'
and e1.user_id not in (select user_id from events where event_name = 'app_open');

select count(distinct e1.user_id)
from events e1
where e1.event_name = 'subscription_purchased'
and e1.user_id not in ( select user_id from events where event_name = 'trial_started');

select 
(select count(*) from users)  as signups,
(select count(distinct user_id) from events where event_name = 'trial_started' ) as trial_started,
(select count(distinct user_id) from events where event_name = 'subscription_purchased' ) as subscribed,
round( (select count(distinct user_id) from events where event_name = 'trial_started') * 100.0
		/ (select count(*) from users),1) as signup_to_trial_pct,
round( (select count(distinct user_id) from events where event_name = 'subscription_purchased') *100.0
		/(select count(distinct user_id) from events where event_name = 'trial_started'),1) as trial_to_paid_pct,
round( (select count(distinct user_id) from events where event_name = 'subscription_purchased') * 100.0
		/(select count(*) from users),1) as overall_signup_to_paid_pct;
        
select date_format(signup_timestamp, '%Y-%m') as signup_month, count(*) as num_users
from users
group by signup_month
order by signup_month;

select date_format( u.signup_timestamp, '%Y-%m') as cohort_month,
		count( distinct u.user_id) as cohort_size,
        count( distinct case
				when e.event_timestamp > u.signup_timestamp
                and e.event_timestamp <= date_add( u.signup_timestamp, interval 2 month)
                then e.user_id END) as active_month1,
		round( count(distinct case
				when e.event_timestamp > u.signup_timestamp
                and e.event_timestamp <= date_add( u.signup_timestamp, interval 2 month) 
                then e.user_id END) * 100.0 / count( distinct u.user_id),1) as retention_pct
		from users u
        left join events e on u.user_id = e.user_id
        -- Right-censoring fix: exclude cohorts whose 2-month window hasn't fully passed yet (cutoff 2026-09-08),
		-- else recent signups look falsely retained since they haven't had time to churn.
		WHERE DATE_ADD(u.signup_timestamp, INTERVAL 2 MONTH) <= '2026-09-08'
        group by cohort_month
        order by cohort_month;
        
        select * from experiments;
        
        select variant, count(*) as user_assigned
        from experiment_assignments
        where experiment_id = 2
        group by variant;
        
  SELECT 
		ea.variant,
        count( distinct ea.user_id) as users_in_variant,
        count( distinct ev.user_id) as converted,
        round( count( distinct ev.user_id) * 100.0 / count( distinct ea.user_id), 1) as conversion_pct
from experiment_assignments ea
left join events ev
	on ea.user_id = ev.user_id
    and ev.event_name = 'subscription_purchased'
    and ev.event_timestamp >= ea.assignment_timestamp
where ea.experiment_id = 2
group by ea.variant;
        
SELECT user_id, COUNT(*) 
FROM experiment_assignments 
WHERE experiment_id = 2 
GROUP BY user_id 
HAVING COUNT(*) > 1;                

SELECT user_id, COUNT(DISTINCT variant) AS variant_count
FROM experiment_assignments
WHERE experiment_id = 2
GROUP BY user_id
HAVING COUNT(DISTINCT variant) > 1;

-- Exclude users who received BOTH control and treatment (contaminated assignment)
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