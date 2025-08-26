-- 01_staging_schema.sql
-- MySQL STAGING SCHEMA & TABLE + CSV load hints

CREATE DATABASE IF NOT EXISTS demo_staging;
USE demo_staging;

DROP TABLE IF EXISTS stg_orders;
CREATE TABLE stg_orders (
  `Row ID` INT,
  `Order ID` VARCHAR(255),
  `Order Date` DATE,
  `Ship Date` DATE,
  `Ship Mode` VARCHAR(255),
  `Customer ID` VARCHAR(255),
  `Customer Name` VARCHAR(255),
  `Segment` VARCHAR(255),
  `Country/Region` VARCHAR(255),
  `City` VARCHAR(255),
  `State` VARCHAR(255),
  `Postal Code` INT,
  `Region` VARCHAR(255),
  `Product ID` VARCHAR(255),
  `Category` VARCHAR(255),
  `Sub-Category` VARCHAR(255),
  `Product Name` VARCHAR(255),
  `Sales` DECIMAL(12,2),
  `Quantity` INT,
  `Discount` DECIMAL(6,3),
  `Profit` DECIMAL(12,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Load your CSV (adjust file path and LOCAL setting depending on your MySQL configuration)
-- IMPORTANT: ensure local_infile=1 in both client and server if using LOCAL.
-- Example:
--   SET GLOBAL local_infile=1;
--   mysql --local-infile=1 -u <user> -p
--   LOAD DATA LOCAL INFILE '/absolute/path/to/orders.csv'
--   INTO TABLE stg_orders
--   FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
--   LINES TERMINATED BY '\n'
--   IGNORE 1 LINES;

SET GLOBAL local_infile=1;
-- mysql --local-infile=1 -u <user> -p; run this on terminal before running the LOAD

-- Example LOAD (edit path accordingly)
-- LOAD DATA LOCAL INFILE '/path/to/orders.csv'
-- INTO TABLE stg_orders
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES;
