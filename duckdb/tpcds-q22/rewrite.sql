WITH date_bounds AS
  (SELECT MIN(d_date_sk) AS lo,
          MAX(d_date_sk) AS hi
   FROM date_dim
   WHERE d_month_seq BETWEEN 1200 AND 1200 + 11),
     item_dims AS
  (SELECT i_item_sk,
          i_product_name,
          i_brand,
          i_class,
          i_category
   FROM item),
     inv_by_item AS
  (SELECT inv.inv_item_sk,
          SUM(inv.inv_quantity_on_hand) AS qoh_sum,
          COUNT(inv.inv_quantity_on_hand) AS qoh_count
   FROM inventory AS inv
   JOIN date_bounds AS d ON inv.inv_date_sk BETWEEN GREATEST(d.lo, 2450815) AND LEAST(d.hi, 2452635)
   GROUP BY inv.inv_item_sk)
SELECT i.i_product_name,
       i.i_brand,
       i.i_class,
       i.i_category,
       SUM(v.qoh_sum) / NULLIF(SUM(v.qoh_count), 0) AS qoh
FROM inv_by_item AS v
JOIN item_dims AS i ON i.i_item_sk = v.inv_item_sk
GROUP BY ROLLUP(i.i_product_name, i.i_brand, i.i_class, i.i_category)
ORDER BY qoh NULLS FIRST,
         i.i_product_name NULLS FIRST,
         i.i_brand NULLS FIRST,
         i.i_class NULLS FIRST,
         i.i_category NULLS FIRST
LIMIT 100;
