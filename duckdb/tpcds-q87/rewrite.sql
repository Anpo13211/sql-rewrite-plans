WITH sd AS MATERIALIZED
  (SELECT d_date_sk,
          d_date
   FROM date_dim
   WHERE d_month_seq BETWEEN 1200 AND 1200 + 11), cd AS MATERIALIZED
  (SELECT d_date_sk,
          d_date
   FROM date_dim
   WHERE d_month_seq BETWEEN 1200 AND 1200 + 11), wd AS MATERIALIZED
  (SELECT d_date_sk,
          d_date
   FROM date_dim
   WHERE d_month_seq BETWEEN 1200 AND 1200 + 11), sp AS MATERIALIZED
  (SELECT DISTINCT ss.ss_customer_sk AS customer_sk,
                   sd.d_date
   FROM store_sales ss
   JOIN sd ON sd.d_date_sk=ss.ss_sold_date_sk), bp AS MATERIALIZED
  (SELECT DISTINCT cs.cs_bill_customer_sk AS customer_sk,
                   cd.d_date
   FROM catalog_sales cs
   JOIN cd ON cd.d_date_sk=cs.cs_sold_date_sk
   UNION ALL SELECT DISTINCT ws.ws_bill_customer_sk AS customer_sk,
                             wd.d_date
   FROM web_sales ws
   JOIN wd ON wd.d_date_sk=ws.ws_sold_date_sk)
SELECT count(*)
FROM
  (SELECT c.c_last_name,
          c.c_first_name,
          sp.d_date
   FROM sp
   JOIN customer c ON c.c_customer_sk=sp.customer_sk
   EXCEPT SELECT c.c_last_name,
                 c.c_first_name,
                 bp.d_date
   FROM bp
   JOIN customer c ON c.c_customer_sk=bp.customer_sk) AS cool_cust;
