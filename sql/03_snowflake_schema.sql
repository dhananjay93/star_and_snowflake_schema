-- 03_snowflake_schema.sql
-- MySQL SNOWFLAKE SCHEMA DDL

CREATE DATABASE IF NOT EXISTS snowflake_schema;
USE snowflake_schema;

DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date LIKE star_schema.dim_date;

DROP TABLE IF EXISTS dim_ship_mode;
CREATE TABLE dim_ship_mode LIKE star_schema.dim_ship_mode;

DROP TABLE IF EXISTS dim_region;
CREATE TABLE dim_region (
  region_key INT AUTO_INCREMENT PRIMARY KEY,
  region VARCHAR(100) NOT NULL,
  UNIQUE KEY uk_region (region)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_country;
CREATE TABLE dim_country (
  country_key INT AUTO_INCREMENT PRIMARY KEY,
  country VARCHAR(255) NOT NULL,
  region_key INT,
  UNIQUE KEY uk_country (country),
  CONSTRAINT fk_country_region FOREIGN KEY (region_key) REFERENCES dim_region(region_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_state;
CREATE TABLE dim_state (
  state_key INT AUTO_INCREMENT PRIMARY KEY,
  state VARCHAR(255) NOT NULL,
  country_key INT,
  UNIQUE KEY uk_state (state, country_key),
  CONSTRAINT fk_state_country FOREIGN KEY (country_key) REFERENCES dim_country(country_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_city;
CREATE TABLE dim_city (
  city_key INT AUTO_INCREMENT PRIMARY KEY,
  city VARCHAR(255) NOT NULL,
  state_key INT,
  postal_code VARCHAR(20),
  UNIQUE KEY uk_city (city, state_key, postal_code),
  CONSTRAINT fk_city_state FOREIGN KEY (state_key) REFERENCES dim_state(state_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_location;
CREATE TABLE dim_location (
  location_key INT AUTO_INCREMENT PRIMARY KEY,
  city_key INT,
  CONSTRAINT fk_location_city FOREIGN KEY (city_key) REFERENCES dim_city(city_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
  customer_key INT AUTO_INCREMENT PRIMARY KEY,
  customer_id VARCHAR(64) NOT NULL,
  customer_name VARCHAR(255) NOT NULL,
  segment VARCHAR(100),
  location_key INT,
  UNIQUE KEY uk_customer_id (customer_id),
  CONSTRAINT fk_customer_location FOREIGN KEY (location_key) REFERENCES dim_location(location_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_category;
CREATE TABLE dim_category (
  category_key INT AUTO_INCREMENT PRIMARY KEY,
  category VARCHAR(255) NOT NULL,
  UNIQUE KEY uk_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_subcategory;
CREATE TABLE dim_subcategory (
  subcategory_key INT AUTO_INCREMENT PRIMARY KEY,
  sub_category VARCHAR(255) NOT NULL,
  category_key INT,
  UNIQUE KEY uk_subcat (sub_category, category_key),
  CONSTRAINT fk_subcat_cat FOREIGN KEY (category_key) REFERENCES dim_category(category_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product (
  product_key INT AUTO_INCREMENT PRIMARY KEY,
  product_id VARCHAR(64) NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  subcategory_key INT,
  UNIQUE KEY uk_product_id (product_id),
  CONSTRAINT fk_product_subcat FOREIGN KEY (subcategory_key) REFERENCES dim_subcategory(subcategory_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS fact_orders;
CREATE TABLE fact_orders (
  fact_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id VARCHAR(64) NOT NULL,
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
