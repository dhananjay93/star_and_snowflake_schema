# Data Modelling - Star vs Snowflake Schema

Blog : [https://www.notion.so/Data-Modelling-Star-vs-Snowflake-Schema-25babcbb30a080ccbba8e0908f1e21e1?source=copy_link] 

The objective is to create star and snowflake schema. We will be using superstore data. 


## Contents

- `sql/01_staging_schema.sql` → Creates staging schema and loads raw orders.
- `sql/02_star_schema.sql` → STAR schema DDL (dim_date, dim_customer, dim_product, etc).
- `sql/03_snowflake_schema.sql` → SNOWFLAKE schema DDL (normalized geography, product hierarchy).
- `sql/04_populate_star.sql` → Populates STAR dimensions and fact table from staging.
- `sql/05_populate_snowflake.sql` → Populates SNOWFLAKE dimensions and fact table.
