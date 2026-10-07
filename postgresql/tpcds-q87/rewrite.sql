WITH s AS MATERIALIZED
  (SELECT ss.ss_customer_sk AS customer_sk,
          d.d_date
   FROM date_dim d
   JOIN store_sales ss ON ss.ss_sold_date_sk=d.d_date_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200 + 11
   GROUP BY ss.ss_customer_sk,
            d.d_date), c AS MATERIALIZED
  (SELECT cs.cs_bill_customer_sk AS customer_sk,
          d.d_date
   FROM date_dim d
   JOIN catalog_sales cs ON cs.cs_sold_date_sk=d.d_date_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200 + 11
   GROUP BY cs.cs_bill_customer_sk,
            d.d_date), w AS MATERIALIZED
  (SELECT ws.ws_bill_customer_sk AS customer_sk,
          d.d_date
   FROM date_dim d
   JOIN web_sales ws ON ws.ws_sold_date_sk=d.d_date_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200 + 11
   GROUP BY ws.ws_bill_customer_sk,
            d.d_date)
SELECT count(*)
FROM (
        (SELECT cu.c_last_name,
                cu.c_first_name,
                s.d_date
         FROM s
         JOIN customer cu ON cu.c_customer_sk=s.customer_sk)
      EXCEPT (
                (SELECT cu.c_last_name,
                        cu.c_first_name,
                        c.d_date
                 FROM c
                 JOIN customer cu ON cu.c_customer_sk=c.customer_sk)
              UNION ALL
                (SELECT cu.c_last_name,
                        cu.c_first_name,
                        w.d_date
                 FROM w
                 JOIN customer cu ON cu.c_customer_sk=w.customer_sk))) AS cool_cust;
