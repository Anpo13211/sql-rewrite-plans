WITH target_items AS
  (SELECT i_item_sk
   FROM item
   WHERE i_manufact_id = 977),
     target_dates AS
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_date BETWEEN '2000-01-27' AND CAST('2000-04-26' AS DATE)),
     filtered_sales AS MATERIALIZED
  (SELECT cs.cs_item_sk,
          cs.cs_ext_discount_amt
   FROM target_items i
   JOIN catalog_sales cs ON cs.cs_item_sk = i.i_item_sk
   JOIN target_dates d ON d.d_date_sk = cs.cs_sold_date_sk), item_avg AS
  (SELECT cs_item_sk,
          AVG(cs_ext_discount_amt) AS avg_discount
   FROM filtered_sales
   GROUP BY cs_item_sk),
                                                             qualifying_sales AS
  (SELECT f.cs_ext_discount_amt
   FROM filtered_sales f
   JOIN item_avg a ON a.cs_item_sk = f.cs_item_sk
   AND f.cs_ext_discount_amt > 1.3 * a.avg_discount)
SELECT SUM(cs_ext_discount_amt) AS "excess discount amount"
FROM qualifying_sales
LIMIT 100;
