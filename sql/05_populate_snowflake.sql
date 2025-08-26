-- 05_populate_snowflake.sql
-- Populate SNOWFLAKE schema (run after 02 & 03 DDL and after 04 has built dim_date)
USE snowflake_schema;

-- Copy dates into snowflake schema (from star schema)
INSERT INTO dim_date (date_key, full_date, day_of_month, month_num, month_name, quarter_num, year_num, week_num, day_name)
SELECT * FROM star_schema.dim_date
ON DUPLICATE KEY UPDATE full_date=VALUES(full_date);

-- Ship mode
INSERT INTO dim_ship_mode (ship_mode)
SELECT DISTINCT `Ship Mode` FROM demo_staging.stg_orders
WHERE `Ship Mode` IS NOT NULL
ON DUPLICATE KEY UPDATE ship_mode=VALUES(ship_mode);

-- Region
INSERT INTO dim_region (region)
SELECT DISTINCT `Region` FROM demo_staging.stg_orders
WHERE `Region` IS NOT NULL
ON DUPLICATE KEY UPDATE region=VALUES(region);

-- Country
INSERT INTO dim_country (country, region_key)
SELECT DISTINCT s.`Country/Region`, r.region_key
FROM demo_staging.stg_orders s
LEFT JOIN dim_region r ON r.region = s.`Region`
WHERE s.`Country/Region` IS NOT NULL
ON DUPLICATE KEY UPDATE region_key=VALUES(region_key);

-- State
INSERT INTO dim_state (state, country_key)
SELECT DISTINCT s.`State`, c.country_key
FROM demo_staging.stg_orders s
LEFT JOIN dim_country c ON c.country = s.`Country/Region`
WHERE s.`State` IS NOT NULL
ON DUPLICATE KEY UPDATE country_key=VALUES(country_key);

-- City
INSERT INTO dim_city (city, state_key, postal_code)
SELECT DISTINCT s.`City`, st.state_key, s.`Postal Code`
FROM demo_staging.stg_orders s
LEFT JOIN dim_state st ON st.state = s.`State`
WHERE s.`City` IS NOT NULL
ON DUPLICATE KEY UPDATE state_key=VALUES(state_key), postal_code=VALUES(postal_code);

-- Location
INSERT INTO dim_location (city_key)
SELECT DISTINCT ci.city_key
FROM dim_city ci
ON DUPLICATE KEY UPDATE city_key=VALUES(city_key);

-- Category
INSERT INTO dim_category (category)
SELECT DISTINCT `Category` FROM demo_staging.stg_orders
WHERE `Category` IS NOT NULL
ON DUPLICATE KEY UPDATE category=VALUES(category);

-- Subcategory
INSERT INTO dim_subcategory (sub_category, category_key)
SELECT DISTINCT s.`Sub-Category`, c.category_key
FROM demo_staging.stg_orders s
LEFT JOIN dim_category c ON c.category = s.`Category`
WHERE s.`Sub-Category` IS NOT NULL
ON DUPLICATE KEY UPDATE category_key=VALUES(category_key);

-- Product
INSERT INTO dim_product (product_id, product_name, subcategory_key)
SELECT DISTINCT s.`Product ID`, s.`Product Name`, sc.subcategory_key
FROM demo_staging.stg_orders s
LEFT JOIN dim_subcategory sc ON sc.sub_category = s.`Sub-Category`
ON DUPLICATE KEY UPDATE product_name=VALUES(product_name), subcategory_key=VALUES(subcategory_key);

-- Customer (links to normalized location)
INSERT INTO dim_customer (customer_id, customer_name, segment, location_key)
SELECT DISTINCT s.`Customer ID`, s.`Customer Name`, s.`Segment`, lo.location_key
FROM demo_staging.stg_orders s
LEFT JOIN dim_city ci ON ci.city = s.`City` AND (ci.postal_code <=> s.`Postal Code`)
LEFT JOIN dim_location lo ON lo.city_key = ci.city_key
ON DUPLICATE KEY UPDATE customer_name=VALUES(customer_name), segment=VALUES(segment), location_key=VALUES(location_key);

-- Fact
INSERT INTO fact_orders (
  order_id, order_line, order_date_key, ship_date_key, customer_key, product_key, ship_mode_key, sales, quantity, discount, profit
)
SELECT
  s.`Order ID` AS order_id,
  s.`Row ID` AS order_line,
  DATE_FORMAT(s.`Order Date`, '%Y%m%d')+0 AS order_date_key,
  CASE WHEN s.`Ship Date` IS NULL THEN NULL ELSE DATE_FORMAT(s.`Ship Date`, '%Y%m%d')+0 END AS ship_date_key,
  dc.customer_key,
  dp.product_key,
  dsm.ship_mode_key,
  s.`Sales`,
  s.`Quantity`,
  s.`Discount`,
  s.`Profit`
FROM demo_staging.stg_orders s
LEFT JOIN dim_customer dc ON dc.customer_id = s.`Customer ID`
LEFT JOIN dim_product  dp ON dp.product_id  = s.`Product ID`
LEFT JOIN dim_ship_mode dsm ON dsm.ship_mode = s.`Ship Mode`;
