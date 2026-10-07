WITH date_keys AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_month_seq BETWEEN GREATEST(1200, 0) AND LEAST(1200+11, 2400)
     AND d_date_sk BETWEEN 2450815 AND 2452635), item_qoh AS MATERIALIZED
  (SELECT inv.inv_item_sk,
          SUM(inv.inv_quantity_on_hand) AS quantity_sum,
          COUNT(inv.inv_quantity_on_hand) AS quantity_count
   FROM date_keys d
   JOIN inventory inv ON inv.inv_date_sk = d.d_date_sk
   GROUP BY inv.inv_item_sk)
SELECT i.i_product_name,
       i.i_brand,
       i.i_class,
       i.i_category,
       SUM(q.quantity_sum) / NULLIF(SUM(q.quantity_count), 0) AS qoh
FROM item_qoh q
JOIN item i ON i.i_item_sk = q.inv_item_sk
GROUP BY ROLLUP (i.i_product_name,
                 i.i_brand,
                 i.i_class,
                 i.i_category)
ORDER BY qoh NULLS FIRST,
         i.i_product_name NULLS FIRST,
         i.i_brand NULLS FIRST,
         i.i_class NULLS FIRST,
         i.i_category NULLS FIRST
LIMIT 100;
