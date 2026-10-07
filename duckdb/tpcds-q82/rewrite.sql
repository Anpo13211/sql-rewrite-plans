WITH eligible_dates AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_date BETWEEN CAST('2000-05-25' AS DATE) AND CAST('2000-07-24' AS DATE)), eligible_items AS MATERIALIZED
  (SELECT i_item_sk,
          i_item_id,
          i_item_desc,
          i_current_price
   FROM item
   WHERE i_current_price BETWEEN 62 AND 62 + 30
     AND i_manufact_id IN ('129', '270', '821', '423'))
SELECT DISTINCT i.i_item_id,
                i.i_item_desc,
                i.i_current_price
FROM inventory AS inv
JOIN eligible_dates AS d ON d.d_date_sk = inv.inv_date_sk
JOIN eligible_items AS i ON i.i_item_sk = inv.inv_item_sk
WHERE inv.inv_quantity_on_hand BETWEEN 100 AND 500
ORDER BY i.i_item_id
LIMIT 100;
