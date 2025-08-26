-- 02_star_schema.sql
-- MySQL STAR SCHEMA DDL

CREATE DATABASE IF NOT EXISTS star_schema;
USE star_schema;

DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date (
  date_key INT PRIMARY KEY,                  -- yyyymmdd
  full_date DATE NOT NULL,
  day_of_month TINYINT NOT NULL,
  month_num TINYINT NOT NULL,
  month_name VARCHAR(15) NOT NULL,
  quarter_num TINYINT NOT NULL,
  year_num SMALLINT NOT NULL,
  week_num TINYINT NOT NULL,
  day_name VARCHAR(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_ship_mode;
CREATE TABLE dim_ship_mode (
  ship_mode_key INT AUTO_INCREMENT PRIMARY KEY,
  ship_mode VARCHAR(100) NOT NULL,
  UNIQUE KEY uk_ship_mode (ship_mode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
  customer_key INT AUTO_INCREMENT PRIMARY KEY,
  customer_id VARCHAR(64) NOT NULL,
  customer_name VARCHAR(255) NOT NULL,
  segment VARCHAR(100),
  city VARCHAR(255),
  state VARCHAR(255),
  postal_code VARCHAR(20),
  country VARCHAR(255),
  region VARCHAR(100),
  UNIQUE KEY uk_customer_id (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product (
  product_key INT AUTO_INCREMENT PRIMARY KEY,
  product_id VARCHAR(64) NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  sub_category VARCHAR(255),
  category VARCHAR(255),
  UNIQUE KEY uk_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS fact_orders;
CREATE TABLE fact_orders (
  fact_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id VARCHAR(64) NOT NULL,                 -- degenerate dimension
  order_line INT NULL,
  order_date_key INT NOT NULL,
  ship_date_key INT NULL,
  customer_key INT NOT NULL,
  product_key INT NOT NULL,
  ship_mode_key INT NULL,
  sales DECIMAL(12,2) NOT NULL DEFAULT 0,
  quantity INT NOT NULL DEFAULT 0,
  discount DECIMAL(6,3) NOT NULL DEFAULT 0,
  profit DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_fact_order_date FOREIGN KEY (order_date_key) REFERENCES dim_date(date_key),
  CONSTRAINT fk_fact_ship_date  FOREIGN KEY (ship_date_key)  REFERENCES dim_date(date_key),
  CONSTRAINT fk_fact_customer   FOREIGN KEY (customer_key)   REFERENCES dim_customer(customer_key),
  CONSTRAINT fk_fact_product    FOREIGN KEY (product_key)    REFERENCES dim_product(product_key),
  CONSTRAINT fk_fact_ship_mode  FOREIGN KEY (ship_mode_key)  REFERENCES dim_ship_mode(ship_mode_key),
  KEY idx_fact_order_date (order_date_key),
  KEY idx_fact_customer (customer_key),
  KEY idx_fact_product (product_key),
  KEY idx_fact_ship_mode (ship_mode_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
