
create view vw_customer_accounts as
select  customer_id, concat(first_name, last_name), email, account_number, balance, currency, status
from customers join accounts using(customer_id);

create view vw_recent_transactions as
select * from transactions
where created_at >= now() - interval '30 days';


create view vw_customer_risk_profile as
    with average_risk_score_customer as(
    select customer_id, avg(coalesce(risk_score, 0)) as average
    from customers c
    join accounts a using (customer_id)
    left join transactions t on t.account_id = a.account_id
    group by customer_id
)select customer_id, concat(first_name, ' ', last_name) as name, a.account_id,
           count(transaction_id) as risk_transactions, average as average_risk_score,
           max(risk_score) as max_customer_risk_score, sum(amount) as blocked_sum
    from customers c
    join accounts a using (customer_id)
    left join transactions t on t.account_id = a.account_id
    left join average_risk_score_customer using (customer_id)
where t.status = 'FLAGGED'
group by customer_id, first_name, last_name , a.account_id, average
order by average desc ;
