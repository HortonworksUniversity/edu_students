--impala-shell -l -u cloudera  --auth_creds_ok_in_clear -f kudu.sql --var=DB=tpcds_kudu_10 --var=HIVE_DB=tpcds_text_10

--impala-shell -f kudu.sql --var=DB=tpcds_kudu_10 --var=HIVE_DB=tpcds_text_10


drop database if exists ${VAR:DB} cascade;
create database ${VAR:DB};
use ${VAR:DB};

drop table if exists call_center;
create table ${VAR:DB}.call_center
PRIMARY KEY (cc_call_center_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.call_center;

drop table if exists catalog_page;
create table ${VAR:DB}.catalog_page
PRIMARY KEY (cp_catalog_page_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.catalog_page;

drop table if exists catalog_returns;
create table ${VAR:DB}.catalog_returns
PRIMARY KEY (cr_returned_date_sk,cr_returned_time_sk,cr_item_sk,cr_refunded_customer_sk)
PARTITION BY HASH(cr_returned_date_sk,cr_returned_time_sk,cr_item_sk,cr_refunded_customer_sk) PARTITIONS 3
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.catalog_returns;

drop table if exists catalog_sales;
create table ${VAR:DB}.catalog_sales
PRIMARY KEY (cs_sold_date_sk,cs_sold_time_sk,cs_ship_date_sk,cs_bill_customer_sk)
PARTITION BY HASH(cs_sold_date_sk,cs_sold_time_sk,cs_ship_date_sk,cs_bill_customer_sk) PARTITIONS 3
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.catalog_sales;

drop table if exists customer_address;
create table ${VAR:DB}.customer_address
PRIMARY KEY (ca_address_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.customer_address;

drop table if exists customer_demographics;
create table ${VAR:DB}.customer_demographics
PRIMARY KEY (cd_demo_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.customer_demographics;

drop table if exists customer;
create table ${VAR:DB}.customer
PRIMARY KEY (c_customer_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.customer;

drop table if exists date_dim;
create table ${VAR:DB}.date_dim
PRIMARY KEY (d_date_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.date_dim;

drop table if exists household_demographics;
create table ${VAR:DB}.household_demographics
PRIMARY KEY (hd_demo_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.household_demographics;

drop table if exists income_band;
create table ${VAR:DB}.income_band
PRIMARY KEY (ib_income_band_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.income_band;

drop table if exists inventory;
create table ${VAR:DB}.inventory
PRIMARY KEY (inv_date_sk,inv_item_sk,inv_warehouse_sk)
PARTITION BY HASH(inv_date_sk,inv_item_sk,inv_warehouse_sk) PARTITIONS 3
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.inventory;

drop table if exists item;
create table ${VAR:DB}.item
PRIMARY KEY (i_item_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.item;

drop table if exists promotion;
create table ${VAR:DB}.promotion
PRIMARY KEY (p_promo_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.promotion;

drop table if exists reason;
create table ${VAR:DB}.reason
PRIMARY KEY (r_reason_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.reason;

drop table if exists ship_mode;
create table ${VAR:DB}.ship_mode
PRIMARY KEY (sm_ship_mode_sk)
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.ship_mode;

drop table if exists store_returns;
create table ${VAR:DB}.store_returns
PRIMARY KEY (sr_returned_date_sk,sr_return_time_sk,sr_item_sk,sr_customer_sk)
PARTITION BY HASH(sr_returned_date_sk,sr_return_time_sk,sr_item_sk,sr_customer_sk) PARTITIONS 3
STORED AS KUDU
as select * from ${VAR:HIVE_DB}.store_returns;

