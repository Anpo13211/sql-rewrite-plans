WITH frequent_items AS MATERIALIZED
  (SELECT ss.ss_item_sk AS item_sk
   FROM store_sales ss
   JOIN date_dim d ON d.d_date_sk=ss.ss_sold_date_sk
   JOIN item i ON i.i_item_sk=ss.ss_item_sk
   WHERE d.d_year IN (2000,2000+1,2000+2,2000+3)
   GROUP BY ss.ss_item_sk,
            ss.ss_sold_date_sk
   HAVING count(*)>4),period_customer_sales AS MATERIALIZED
  (SELECT ss.ss_customer_sk AS customer_sk,
          sum(ss.ss_quantity*ss.ss_sales_price) AS sales
   FROM store_sales ss
   JOIN
     (SELECT d_date_sk
      FROM date_dim
      WHERE d_year IN (2000,2000+1,2000+2,2000+3)) d ON d.d_date_sk=ss.ss_sold_date_sk
   JOIN customer c ON c.c_customer_sk=ss.ss_customer_sk
   GROUP BY ss.ss_customer_sk),maximum_sales AS
  (SELECT max(sales) AS max_sales
   FROM period_customer_sales),
                               all_customer_sales AS MATERIALIZED
  (SELECT ss.ss_customer_sk AS customer_sk,
          sum(ss.ss_quantity*ss.ss_sales_price) AS sales
   FROM store_sales ss
   JOIN customer c ON c.c_customer_sk=ss.ss_customer_sk
   GROUP BY ss.ss_customer_sk),best_customers AS MATERIALIZED
  (SELECT a.customer_sk
   FROM all_customer_sales a
   CROSS JOIN maximum_sales m
   WHERE a.sales>(50/100.0)*m.max_sales)
SELECT c.c_last_name,
       c.c_first_name,
       sum(cs.cs_quantity*cs.cs_list_price) AS sales
FROM catalog_sales cs
JOIN date_dim d ON d.d_date_sk=cs.cs_sold_date_sk
AND d.d_year=2000
AND d.d_moy=2
JOIN frequent_items f ON f.item_sk=cs.cs_item_sk
JOIN best_customers b ON b.customer_sk=cs.cs_bill_customer_sk
JOIN customer c ON c.c_customer_sk=cs.cs_bill_customer_sk
GROUP BY c.c_last_name,
         c.c_first_name
UNION ALL
SELECT c.c_last_name,
       c.c_first_name,
       sum(ws.ws_quantity*ws.ws_list_price) AS sales
FROM web_sales ws
JOIN date_dim d ON d.d_date_sk=ws.ws_sold_date_sk
AND d.d_year=2000
AND d.d_moy=2
JOIN frequent_items f ON f.item_sk=ws.ws_item_sk
JOIN best_customers b ON b.customer_sk=ws.ws_bill_customer_sk
JOIN customer c ON c.c_customer_sk=ws.ws_bill_customer_sk
GROUP BY c.c_last_name,
         c.c_first_name
ORDER BY c_last_name NULLS FIRST,
         c_first_name NULLS FIRST,
         sales NULLS FIRST
LIMIT 100;
