-- 01_load_data.sql
-- Run this AFTER 00_schema.sql has already created the 13 tables.
-- Usage: USE ott_portfolio_c1; then run this file (SOURCE 01_load_data.sql;)

USE ott_portfolio_c1;

-- 1. users
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES
(user_id, signup_timestamp, signup_platform, @campaign_id, trial_eligible, country)
SET campaign_id = NULLIF(@campaign_id, '');

-- 2. content
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/content.csv'
INTO TABLE content
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- 3. plans
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/plans.csv'
INTO TABLE plans
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- 4. experiments
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/experiments.csv'
INTO TABLE experiments
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- 5. sessions
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/sessions.csv'
INTO TABLE sessions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- 6. subscriptions
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/subscriptions.csv'
INTO TABLE subscriptions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES
(subscription_id, user_id, plan_id, trial_start_timestamp, auto_renew,
 @cancel_req, @cancel_eff, @cancel_reason)
SET cancel_requested_timestamp = NULLIF(@cancel_req, ''),
    cancel_effective_timestamp = NULLIF(@cancel_eff, ''),
    cancellation_reason = NULLIF(@cancel_reason, '');

-- 7. events
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/events.csv'
INTO TABLE events
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES
(event_id, user_id, @session_id, @content_id, event_name, event_timestamp)
SET session_id = NULLIF(@session_id, ''),
    content_id = NULLIF(@content_id, '');

-- 8. viewing_activity
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/viewing_activity.csv'
INTO TABLE viewing_activity
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- 9. payment_transactions
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/payment_transactions.csv'
INTO TABLE payment_transactions
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES
(transaction_id, subscription_id, user_id, transaction_timestamp, amount, status, @failure_reason)
SET failure_reason = NULLIF(@failure_reason, '');

-- 10. marketing_spend
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/marketing_spend.csv'
INTO TABLE marketing_spend
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- 11. experiment_assignments
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/experiment_assignments.csv'
INTO TABLE experiment_assignments
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- 12. experiment_exposures
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/experiment_exposures.csv'
INTO TABLE experiment_exposures
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- 13. cancellation_feedback
LOAD DATA LOCAL INFILE 'D:/Product_Analyst_Preparation/ott-portfolio-project/ott-portfolio-project/data/cancellation_feedback.csv'
INTO TABLE cancellation_feedback
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 LINES;
