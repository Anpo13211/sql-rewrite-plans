WITH s1 AS MATERIALIZED
  (SELECT ca.ca_county,
          d.d_year,
          SUM(s.ss_ext_sales_price) AS amount
   FROM date_dim d
   JOIN store_sales s ON s.ss_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=s.ss_addr_sk
   WHERE d.d_qoy=1
     AND d.d_year=2000
   GROUP BY ca.ca_county,
            d.d_year), s2 AS MATERIALIZED
  (SELECT ca.ca_county,
          SUM(s.ss_ext_sales_price) AS amount
   FROM date_dim d
   JOIN store_sales s ON s.ss_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=s.ss_addr_sk
   WHERE d.d_qoy=2
     AND d.d_year=2000
   GROUP BY ca.ca_county), s3 AS MATERIALIZED
  (SELECT ca.ca_county,
          SUM(s.ss_ext_sales_price) AS amount
   FROM date_dim d
   JOIN store_sales s ON s.ss_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=s.ss_addr_sk
   WHERE d.d_qoy=3
     AND d.d_year=2000
   GROUP BY ca.ca_county), w1 AS MATERIALIZED
  (SELECT ca.ca_county,
          SUM(w.ws_ext_sales_price) AS amount
   FROM date_dim d
   JOIN web_sales w ON w.ws_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=w.ws_bill_addr_sk
   WHERE d.d_qoy=1
     AND d.d_year=2000
   GROUP BY ca.ca_county), w2 AS MATERIALIZED
  (SELECT ca.ca_county,
          SUM(w.ws_ext_sales_price) AS amount
   FROM date_dim d
   JOIN web_sales w ON w.ws_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=w.ws_bill_addr_sk
   WHERE d.d_qoy=2
     AND d.d_year=2000
   GROUP BY ca.ca_county), w3 AS MATERIALIZED
  (SELECT ca.ca_county,
          SUM(w.ws_ext_sales_price) AS amount
   FROM date_dim d
   JOIN web_sales w ON w.ws_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=w.ws_bill_addr_sk
   WHERE d.d_qoy=3
     AND d.d_year=2000
   GROUP BY ca.ca_county)
SELECT s1.ca_county,
       s1.d_year,
       (w2.amount*1.0000)/w1.amount AS web_q1_q2_increase,
       (s2.amount*1.0000)/s1.amount AS store_q1_q2_increase,
       (w3.amount*1.0000)/w2.amount AS web_q2_q3_increase,
       (s3.amount*1.0000)/s2.amount AS store_q2_q3_increase
FROM s1
JOIN s2 USING (ca_county)
JOIN s3 USING (ca_county)
JOIN w1 USING (ca_county)
JOIN w2 USING (ca_county)
JOIN w3 USING (ca_county)
WHERE CASE
          WHEN w1.amount>0 THEN (w2.amount*1.0000)/w1.amount
          ELSE NULL
      END>CASE
              WHEN s1.amount>0 THEN (s2.amount*1.0000)/s1.amount
              ELSE NULL
          END
  AND CASE
          WHEN w2.amount>0 THEN (w3.amount*1.0000)/w2.amount
          ELSE NULL
      END>CASE
              WHEN s2.amount>0 THEN (s3.amount*1.0000)/s2.amount
              ELSE NULL
          END
ORDER BY s1.ca_county;
