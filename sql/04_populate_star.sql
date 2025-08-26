-- 04_populate_star.sql
-- Populate STAR schema (run after staging is loaded)
USE star_schema;

-- Build date dimension from distinct dates in staging
INSERT INTO dim_date (date_key, full_date, day_of_month, month_num, month_name, quarter_num, year_num, week_num, day_name)
SELECT
  DATE_FORMAT(d,'%Y%m%d')+0 as date_key,
  d as full_date,
  DAY(d),
  MONTH(d),
  DATE_FORMAT(d, '%M'),
  QUARTER(d),
  YEAR(d),
  WEEK(d, 3),
  DATE_FORMAT(d, '%W')
FROM (
  SELECT DISTINCT `Order Date` AS d FROM demo_staging.stg_orders WHERE `Order Date` IS NOT NULL
  UNION
  SELECT DISTINCT `Ship Date` AS d FROM demo_staging.stg_orders WHERE `Ship Date` IS NOT NULL
) x
ON DUPLICATE KEY UPDATE full_date=VALUES(full_date);

-- Ship mode
INSERT INTO dim_ship_mode (ship_mode)
SELECT DISTINCT `Ship Mode` FROM demo_staging.stg_orders
WHERE `Ship Mode` IS NOT NULL
ON DUPLICATE KEY UPDATE ship_mode=VALUES(ship_mode);

-- Customer
INSERT INTO dim_customer (customer_id, customer_name, segment, city, state, postal_code, country, region)
SELECT DISTINCT
  `Customer ID`, `Customer Name`, `Segment`, `City`, `State`, `Postal Code`, `Country/Region`, `Region`
FROM demo_staging.stg_orders
ON DUPLICATE KEY UPDATE customer_name=VALUES(customer_name), segment=VALUES(segment), city=VALUES(city), state=VALUES(state),
  postal_code=VALUES(postal_code), country=VALUES(country), region=VALUES(region);

-- Product
INSERT INTO dim_product (product_id, product_name, sub_category, category)
SELECT DISTINCT
  `Product ID`, `Product Name`, `Sub-Category`, `Category`
FROM demo_staging.stg_orders
ON DUPLICATE KEY UPDATE product_name=VALUES(product_name), sub_category=VALUES(sub_category), category=VALUES(category);

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
