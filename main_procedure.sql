
create or replace procedure execute_money_withdrawal(
    p_transaction_id bigint,
    p_account_id bigint,
    p_card_id bigint,
    p_amount decimal,
    p_currency varchar,
    p_merchant_category varchar,
    p_merchant_country varchar
)
as $$
declare
    v_current_balance decimal;
begin
    select balance into v_current_balance
    from accounts
    where account_id = p_account_id;

    if v_current_balance is null then
        raise exception 'The account with ID % was not found!', p_account_id;
    end if;

    if v_current_balance < p_amount then
        raise exception 'Insufficient funds in the account! Balance: %, withdrawal amount: %', v_current_balance, p_amount;
    end if;

    insert into transactions(
        transaction_id, account_id, card_id, amount, currency,
        merchant_category, merchant_country, status, risk_score,
        transaction_at, created_at
    )
    values (
        p_transaction_id, p_account_id, p_card_id, p_amount, p_currency,
        p_merchant_category, p_merchant_country, 'PENDING', 0,
        now(), now()
    );

    commit;

end;
$$ language plpgsql;

