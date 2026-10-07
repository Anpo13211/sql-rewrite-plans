WITH eligible_dates AS NOT MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_dow IN (6, 0)
     AND d_year IN (1999, 1999+1, 1999+2)), eligible_stores AS NOT MATERIALIZED
  (SELECT s_store_sk
   FROM store
   WHERE s_city IN ('Fairview', 'Midway')), eligible_households AS NOT MATERIALIZED
  (SELECT hd_demo_sk
   FROM household_demographics
   WHERE hd_dep_count = 4
     OR hd_vehicle_count = 3), sales_agg AS
  (SELECT ss.ss_ticket_number,
          ss.ss_customer_sk,
          ss.ss_addr_sk,
          SUM(ss.ss_coupon_amt) AS amt,
          SUM(ss.ss_net_profit) AS profit
   FROM store_sales ss
   JOIN eligible_dates d ON d.d_date_sk = ss.ss_sold_date_sk
   JOIN eligible_stores s ON s.s_store_sk = ss.ss_store_sk
   JOIN eligible_households hd ON hd.hd_demo_sk = ss.ss_hdemo_sk
   GROUP BY ss.ss_ticket_number,
            ss.ss_customer_sk,
            ss.ss_addr_sk)
SELECT c.c_last_name,
       c.c_first_name,
       current_addr.ca_city,
       bought_addr.ca_city AS bought_city,
       a.ss_ticket_number,
       a.amt,
       a.profit
FROM sales_agg a
JOIN customer c ON c.c_customer_sk = a.ss_customer_sk
JOIN customer_address current_addr ON current_addr.ca_address_sk = c.c_current_addr_sk
JOIN customer_address bought_addr ON bought_addr.ca_address_sk = a.ss_addr_sk
WHERE bought_addr.ca_city <> current_addr.ca_city
ORDER BY c.c_last_name NULLS FIRST,
         c.c_first_name NULLS FIRST,
         current_addr.ca_city NULLS FIRST,
         bought_addr.ca_city NULLS FIRST,
         a.ss_ticket_number NULLS FIRST
LIMIT 100;
