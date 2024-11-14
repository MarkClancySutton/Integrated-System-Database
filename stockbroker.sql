-- Create tables

-- Create the database
CREATE DATABASE stockbroker;

-- Connect to the newly created database
--\c stockbroker;

-- Create schema if needed (optional)
CREATE SCHEMA IF NOT EXISTS stockbroker;

-- Create the tables within the stockbroker schema
CREATE TABLE stockbroker.Companies (
    companyID SERIAL PRIMARY KEY,
    companyName VARCHAR(100) NOT NULL,
    annualRevenue DECIMAL
);

CREATE TABLE stockbroker.Traders (
    staffID SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    joinDate DATE
);

CREATE TABLE stockbroker.Portfolios (
    portfolioID SERIAL PRIMARY KEY,
    portfolioName VARCHAR(100) NOT NULL
);

-- Step 1: Create a Partitioned Table
CREATE TABLE stockbroker.Prices(
    companyID INT,
    date DATE,
    value DECIMAL,
    PRIMARY KEY (companyID, date)
) PARTITION BY RANGE (date);


CREATE TABLE stockbroker.positions (
    companyID INT,
    portfolioID INT,
    stockHeld DECIMAL,
    PRIMARY KEY (companyID, portfolioID)
) PARTITION BY LIST (portfolioID);


-- Grant privileges to user alice on the stockbroker schema
GRANT ALL PRIVILEGES ON SCHEMA stockbroker TO alice;

-- Grant privileges to user alice on all tables within the stockbroker schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA stockbroker TO alice;

-- Grant privileges to user alice on sequences within the stockbroker schema (if any auto-increment columns)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA stockbroker TO alice;

ALTER ROLE alice WITH CREATEROLE;


--Security section
CREATE ROLE Traders LOGIN;
CREATE ROLE Customers LOGIN;

-- Grant appropriate permissions to Traders
GRANT SELECT, INSERT, UPDATE ON stockbroker.Companies TO Traders;
GRANT SELECT, INSERT, UPDATE ON stockbroker.Prices TO Traders;
GRANT SELECT, INSERT, UPDATE ON stockbroker.Positions TO Traders;

-- Grant read-only access to Customers
GRANT SELECT ON stockbroker.Positions TO Customers;

CREATE EXTENSION IF NOT EXISTS pgaudit;


-- Auditing section
SELECT audit.audit_table('stockbroker.companies', 'all');
SELECT audit.audit_table('stockbroker.traders', 'all');
SELECT audit.audit_table('stockbroker.portfolios', 'all');

GRANT EXECUTE ON FUNCTION audit.audit_table TO traders;

SELECT * FROM pg_audit_log;

-- Indexing
CREATE INDEX idx_companies_companyID ON stockbroker.companies (companyID);
CREATE INDEX idx_traders_staffID ON stockbroker.traders (staffID);
CREATE INDEX idx_portfolios_portfolioID ON stockbroker.portfolios (portfolioID);
CREATE INDEX idx_prices_companyID ON stockbroker.prices (companyID);
CREATE INDEX idx_prices_date ON stockbroker.prices (date);
CREATE INDEX idx_positions_companyID ON stockbroker.positions (companyID);
CREATE INDEX idx_positions_portfolioID ON stockbroker.positions (portfolioID);

-- Partitioning
-- For yearly based partitions
CREATE TABLE stockbroker.prices_2022 PARTITION OF stockbroker.prices FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE stockbroker.prices_2023 PARTITION OF stockbroker.prices FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

--to see the other partitioned tables 
drop table stockbroker.prices_2022;
drop table stockbroker.prices_2023;

-- For Quarter partitions
CREATE TABLE stockbroker.prices_q1 PARTITION OF stockbroker.prices
    FOR VALUES FROM ('2022-01-01') TO ('2022-04-01');

CREATE TABLE stockbroker.prices_q2 PARTITION OF stockbroker.prices
    FOR VALUES FROM ('2022-04-01') TO ('2022-07-01');

CREATE TABLE stockbroker.prices_q3 PARTITION OF stockbroker.prices
    FOR VALUES FROM ('2022-07-01') TO ('2022-10-01');

CREATE TABLE stockbroker.prices_q4 PARTITION OF stockbroker.prices
    FOR VALUES FROM ('2022-10-01') TO ('2023-01-01');
	
drop table stockbroker.prices_q1;
drop table stockbroker.prices_q2;
drop table stockbroker.prices_q3;
drop table stockbroker.prices_q4;

CREATE TABLE stockbroker.positions_portfolio_1 PARTITION OF stockbroker.positions FOR VALUES IN (1);
CREATE TABLE stockbroker.positions_portfolio_2 PARTITION OF stockbroker.positions FOR VALUES IN (2);
-- Add more partitions as needed for other portfolios