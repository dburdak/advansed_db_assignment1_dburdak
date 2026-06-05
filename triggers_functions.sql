
CREATE OR REPLACE FUNCTION log_transaction_status_change()
RETURNS TRIGGER AS $$
BEGIN
    insert into transaction_status_history(transaction_id, old_status, new_status, changed_at, changed_by)
    values (OLD.transaction_id, OLD.status, NEW.status, current_timestamp, current_user);

    return null;
END;
$$ LANGUAGE plpgsql;

create or replace trigger transaction_status_change
after update
on transactions
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
execute function log_transaction_status_change();



CREATE SEQUENCE IF NOT EXISTS fraud_alerts_seq START WITH 1;
CREATE SEQUENCE IF NOT EXISTS status_history_seq START WITH 1;


CREATE OR REPLACE FUNCTION tg_risk_score_on_transaction()
RETURNS TRIGGER AS $$
DECLARE
    v_rule RECORD;
    v_customer_country VARCHAR;
    v_velocity_count INT;
    v_alert_id BIGINT;
BEGIN
    SELECT c.country_code INTO v_customer_country
    FROM accounts a
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE a.account_id = NEW.account_id;

    SELECT COUNT(*) INTO v_velocity_count
    FROM transactions
    WHERE account_id = NEW.account_id
      AND transaction_at >= NEW.transaction_at - INTERVAL '5 minutes';

    FOR v_rule IN
        SELECT rule_id, rule_name, rule_type, threshold_value
        FROM fraud_rules
        WHERE is_active = true
    LOOP
        IF v_rule.rule_type = 'LIMIT_EXCEEDED' AND NEW.amount > v_rule.threshold_value THEN
            NEW.risk_score := 40;
            NEW.status := 'FLAGGED';

            v_alert_id := nextval('fraud_alerts_seq');

            INSERT INTO fraud_alerts(alert_id, transaction_id, rule_id, reason, risk_score, alert_status, created_at)
            VALUES(v_alert_id, NEW.transaction_id, v_rule.rule_id, 'The rule has been broken: ' || v_rule.rule_name, NEW.risk_score, 'OPEN', NOW());
            RETURN NEW;

        ELSIF v_rule.rule_type = 'GEOGRAPHY' AND v_rule.threshold_value = 1 AND NEW.merchant_country != v_customer_country THEN
            NEW.risk_score := 35;
            NEW.status := 'FLAGGED';

            v_alert_id := nextval('fraud_alerts_seq');

            INSERT INTO fraud_alerts(alert_id, transaction_id, rule_id, reason, risk_score, alert_status, created_at)
            VALUES(v_alert_id, NEW.transaction_id, v_rule.rule_id, 'The rule has been broken: ' || v_rule.rule_name, NEW.risk_score, 'OPEN', NOW());
            RETURN NEW;

        ELSIF v_rule.rule_type = 'VELOCITY' AND v_velocity_count >= v_rule.threshold_value THEN
            NEW.risk_score := 25;
            NEW.status := 'FLAGGED';
            v_alert_id := nextval('fraud_alerts_seq');

            INSERT INTO fraud_alerts(alert_id, transaction_id, rule_id, reason, risk_score, alert_status, created_at)
            VALUES(v_alert_id, NEW.transaction_id, v_rule.rule_id, 'The rule has been broken: ' || v_rule.rule_name, NEW.risk_score, 'OPEN', NOW());
            RETURN NEW;
        END IF;
    END LOOP;

    NEW.risk_score := 0;
    NEW.status := 'APPROVED';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION log_transaction_status_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO transaction_status_history(history_id, transaction_id, old_status, new_status, changed_at, changed_by)
    VALUES (nextval('status_history_seq'), OLD.transaction_id, OLD.status, NEW.status, CURRENT_TIMESTAMP, CURRENT_USER);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;



create trigger before_insert_transaction
before insert on transactions
for each row
execute function tg_risk_score_on_transaction();


create sequence if not exists audit_log_seq start with 1;

create or replace function tg_audit_log()
returns trigger as $$
declare
    v_customer_id bigint;
    v_old_json json := null;
    v_new_json json := null;
begin
    if tg_op = 'INSERT' then
        v_new_json := row_to_json(new);
    elsif tg_op = 'UPDATE' then
        v_old_json := row_to_json(old);
        v_new_json := row_to_json(new);
    elsif tg_op = 'DELETE' then
        v_old_json := row_to_json(old);
    end if;

    if tg_table_name = 'customers' or tg_table_name = 'accounts' then
        if tg_op = 'DELETE' then
            v_customer_id := old.customer_id;
        else
            v_customer_id := new.customer_id;
        end if;
    elsif tg_table_name = 'cards' then
        if tg_op = 'DELETE' then
            v_customer_id := (select customer_id from accounts where account_id = old.account_id);
        else
            v_customer_id := (select customer_id from accounts where account_id = new.account_id);
        end if;
    end if;

    insert into audit_log (
        audit_id,
        customer_id,
        table_name,
        operation,
        old_value,
        new_value,
        changed_at
    )
    values (
        nextval('audit_log_seq'),
        v_customer_id,
        tg_table_name,
        tg_op,
        v_old_json,
        v_new_json,
        now()
    );
    return null;
end;
$$ language plpgsql;

create trigger audit_customers_trigger
after insert or update or delete on customers
for each row execute function tg_audit_log();

create trigger audit_accounts_trigger
after insert or update or delete on accounts
for each row execute function tg_audit_log();

create trigger audit_cards_trigger
after insert or update or delete on cards
for each row execute function tg_audit_log();

create or replace function transaction_execution()
returns trigger
as $$
   begin
   update accounts
   set balance = balance - new.amount
   where account_id = new.account_id;
   return null;
end;
    $$ language plpgsql;

create or replace trigger tg_execute_transaction_insert
    after insert on transactions
    FOR EACH ROW
    when (NEW.status = 'APPROVED')
    execute function transaction_execution();

create or replace trigger tg_execute_transaction_update
    after update on transactions
    FOR EACH ROW
    when (NEW.status = 'APPROVED' and OLD.status IS DISTINCT FROM NEW.status)
    execute function transaction_execution();
