# 🏦 Anti-Fraud & Banking Core Database System

This project is a relational database system (PostgreSQL) designed for a banking core with an integrated real-time transaction monitoring and fraud detection system (**Anti-Fraud System**).

The system automatically evaluates the risk score of each financial operation based on geographical, quantitative, and time limits (Velocity checks), maintains a comprehensive audit log of user actions, and aggregates daily analytics.

---

## 📐 1. Database Architecture (Data Schema)

The database consists of 8 interconnected tables, which can be logically divided into three modules:

### 👤 Core Banking Module
* **`customers`**: Stores personal data of clients (Full Name, country of residence, account status).
* **`accounts`**: Manages multi-currency client accounts (`UAH`, `USD`, `EUR`) with a non-negative balance constraint.
* **`cards`**: Contains payment cards linked to bank accounts, featuring masked/hashed card numbers and various service tiers (Classic, Gold, Platinum, Virtual).

### 💸 Transaction Module
* **`transactions`**: Records payments, ATM cash withdrawals, and online purchases, while calculating a `risk_score` (ranging from 0 to 100) and assigning transaction statuses.

### 🛡 Anti-Fraud & Audit Module
* **`fraud_rules`**: Defines configurations for active fraud rules (limits, velocity thresholds, and geographical checks).
* **`fraud_alerts`**: Stores security alerts generated for suspicious transactions that require compliance review.
* **`transaction_status_history`**: Tracks every change in a transaction's status to prevent internal fraud and ensure data lineage.
* **`audit_log`**: Implements global CDC (Change Data Capture) auditing for customer, account, and card tables by storing historical states as `JSON` snapshots before and after modifications.

---

## 🧠 2. Automation & Business Logic (Triggers & Procedures)

The system is fully autonomous and operates via a robust set of PL/pgSQL triggers and stored procedures:

### 🔴 Risk Assessment (`BEFORE INSERT` on `transactions`)
The `before_insert_transaction` trigger analyzes each transaction **prior to its persistence** in the database using three main rule categories:
1.  **LIMIT_EXCEEDED**: If the transaction amount exceeds the rule threshold (e.g., > 10,000 or > 50,000), the transaction is flagged as `FLAGGED` and assigned a `risk_score = 40`.
2.  **GEOGRAPHY**: If the merchant's country (`merchant_country`) does not match the customer's home country, the transaction is classified as a cross-border anomaly (`risk_score = 35`, status `FLAGGED`).
3.  **VELOCITY**: Inspects the frequency of transactions over the last 5 minutes. If the threshold is breached, the transaction is marked as `FLAGGED` with a `risk_score = 25`.

Whenever a rule is violated, the system automatically inserts a corresponding entry into the `fraud_alerts` table. If no rules are triggered, the transaction status is automatically set to `APPROVED`.

### 🧮 Balance Execution (`AFTER INSERT / UPDATE` on `transactions`)
The `tg_execute_transaction_insert / update` trigger automatically deducts funds from the client's balance (`accounts.balance`), but **strictly on the condition** that the transaction transitions into the `APPROVED` status.

### 📝 Secure Withdrawal Procedure
The `execute_money_withdrawal` procedure encapsulates the cash withdrawal logic:
* Verifies if the target account exists.
* Validates sufficient fundsavailability (if funds are insufficient, it raises an `EXCEPTION` and rolls back the operation).
* Initiates the transaction in a `PENDING` state for subsequent anti-fraud screening.

---

## 📊 3. Analytical Database Views

The project includes three analytical views designed for the monitoring and risk-management departments:

1.  **`vw_customer_accounts`**: A consolidated view of the customer profile (Full Name, email, account number, current balance, account status).
2.  **`vw_recent_transactions`**: An operational snapshot displaying transactions from the last 30 days for rapid querying.
3.  **`vw_customer_risk_profile`**: A comprehensive risk exposure profile per client. It computes the average `risk_score` for each user, the count of their suspicious transactions, and the total monetary volume blocked due to fraud flags.

---

## ⚡ 4. Materialized Views for Performance

To optimize heavy analytical reporting, a materialized view named **`mv_daily_fraud_summary`** was implemented.

It aggregates millions of row-level transactions into high-level daily metrics:
* Total transaction count and volume per day.
* Count and volume of transactions blocked by the system (`flagged_transactions`).
* The bank's overall average daily risk score.
* **Top Risky Customer**: Automatically determines the specific customer ID who posed the highest risk to the bank during the current day (utilizing an optimized `DISTINCT ON` clause).
* Total number of security alerts triggered.

### 🔄 Scheduled Refresh Configuration
To keep analytical data fresh, an automatic refresh schedule has been configured to execute every 5 minutes using the system `cron` daemon (or `launchd` on macOS):

```text
*/5 * * * * export PGPASSWORD='your_password'; /opt/homebrew/bin/psql -h localhost -U
