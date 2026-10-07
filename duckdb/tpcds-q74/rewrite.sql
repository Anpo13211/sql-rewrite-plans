WITH sales AS MATERIALIZED
  (SELECT ss_customer_sk AS customer_sk,
          d_year AS year_,
          SUM(ss_net_paid) AS year_total,
          's' AS sale_type
   FROM store_sales
   JOIN date_dim ON d_date_sk=ss_sold_date_sk
   WHERE d_year IN (2001,2001+1)
   GROUP BY ss_customer_sk,
            d_year
   UNION ALL SELECT ws_bill_customer_sk AS customer_sk,
                    d_year AS year_,
                    SUM(ws_net_paid) AS year_total,
                    'w' AS sale_type
   FROM web_sales
   JOIN date_dim ON d_date_sk=ws_sold_date_sk
   WHERE d_year IN (2001,2001+1)
   GROUP BY ws_bill_customer_sk,
            d_year),totals AS
  (SELECT customer_sk,
          SUM(year_total) FILTER (
                                  WHERE sale_type='s'
                                    AND year_=2001) AS s_first,
          SUM(year_total) FILTER (
                                  WHERE sale_type='s'
                                    AND year_=2001+1) AS s_second,
          SUM(year_total) FILTER (
                                  WHERE sale_type='w'
                                    AND year_=2001) AS w_first,
          SUM(year_total) FILTER (
                                  WHERE sale_type='w'
                                    AND year_=2001+1) AS w_second
   FROM sales
   GROUP BY customer_sk)
SELECT c.c_customer_id AS customer_id,
       c.c_first_name AS customer_first_name,
       c.c_last_name AS customer_last_name
FROM totals t
JOIN customer c ON c.c_customer_sk=t.customer_sk
WHERE 's'='s'
  AND 'w'='w'
  AND 's'='s'
  AND 'w'='w'
  AND t.s_first>0
  AND t.w_first>0
  AND CASE
          WHEN t.w_first>0 THEN t.w_second/t.w_first
          ELSE NULL
      END>CASE
              WHEN t.s_first>0 THEN t.s_second/t.s_first
              ELSE NULL
          END
ORDER BY 1 NULLS FIRST
LIMIT 100;
