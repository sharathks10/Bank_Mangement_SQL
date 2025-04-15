# 🏦 Bank Management System (SQL Based)

A simple database-driven Bank Management System to manage accounts, transactions, balances, and generate bank statements.

## 🔧 Technologies Used
- MySQL (SQL)

## 💡 Features
- Customer and account creation using stored procedures
- Fund transfer between accounts
- Triggers for automatic balance updates
- Audit logging via transaction table
- Bank statement view for transaction history

## 📁 File Structure
- `bank_management.sql` – Complete SQL code to create DB, tables, procedures, triggers, and views.
- `README.md` – Project overview.

## 🧪 How to Run
1. Open MySQL Workbench or CLI.
2. Run the `bank_management.sql` file.
3. Call stored procedures like:

```sql
CALL create_account('Jack Sparrow', 'jack@gmail.com', '9876543210', 1000.00);
CALL transfer_funds(1, 2, 500.00);
SELECT * FROM bank_statements;
