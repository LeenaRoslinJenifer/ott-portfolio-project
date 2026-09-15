-- OTT Portfolio Project — Schema v2 (revised, audit-fixed)
-- Run this INSIDE your target database, e.g.:
--   CREATE DATABASE IF NOT EXISTS ott_portfolio_c1;
--   USE ott_portfolio_c1;
--   SOURCE schema_v2_revised.sql;


DROP DATABASE IF EXISTS ott_portfolio_c1;
CREATE DATABASE ott_portfolio_c1;
USE ott_portfolio_c1;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    signup_timestamp DATETIME NOT NULL,
    signup_platform VARCHAR(20),
    campaign_id VARCHAR(50) NULL,
    trial_eligible TINYINT(1) NOT NULL,
    country VARCHAR(5)
);

CREATE TABLE content (
    content_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(30),
    duration_minutes INT,
    is_live TINYINT(1)
);

CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(30),
    monthly_price INT,
    billing_cycle_days INT
);

CREATE TABLE experiments (
    experiment_id INT PRIMARY KEY,
    experiment_name VARCHAR(50),
    start_date DATE
);

CREATE TABLE sessions (
    session_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    session_start_timestamp DATETIME NOT NULL,
    platform VARCHAR(20),
    session_duration_minutes INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    trial_start_timestamp DATETIME,
    auto_renew TINYINT(1),
    cancel_requested_timestamp DATETIME NULL,
    cancel_effective_timestamp DATETIME NULL,
    cancellation_reason VARCHAR(50) NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

CREATE TABLE events (
    event_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    session_id INT NULL,
    content_id INT NULL,
    event_name VARCHAR(50),
    event_timestamp DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (session_id) REFERENCES sessions(session_id),
    FOREIGN KEY (content_id) REFERENCES content(content_id)
);

CREATE TABLE viewing_activity (
    view_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    content_id INT NOT NULL,
    view_timestamp DATETIME NOT NULL,
    watch_duration_minutes INT,
    playback_failure TINYINT(1),
    search_to_play TINYINT(1),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (content_id) REFERENCES content(content_id)
);

CREATE TABLE payment_transactions (
    transaction_id INT PRIMARY KEY,
    subscription_id INT NOT NULL,
    user_id INT NOT NULL,
    transaction_timestamp DATETIME,
    amount INT,
    status VARCHAR(20),
    failure_reason VARCHAR(50) NULL,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE marketing_spend (
    spend_id INT PRIMARY KEY,
    campaign_id VARCHAR(50),
    spend_date DATE,
    amount_spent DECIMAL(10,2),
    impressions INT,
    clicks INT
);

CREATE TABLE experiment_assignments (
    assignment_id INT PRIMARY KEY,
    experiment_id INT NOT NULL,
    user_id INT NOT NULL,
    variant VARCHAR(20),
    assignment_timestamp DATETIME NOT NULL,
    FOREIGN KEY (experiment_id) REFERENCES experiments(experiment_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE experiment_exposures (
    exposure_id INT PRIMARY KEY,
    assignment_id INT NOT NULL,
    exposure_timestamp DATETIME NOT NULL,
    FOREIGN KEY (assignment_id) REFERENCES experiment_assignments(assignment_id)
);

CREATE TABLE cancellation_feedback (
    feedback_id INT PRIMARY KEY,
    subscription_id INT NOT NULL,
    user_id INT NOT NULL,
    feedback_text VARCHAR(255),
    rating INT,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
