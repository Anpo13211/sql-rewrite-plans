WITH filtered_sales AS
  (SELECT ss.ss_ticket_number,
          ss.ss_customer_sk,
          ss.ss_addr_sk,
          ss.ss_ext_sales_price,
          ss.ss_ext_tax,
          ss.ss_ext_list_price
   FROM date_dim AS d
   JOIN store_sales AS ss ON ss.ss_sold_date_sk = d.d_date_sk
   JOIN store AS s ON s.s_store_sk = ss.ss_store_sk
   JOIN household_demographics AS hd ON hd.hd_demo_sk = ss.ss_hdemo_sk
   WHERE d.d_dom BETWEEN 1 AND 2
     AND d.d_year IN (1999, 1999+1, 1999+2)
     AND s.s_city IN ('Fairview', 'Midway')
     AND (hd.hd_dep_count = 4
          OR hd.hd_vehicle_count = 3)),
     sales_rollup AS
  (SELECT ss_ticket_number,
          ss_customer_sk,
          ss_addr_sk,
          SUM(ss_ext_sales_price) AS extended_price,
          SUM(ss_ext_tax) AS extended_tax,
          SUM(ss_ext_list_price) AS list_price
   FROM filtered_sales
   GROUP BY ss_ticket_number,
            ss_customer_sk,
            ss_addr_sk)
SELECT c.c_last_name,
       c.c_first_name,
       current_addr.ca_city,
       bought_addr.ca_city AS bought_city,
       r.ss_ticket_number,
       r.extended_price,
       r.extended_tax,
       r.list_price
FROM sales_rollup AS r
JOIN customer AS c ON c.c_customer_sk = r.ss_customer_sk
JOIN customer_address AS current_addr ON current_addr.ca_address_sk = c.c_current_addr_sk
JOIN customer_address AS bought_addr ON bought_addr.ca_address_sk = r.ss_addr_sk
AND bought_addr.ca_city <> current_addr.ca_city
ORDER BY c.c_last_name NULLS FIRST,
         r.ss_ticket_number NULLS FIRST
LIMIT 100;
