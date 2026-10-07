WITH m(channel, period_no, d_year, ca_county, amount) AS
  (SELECT 's',
          1,
          d.d_year,
          ca.ca_county,
          SUM(ss.ss_ext_sales_price)
   FROM date_dim d
   JOIN store_sales ss ON ss.ss_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=ss.ss_addr_sk
   WHERE d.d_qoy=1
     AND d.d_year=2000
   GROUP BY d.d_year,
            ca.ca_county
   UNION ALL SELECT 's',
                    2,
                    d.d_year,
                    ca.ca_county,
                    SUM(ss.ss_ext_sales_price)
   FROM date_dim d
   JOIN store_sales ss ON ss.ss_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=ss.ss_addr_sk
   WHERE d.d_qoy=2
     AND d.d_year=2000
   GROUP BY d.d_year,
            ca.ca_county
   UNION ALL SELECT 's',
                    3,
                    d.d_year,
                    ca.ca_county,
                    SUM(ss.ss_ext_sales_price)
   FROM date_dim d
   JOIN store_sales ss ON ss.ss_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=ss.ss_addr_sk
   WHERE d.d_qoy=3
     AND d.d_year=2000
   GROUP BY d.d_year,
            ca.ca_county
   UNION ALL SELECT 'w',
                    1,
                    d.d_year,
                    ca.ca_county,
                    SUM(ws.ws_ext_sales_price)
   FROM date_dim d
   JOIN web_sales ws ON ws.ws_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=ws.ws_bill_addr_sk
   WHERE d.d_qoy=1
     AND d.d_year=2000
   GROUP BY d.d_year,
            ca.ca_county
   UNION ALL SELECT 'w',
                    2,
                    d.d_year,
                    ca.ca_county,
                    SUM(ws.ws_ext_sales_price)
   FROM date_dim d
   JOIN web_sales ws ON ws.ws_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=ws.ws_bill_addr_sk
   WHERE d.d_qoy=2
     AND d.d_year=2000
   GROUP BY d.d_year,
            ca.ca_county
   UNION ALL SELECT 'w',
                    3,
                    d.d_year,
                    ca.ca_county,
                    SUM(ws.ws_ext_sales_price)
   FROM date_dim d
   JOIN web_sales ws ON ws.ws_sold_date_sk=d.d_date_sk
   JOIN customer_address ca ON ca.ca_address_sk=ws.ws_bill_addr_sk
   WHERE d.d_qoy=3
     AND d.d_year=2000
   GROUP BY d.d_year,
            ca.ca_county),
     v AS
  (SELECT ca_county,
          MAX(d_year) FILTER (
                              WHERE channel='s'
                                AND period_no=1) AS d_year,
          MAX(amount) FILTER (
                              WHERE channel='s'
                                AND period_no=1) AS s1,
          MAX(amount) FILTER (
                              WHERE channel='s'
                                AND period_no=2) AS s2,
          MAX(amount) FILTER (
                              WHERE channel='s'
                                AND period_no=3) AS s3,
          MAX(amount) FILTER (
                              WHERE channel='w'
                                AND period_no=1) AS w1,
          MAX(amount) FILTER (
                              WHERE channel='w'
                                AND period_no=2) AS w2,
          MAX(amount) FILTER (
                              WHERE channel='w'
                                AND period_no=3) AS w3
   FROM m
   GROUP BY ca_county)
SELECT ca_county,
       d_year,
       (w2*1.0000)/w1 AS web_q1_q2_increase,
       (s2*1.0000)/s1 AS store_q1_q2_increase,
       (w3*1.0000)/w2 AS web_q2_q3_increase,
       (s3*1.0000)/s2 AS store_q2_q3_increase
FROM v
WHERE w1>0
  AND s1>0
  AND (w2*1.0000)/w1>(s2*1.0000)/s1
  AND w2>0
  AND s2>0
  AND (w3*1.0000)/w2>(s3*1.0000)/s2
ORDER BY ca_county;
