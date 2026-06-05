
INSERT INTO customers (customer_id, first_name, last_name, email, birth_day, country_code, created_at, is_active) VALUES
(1, 'Олександр', 'Петренко', 'olex.petr@email.com', '1988-05-12', 'UKR', '2023-01-15 10:00:00', true),
(2, 'John', 'Doe', 'john.doe@example.com', '1990-11-23', 'USA', '2023-02-20 11:30:00', true),
(3, 'Hans', 'Müller', 'hans.m@domain.de', '1975-03-09', 'DEU', '2023-03-10 09:15:00', true),
(4, 'Emma', 'Smith', 'emma.smith@mail.co.uk', '1995-07-30', 'GBR', '2023-04-05 14:20:00', true),
(5, 'Marie', 'Dubois', 'marie.dubois@test.fr', '1982-12-01', 'FRA', '2023-05-18 16:45:00', true),
(6, 'Jan', 'Kowalski', 'j.kowalski@poczta.pl', '1993-08-14', 'POL', '2023-06-22 12:00:00', true),
(7, 'Carlos', 'Garcia', 'carlos.g@correo.es', '1989-02-28', 'ESP', '2023-07-11 10:10:00', false),
(8, 'Giovanni', 'Rossi', 'g.rossi@italy.it', '1970-10-05', 'ITA', '2023-08-01 08:30:00', true),
(9, 'Robert', 'Brown', 'robert.b@canada.ca', '2000-04-17', 'CAN', '2023-09-09 17:00:00', true),
(10, 'David', 'Warner', 'd.warner@aus.com', '1985-06-25', 'AUS', '2023-10-10 15:25:00', true);


INSERT INTO accounts (account_id, customer_id, account_number, currency, balance, status, opened_at) VALUES
(101, 1, 'UA123456789012345678901234561', 'UAH', 250000.00, 'ACTIVE', '2023-01-15 10:05:00'),
(102, 2, 'US987654321098765432109876542', 'USD', 5400.50, 'ACTIVE', '2023-02-20 11:35:00'),
(103, 3, 'DE112233445566778899001122333', 'EUR', 1250.00, 'ACTIVE', '2023-03-10 09:20:00'),
(104, 4, 'GB443322110055667788991122334', 'USD', 890.00, 'ACTIVE', '2023-04-05 14:25:00'),
(105, 5, 'FR556677889900112233445566775', 'EUR', 0.00, 'INACTIVE', '2023-05-18 16:50:00'),
(106, 6, 'PL998877665544332211009988776', 'UAH', 15000.75, 'ACTIVE', '2023-06-22 12:05:00'),
(107, 7, 'ES111122223333444455556666777', 'EUR', 43000.00, 'FROZEN', '2023-07-11 10:15:00'),
(108, 8, 'IT999988887777666655554444338', 'EUR', 720.00, 'ACTIVE', '2023-08-01 08:35:00'),
(109, 9, 'CA555544443333222211110000999', 'USD', 10500.20, 'ACTIVE', '2023-09-09 17:05:00'),
(110, 10, 'AU121234345656787890901212340', 'UAH', 0.00, 'CLOSED', '2023-10-10 15:30:00');


INSERT INTO cards (card_id, account_id, card_number_hash, card_type, status, expiration_date) VALUES
(201, 101, 'hash_card_1_petrenko', 'VISA_PLATINUM', 'ACTIVE', '2028-12-31'),
(202, 102, 'hash_card_2_doe', 'MC_GOLD', 'ACTIVE', '2027-05-31'),
(203, 103, 'hash_card_3_muller', 'MC_STANDARD', 'ACTIVE', '2026-09-30'),
(204, 104, 'hash_card_4_smith', 'VISA_CLASSIC', 'ACTIVE', '2027-01-31'),
(205, 105, 'hash_card_5_dubois', 'VIRTUAL', 'EXPIRED', '2024-05-01'),
(206, 106, 'hash_card_6_kowalski', 'MC_PLATINUM', 'ACTIVE', '2029-03-31'),
(207, 107, 'hash_card_7_garcia', 'VISA_GOLD', 'BLOCKED', '2027-11-30'),
(208, 108, 'hash_card_8_rossi', 'VISA_CLASSIC', 'ACTIVE', '2026-08-31'),
(209, 109, 'hash_card_9_brown', 'MC_STANDARD', 'ACTIVE', '2028-04-30'),
(210, 110, 'hash_card_10_warner', 'VIRTUAL', 'BLOCKED', '2025-10-31');

