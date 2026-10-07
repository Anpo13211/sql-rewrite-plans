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
   WHERE d_month_seq BETWEEN 1200 AND 1200 + 11), hits AS MATERIALIZED
  (SELECT 1 AS src,
          ss_customer_sk AS customer_sk,
          sd.d_date
   FROM store_sales
   JOIN sd ON sd.d_date_sk = ss_sold_date_sk
   GROUP BY ss_customer_sk,
            sd.d_date
   UNION ALL SELECT 2 AS src,
                    cs_bill_customer_sk AS customer_sk,
                    cd.d_date
   FROM catalog_sales
   JOIN cd ON cd.d_date_sk = cs_sold_date_sk
   GROUP BY cs_bill_customer_sk,
            cd.d_date
   UNION ALL SELECT 3 AS src,
                    ws_bill_customer_sk AS customer_sk,
                    wd.d_date
   FROM web_sales
   JOIN wd ON wd.d_date_sk = ws_sold_date_sk
   GROUP BY ws_bill_customer_sk,
            wd.d_date), named_hits AS MATERIALIZED
  (SELECT DISTINCT src,
                   c.c_last_name,
                   c.c_first_name,
                   h.d_date
   FROM hits h
   JOIN customer c ON c.c_customer_sk = h.customer_sk)
SELECT count(*)
FROM
  (SELECT c_last_name,
          c_first_name,
          d_date
   FROM named_hits
   GROUP BY c_last_name,
            c_first_name,
            d_date
   HAVING count(*) = 3) hot_cust
LIMIT 100;
