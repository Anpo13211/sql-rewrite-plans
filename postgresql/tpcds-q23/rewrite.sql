WITH frequent_item_weights AS MATERIALIZED
  (SELECT item_sk,
          count(*) AS item_weight
   FROM
     (SELECT ss.ss_item_sk AS item_sk,
             ss.ss_sold_date_sk
      FROM store_sales ss
      JOIN item i ON i.i_item_sk=ss.ss_item_sk
      WHERE ss.ss_sold_date_sk IN
          (SELECT d_date_sk
           FROM date_dim
           WHERE d_year IN (2000,2000+1,2000+2,2000+3))
      GROUP BY ss.ss_item_sk,
               ss.ss_sold_date_sk
      HAVING count(*)>4) x
   GROUP BY item_sk), max_store_sales AS MATERIALIZED
  (SELECT max(csales) AS tpcds_cmax
   FROM
     (SELECT ss.ss_customer_sk,
             sum(ss.ss_quantity*ss.ss_sales_price) AS csales
      FROM store_sales ss
      JOIN customer c ON c.c_customer_sk=ss.ss_customer_sk
      WHERE ss.ss_sold_date_sk IN
          (SELECT d_date_sk
           FROM date_dim
           WHERE d_year IN (2000,2000+1,2000+2,2000+3))
      GROUP BY ss.ss_customer_sk) x), best_ss_customer AS MATERIALIZED
  (SELECT ss.ss_customer_sk AS c_customer_sk
   FROM store_sales ss
   JOIN customer c ON c.c_customer_sk=ss.ss_customer_sk
   GROUP BY ss.ss_customer_sk
   HAVING sum(ss.ss_quantity*ss.ss_sales_price)>(50::double precision/100.0)*
     (SELECT tpcds_cmax
      FROM max_store_sales))
SELECT c_last_name,
       c_first_name,
       sales
FROM
  (SELECT c.c_last_name,
          c.c_first_name,
          sum(cs.cs_quantity*cs.cs_list_price*f.item_weight) AS sales
   FROM catalog_sales cs
   JOIN frequent_item_weights f ON f.item_sk=cs.cs_item_sk
   JOIN best_ss_customer b ON b.c_customer_sk=cs.cs_bill_customer_sk
   JOIN customer c ON c.c_customer_sk=cs.cs_bill_customer_sk
   WHERE cs.cs_sold_date_sk IN
       (SELECT d_date_sk
        FROM date_dim
        WHERE d_year=2000
          AND d_moy=2)
   GROUP BY c.c_last_name,
            c.c_first_name
   UNION ALL SELECT c.c_last_name,
                    c.c_first_name,
                    sum(ws.ws_quantity*ws.ws_list_price*f.item_weight) AS sales
   FROM web_sales ws
   JOIN frequent_item_weights f ON f.item_sk=ws.ws_item_sk
   JOIN best_ss_customer b ON b.c_customer_sk=ws.ws_bill_customer_sk
   JOIN customer c ON c.c_customer_sk=ws.ws_bill_customer_sk
   WHERE ws.ws_sold_date_sk IN
       (SELECT d_date_sk
        FROM date_dim
        WHERE d_year=2000
          AND d_moy=2)
   GROUP BY c.c_last_name,
            c.c_first_name) q
ORDER BY c_last_name NULLS FIRST,
         c_first_name NULLS FIRST,
         sales NULLS FIRST
LIMIT 100;
