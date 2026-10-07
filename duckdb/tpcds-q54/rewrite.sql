WITH filtered_catalog_customers AS
  (SELECT cs.cs_bill_customer_sk AS customer_sk
   FROM catalog_sales cs
   JOIN item i ON i.i_item_sk = cs.cs_item_sk
   JOIN date_dim d ON d.d_date_sk = cs.cs_sold_date_sk
   WHERE i.i_category = 'Women'
     AND i.i_class = 'maternity'
     AND d.d_moy = 12
     AND d.d_year = 1998),
     filtered_web_customers AS
  (SELECT ws.ws_bill_customer_sk AS customer_sk
   FROM web_sales ws
   JOIN item i ON i.i_item_sk = ws.ws_item_sk
   JOIN date_dim d ON d.d_date_sk = ws.ws_sold_date_sk
   WHERE i.i_category = 'Women'
     AND i.i_class = 'maternity'
     AND d.d_moy = 12
     AND d.d_year = 1998),
     qualified_buyers AS MATERIALIZED
  (SELECT customer_sk
   FROM filtered_catalog_customers
   UNION SELECT customer_sk
   FROM filtered_web_customers), bounds AS MATERIALIZED
  (SELECT min(d_month_seq) FILTER (
                                   WHERE d_year = 1998
                                     AND d_moy = 12) + 1 AS lo,
          min(d_month_seq) FILTER (
                                   WHERE d_year = 1998
                                     AND d_moy = 12) + 3 AS hi
   FROM date_dim), revenue_dates AS MATERIALIZED
  (SELECT d.d_date_sk
   FROM date_dim d
   CROSS JOIN bounds b
   WHERE d.d_month_seq BETWEEN b.lo AND b.hi), location_multiplicity AS MATERIALIZED
  (SELECT s_county,
          s_state,
          count(*) AS store_matches
   FROM store
   WHERE s_county IS NOT NULL
     AND s_state IS NOT NULL
   GROUP BY s_county,
            s_state), my_revenue AS
  (SELECT c.c_customer_sk,
          sum(ss.ss_ext_sales_price) * lm.store_matches AS revenue
   FROM qualified_buyers qb
   JOIN customer c ON c.c_customer_sk = qb.customer_sk
   JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
   JOIN location_multiplicity lm ON lm.s_county = ca.ca_county
   AND lm.s_state = ca.ca_state
   JOIN store_sales ss ON ss.ss_customer_sk = c.c_customer_sk
   JOIN revenue_dates rd ON rd.d_date_sk = ss.ss_sold_date_sk
   GROUP BY c.c_customer_sk,
            lm.store_matches),
                      segments AS
  (SELECT CAST(round(revenue / 50) AS INTEGER) AS SEGMENT
   FROM my_revenue)
SELECT SEGMENT,
       count(*) AS num_customers,
       SEGMENT * 50 AS segment_base
FROM segments
GROUP BY SEGMENT
ORDER BY SEGMENT NULLS FIRST, num_customers NULLS FIRST,
                              segment_base
LIMIT 100;