INSERT INTO fraud_rules (rule_id, rule_name, rule_type, threshold_value, is_active) VALUES
(1, 'High Amount Transaction', 'LIMIT_EXCEEDED', 10000, true),
(2, 'Extreme Amount Transaction', 'LIMIT_EXCEEDED', 50000, true),
(3, 'Cross-Border Operation', 'GEOGRAPHY', 1, true),
(4, 'High Velocity (5 min)', 'VELOCITY', 5, true),
(5, 'Extreme Velocity (5 min)', 'VELOCITY', 10, true),
(6, 'Night Retail Limit', 'LIMIT_EXCEEDED', 2000, false),
(7, 'Suspicious Country Merchant', 'GEOGRAPHY', 1, false),
(8, 'Micro-burst Transactions', 'VELOCITY', 3, true),
(9, 'Standard Online Limit', 'LIMIT_EXCEEDED', 5000, true),
(10, 'VIP Limit Exceeded', 'LIMIT_EXCEEDED', 100000, true);

INSERT INTO transactions (transaction_id, account_id, card_id, amount, currency, merchant_category, merchant_country, status, risk_score, transaction_at, created_at) VALUES
(301, 101, 201, 1500.00, 'UAH', 'RETAIL', 'UKR', 'APPROVED', 0, now() - interval '2 days', now() - interval '2 days'),
(302, 102, 202, 250.00, 'USD', 'ONLINE', 'USA', 'APPROVED', 5, now() - interval '5 days', now() - interval '5 days'),
(303, 103, 203, 45000.00, 'EUR', 'ONLINE', 'DEU', 'FLAGGED', 40, now() - interval '10 mins', now() - interval '10 mins'),
(304, 104, 204, 12000.00, 'USD', 'CASH', 'GBR', 'DECLINED', 45, now() - interval '12 days', now() - interval '12 days'),
(305, 106, 206, 300.00, 'UAH', 'RETAIL', 'POL', 'APPROVED', 0, now() - interval '1 day', now() - interval '1 day'),
(306, 101, 201, 85000.00, 'UAH', 'GAMBLING', 'UKR', 'FLAGGED', 75, now() - interval '1 hour', now() - interval '1 hour'),
(307, 108, 208, 50.00, 'EUR', 'ONLINE', 'USA', 'APPROVED', 20, now() - interval '15 days', now() - interval '15 days'),
(308, 109, 209, 9900.00, 'USD', 'CASH', 'CAN', 'APPROVED', 10, now() - interval '20 days', now() - interval '20 days'),
(309, 102, 202, 15.00, 'USD', 'ONLINE', 'FRA', 'FLAGGED', 35, now() - interval '5 mins', now() - interval '5 mins'),
(310, 107, 207, 500.00, 'EUR', 'RETAIL', 'ESP', 'DECLINED', 15, now() - interval '3 days', now() - interval '3 days');

INSERT INTO fraud_alerts (alert_id, transaction_id, rule_id, reason, risk_score, alert_status, created_at) VALUES
(401, 303, 2, 'The rule has been broken: Extreme Amount Transaction', 40, 'OPEN', now() - interval '10 mins'),
(402, 306, 1, 'The rule has been broken: High Amount Transaction', 40, 'UNDER_REVIEW', now() - interval '1 hour'),
(403, 309, 3, 'The rule has been broken: Cross-Border Operation', 35, 'OPEN', now() - interval '5 mins'),
(404, 304, 1, 'The rule has been broken: High Amount Transaction', 40, 'RESOLVED_FALSE', now() - interval '12 days'),
(405, 303, 1, 'The rule has been broken: High Amount Transaction', 40, 'OPEN', now() - interval '10 mins'),
(406, 306, 10, 'The rule has been broken: VIP Limit Exceeded', 50, 'UNDER_REVIEW', now() - interval '1 hour'),
(407, 309, 9, 'The rule has been broken: Standard Online Limit', 30, 'RESOLVED_TRUE', now() - interval '4 mins'),
(408, 303, 9, 'The rule has been broken: Standard Online Limit', 40, 'OPEN', now() - interval '10 mins'),
(409, 304, 9, 'The rule has been broken: Standard Online Limit', 40, 'RESOLVED_FALSE', now() - interval '12 days'),
(410, 306, 2, 'The rule has been broken: Extreme Amount Transaction', 75, 'OPEN', now() - interval '1 hour');
