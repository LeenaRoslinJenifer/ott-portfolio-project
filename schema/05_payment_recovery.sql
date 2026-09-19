
use ott_portfolio_c1;
SELECT failure_reason, COUNT(*) AS num_failures
FROM payment_transactions
WHERE status = 'failed'
GROUP BY failure_reason
ORDER BY num_failures DESC;

SELECT
    pt1.failure_reason,
    COUNT(DISTINCT pt1.transaction_id) AS failed_count,
    COUNT(DISTINCT pt2.transaction_id) AS recovered_count,
    ROUND(COUNT(DISTINCT pt2.transaction_id) * 100.0 / COUNT(DISTINCT pt1.transaction_id), 1) AS recovery_pct
FROM payment_transactions pt1
LEFT JOIN payment_transactions pt2
    ON pt1.subscription_id = pt2.subscription_id
    AND pt2.status = 'success'
    AND pt2.transaction_timestamp > pt1.transaction_timestamp
WHERE pt1.status = 'failed'
GROUP BY pt1.failure_reason;

SELECT
    pt1.failure_reason,
    COUNT(*) AS failed_count,
    SUM(CASE WHEN EXISTS (
        SELECT 1 FROM payment_transactions pt2
        WHERE pt2.subscription_id = pt1.subscription_id
        AND pt2.status = 'success'
        AND pt2.transaction_timestamp > pt1.transaction_timestamp
    ) THEN 1 ELSE 0 END) AS recovered_count,
    ROUND(SUM(CASE WHEN EXISTS (
        SELECT 1 FROM payment_transactions pt2
        WHERE pt2.subscription_id = pt1.subscription_id
        AND pt2.status = 'success'
        AND pt2.transaction_timestamp > pt1.transaction_timestamp
    ) THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS recovery_pct
FROM payment_transactions pt1
WHERE pt1.status = 'failed'
GROUP BY pt1.failure_reason;
