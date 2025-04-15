-- Create database
CREATE DATABASE IF NOT EXISTS bank_system;
USE bank_system;

-- Create customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create accounts table
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    balance DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account INT,
    to_account INT,
    amount DECIMAL(10,2),
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for automatic balance update after transaction
DELIMITER //
CREATE TRIGGER update_balance_after_transaction
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'DEPOSIT' THEN
        UPDATE accounts SET balance = balance + NEW.amount WHERE account_id = NEW.to_account;
    ELSEIF NEW.transaction_type = 'WITHDRAWAL' THEN
        UPDATE accounts SET balance = balance - NEW.amount WHERE account_id = NEW.from_account;
    ELSEIF NEW.transaction_type = 'TRANSFER' THEN
        UPDATE accounts SET balance = balance - NEW.amount WHERE account_id = NEW.from_account;
        UPDATE accounts SET balance = balance + NEW.amount WHERE account_id = NEW.to_account;
    END IF;
END;
//
DELIMITER ;

-- Stored Procedure: Create account
DELIMITER //
CREATE PROCEDURE create_account(
    IN name VARCHAR(100),
    IN email VARCHAR(100),
    IN phone VARCHAR(15),
    IN initial_deposit DECIMAL(10,2)
)
BEGIN
    DECLARE cid INT;

    INSERT INTO customers(name, email, phone) VALUES(name, email, phone);
    SET cid = LAST_INSERT_ID();
    INSERT INTO accounts(customer_id, balance) VALUES(cid, 0.00);
    
    SET @acc_id = LAST_INSERT_ID();
    
    -- Insert initial deposit transaction
    INSERT INTO transactions(to_account, amount, transaction_type)
    VALUES (@acc_id, initial_deposit, 'DEPOSIT');
END;
//
DELIMITER ;

-- Stored Procedure: Transfer Funds
DELIMITER //
CREATE PROCEDURE transfer_funds(
    IN from_acc INT,
    IN to_acc INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    -- Check if balance is sufficient
    DECLARE from_balance DECIMAL(10,2);

    SELECT balance INTO from_balance FROM accounts WHERE account_id = from_acc;
    
    IF from_balance >= amount THEN
        INSERT INTO transactions(from_account, to_account, amount, transaction_type)
        VALUES(from_acc, to_acc, amount, 'TRANSFER');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient Balance';
    END IF;
END;
//
DELIMITER ;

-- View for bank statement
CREATE VIEW bank_statements AS
SELECT 
    t.transaction_id,
    a.account_id,
    c.name AS account_holder,
    t.transaction_type,
    t.amount,
    t.created_at
FROM transactions t
LEFT JOIN accounts a ON t.from_account = a.account_id OR t.to_account = a.account_id
LEFT JOIN customers c ON a.customer_id = c.customer_id;
