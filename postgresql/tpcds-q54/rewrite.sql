WITH target_dates AS MATERIALIZED
  (SELECT min(d_date_sk) AS lo,
          max(d_date_sk) AS hi
   FROM date_dim
   WHERE d_year = 1998
     AND d_moy = 12), qualified_items AS MATERIALIZED
  (SELECT i_item_sk
   FROM item
   WHERE i_category = 'Women'
     AND i_class = 'maternity'), buyer_ids AS MATERIALIZED
  (SELECT cs.cs_bill_customer_sk AS customer_sk
   FROM catalog_sales cs
   CROSS JOIN target_dates td
   JOIN qualified_items qi ON qi.i_item_sk = cs.cs_item_sk
   WHERE cs.cs_sold_date_sk BETWEEN td.lo AND td.hi
   UNION SELECT ws.ws_bill_customer_sk
   FROM web_sales ws
   CROSS JOIN target_dates td
   JOIN qualified_items qi ON qi.i_item_sk = ws.ws_item_sk
   WHERE ws.ws_sold_date_sk BETWEEN td.lo AND td.hi), my_customers AS MATERIALIZED
  (SELECT c.c_customer_sk,
          c.c_current_addr_sk
   FROM customer c
   JOIN buyer_ids b ON b.customer_sk = c.c_customer_sk), customer_store_count AS MATERIALIZED
  (SELECT mc.c_customer_sk,
          count(*)::bigint AS store_count
   FROM my_customers mc
   JOIN customer_address ca ON ca.ca_address_sk = mc.c_current_addr_sk
   JOIN store s ON s.s_county = ca.ca_county
   AND s.s_state = ca.ca_state
   GROUP BY mc.c_customer_sk), month_bounds AS MATERIALIZED
  (SELECT
     (SELECT min(d_month_seq) + 1
      FROM date_dim
      WHERE d_year = 1998
        AND d_moy = 12) AS lo,

     (SELECT max(d_month_seq) + 3
      FROM date_dim
      WHERE d_year = 1998
        AND d_moy = 12) AS hi), revenue_dates AS MATERIALIZED
  (SELECT min(d.d_date_sk) AS lo,
          max(d.d_date_sk) AS hi
   FROM date_dim d
   CROSS JOIN month_bounds mb
   WHERE d.d_month_seq BETWEEN mb.lo AND mb.hi), sales_by_customer AS
  (SELECT ss.ss_customer_sk,
          sum(ss.ss_ext_sales_price) AS gross_revenue
   FROM store_sales ss
   JOIN customer_store_count csc ON csc.c_customer_sk = ss.ss_customer_sk
   CROSS JOIN revenue_dates rd
   WHERE ss.ss_sold_date_sk BETWEEN rd.lo AND rd.hi
   GROUP BY ss.ss_customer_sk),
                                                 segments AS
  (SELECT round((sbc.gross_revenue * csc.store_count) / 50)::int AS SEGMENT
   FROM sales_by_customer sbc
   JOIN customer_store_count csc ON csc.c_customer_sk = sbc.ss_customer_sk)
SELECT SEGMENT,
       count(*) AS num_customers,
       SEGMENT * 50 AS segment_base
FROM segments
GROUP BY SEGMENT
ORDER BY SEGMENT NULLS FIRST, num_customers NULLS FIRST,
                              segment_base
LIMIT 100;
