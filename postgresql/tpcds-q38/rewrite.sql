WITH store_keys AS MATERIALIZED
  (SELECT DISTINCT ss.ss_customer_sk AS customer_sk,
                   d.d_date
   FROM date_dim d
   JOIN store_sales ss ON ss.ss_sold_date_sk = d.d_date_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200 + 11), catalog_keys AS MATERIALIZED
  (SELECT DISTINCT cs.cs_bill_customer_sk AS customer_sk,
                   d.d_date
   FROM date_dim d
   JOIN catalog_sales cs ON cs.cs_sold_date_sk = d.d_date_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200 + 11), web_keys AS MATERIALIZED
  (SELECT DISTINCT ws.ws_bill_customer_sk AS customer_sk,
                   d.d_date
   FROM date_dim d
   JOIN web_sales ws ON ws.ws_sold_date_sk = d.d_date_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200 + 11), store_set AS
  (SELECT c.c_last_name,
          c.c_first_name,
          k.d_date
   FROM store_keys k
   JOIN customer c ON c.c_customer_sk = k.customer_sk),
                                             catalog_set AS
  (SELECT c.c_last_name,
          c.c_first_name,
          k.d_date
   FROM catalog_keys k
   JOIN customer c ON c.c_customer_sk = k.customer_sk),
                                             web_set AS
  (SELECT c.c_last_name,
          c.c_first_name,
          k.d_date
   FROM web_keys k
   JOIN customer c ON c.c_customer_sk = k.customer_sk)
SELECT count(*)
FROM
  (
     (SELECT *
      FROM web_set INTERSECT SELECT *
      FROM catalog_set) INTERSECT SELECT *
   FROM store_set) AS hot_cust
LIMIT 100;
