create table customers(
    customer_id bigint primary key ,
    first_name varchar,
    last_name varchar,
    email varchar unique ,
    birth_day date,
    country_code varchar check (length(country_code) = 3),
    created_at timestamp,
    is_active boolean
);

create table accounts(
    account_id bigint primary key ,
    customer_id bigint,
    account_number varchar unique ,
    currency varchar check (currency in ('UAH', 'USD', 'EUR')),
    balance decimal check (balance >= 0),
    status varchar check (status in ('ACTIVE', 'INACTIVE', 'FROZEN', 'CLOSED')),
    opened_at timestamp,
    foreign key(customer_id) references customers(customer_id)

);


create table audit_log(
    audit_id bigint primary key ,
    customer_id bigint,
    table_name varchar,
    operation varchar check (operation in ('INSERT', 'UPDATE', 'DELETE')),
    old_value json,
    new_value json,
    changed_at timestamp,
    foreign key(customer_id) references customers(customer_id)
);

create table cards(
    card_id bigint primary key ,
    account_id bigint,
    card_number_hash varchar unique ,
    card_type varchar check (card_type in ('VISA_CLASSIC', 'VISA_GOLD', 'VISA_PLATINUM', 'MC_STANDARD', 'MC_GOLD', 'MC_PLATINUM', 'VIRTUAL')),
    status varchar check ( status in ('ACTIVE', 'BLOCKED', 'EXPIRED') ),
    expiration_date date,
    foreign key (account_id) references accounts(account_id)
);

create table transactions(
    transaction_id bigint primary key,
    account_id bigint,
    card_id bigint,
    amount decimal check (amount > 0),
    currency varchar check (currency in ('UAH', 'USD', 'EUR')),
    merchant_category varchar check (merchant_category in ('RETAIL', 'GAMBLING', 'CASH', 'ONLINE')),
    merchant_country varchar check (length(merchant_country) = 3),
    status varchar check (status in ('PENDING', 'APPROVED', 'DECLINED', 'FLAGGED')),
    risk_score int check (risk_score between 0 and 100),
    transaction_at timestamp,
    created_at timestamp,
    foreign key (card_id) references cards(card_id),
    foreign key (account_id) references accounts(account_id)
);

create table fraud_rules(
    rule_id bigint primary key,
    rule_name varchar,
    rule_type varchar check (rule_type in ('VELOCITY', 'GEOGRAPHY', 'LIMIT_EXCEEDED')),
    threshold_value int check (threshold_value >= 0),
    is_active boolean
);

create table transaction_status_history(
    history_id bigint primary key,
    transaction_id bigint,
    old_status varchar check (old_status in ('PENDING', 'APPROVED', 'DECLINED', 'FLAGGED')),
    new_status varchar check (new_status in ('PENDING', 'APPROVED', 'DECLINED', 'FLAGGED')),
    changed_at timestamp,
    changed_by varchar,
    foreign key (transaction_id) references transactions(transaction_id)
);

create table fraud_alerts(
    alert_id bigint primary key,
    transaction_id bigint,
    rule_id bigint,
    reason varchar,
    risk_score int check (risk_score between 0 and 100),
    alert_status varchar check (alert_status in ('OPEN', 'UNDER_REVIEW', 'RESOLVED_TRUE', 'RESOLVED_FALSE')),
    created_at timestamp,
    foreign key (transaction_id) references transactions(transaction_id),
    foreign key (rule_id) references fraud_rules(rule_id)
);
