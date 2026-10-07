WITH selected_items AS MATERIALIZED
  (SELECT i_item_sk
   FROM item
   WHERE i_manufact_id = 977), date_bounds AS MATERIALIZED
  (SELECT min(d_date_sk) AS lo,
          max(d_date_sk) AS hi
   FROM date_dim
   WHERE d_date BETWEEN '2000-01-27' AND CAST('2000-04-26' AS date)), qualified AS
  (SELECT cs.cs_ext_discount_amt,
          avg(cs.cs_ext_discount_amt) OVER (PARTITION BY cs.cs_item_sk) AS item_avg
   FROM catalog_sales cs
   JOIN selected_items i ON i.i_item_sk = cs.cs_item_sk
   CROSS JOIN date_bounds b
   WHERE cs.cs_sold_date_sk BETWEEN b.lo AND b.hi)
SELECT sum(cs_ext_discount_amt) AS "excess discount amount"
FROM qualified
WHERE cs_ext_discount_amt > 1.3 * item_avg
LIMIT 100;
