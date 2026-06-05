-- top risky customers
SELECT 
    name, 
    risk_transactions, 
    average_risk_score, 
    blocked_sum 
FROM vw_customer_risk_profile
WHERE risk_transactions > 0
ORDER BY average_risk_score DESC
LIMIT 5;

-- weekly report on fraud alerts
SELECT 
    date, 
    total_transactions, 
    flagged_transactions, 
    suspicious_transaction_amount 
FROM mv_daily_fraud_summary
ORDER BY date DESC
LIMIT 7;

-- recent risky transactions 
SELECT 
    transaction_id, 
    amount, 
    currency, 
    merchant_category, 
    risk_score 
FROM vw_recent_transactions
WHERE status = 'FLAGGED'
ORDER BY risk_score DESC;

-- fraud rules that was detected on most fragged transactions 
SELECT 
    fr.rule_name, 
    COUNT(fa.alert_id) AS total_alerts
FROM fraud_rules fr
LEFT JOIN fraud_alerts fa USING (rule_id)
WHERE fr.is_active = true
GROUP BY fr.rule_name
ORDER BY total_alerts DESC;


-- to see security risks per category
SELECT
    merchant_category,
    COUNT(transaction_id) AS total_tx_count,
    SUM(amount) AS total_volume,
    ROUND(AVG(risk_score), 2) AS avg_risk_score,
    COUNT(transaction_id) FILTER (WHERE status = 'FLAGGED') AS flagged_tx_count,
    ROUND(
        COUNT(transaction_id) FILTER (WHERE status = 'FLAGGED')::numeric / 
        GREATEST(COUNT(transaction_id), 1) * 100, 2
    ) AS flagged_pct
FROM transactions
GROUP BY merchant_category
ORDER BY flagged_pct DESC, avg_risk_score DESC;

