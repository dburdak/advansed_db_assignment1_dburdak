create materialized view mv_daily_fraud_summary as

with top_daily_risky_customers as (
    select distinct on (date(t.created_at))
        date(t.created_at) as transaction_date,
        a.customer_id,
        round(avg(t.risk_score), 2) as avg_customer_risk
    from transactions t
    join accounts a using(account_id)
    group by date(t.created_at), a.customer_id
    order by date(t.created_at) desc, avg_customer_risk desc
)
select
    date(t.created_at) as date,
    count(distinct t.transaction_id) as total_transactions,
    sum(t.amount) as total_amount,
    count(case when t.status = 'FLAGGED' then 1 end) as flagged_transactions,
    coalesce(sum(case when t.status = 'FLAGGED' then t.amount end), 0) as suspicious_transaction_amount,
    round(avg(t.risk_score), 2) as average_risk_score,
    tp.customer_id as top_risky_customer_id,
    count(f.alert_id) as total_fraud_alerts

from transactions t
left join top_daily_risky_customers tp on tp.transaction_date = date(t.created_at)
left join fraud_alerts f on f.transaction_id = t.transaction_id
group by date(t.created_at), tp.customer_id
order by date(t.created_at) desc;

select sum(amount) from transactions where date(created_at) = '2026-06-04';

select * from mv_daily_fraud_summary;
