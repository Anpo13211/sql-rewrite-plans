WITH filtered_items AS MATERIALIZED
  (SELECT i_item_sk,
          i_item_id,
          i_item_desc,
          i_current_price
   FROM item
   WHERE i_current_price BETWEEN 62 AND 62 + 30
     AND i_manufact_id IN ('129', '270', '821', '423')), date_keys AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_date BETWEEN DATE '2000-05-25' AND DATE '2000-07-24')
SELECT DISTINCT i.i_item_id,
                i.i_item_desc,
                i.i_current_price
FROM date_keys d
JOIN inventory inv ON inv.inv_date_sk = d.d_date_sk
JOIN filtered_items i ON i.i_item_sk = inv.inv_item_sk
WHERE inv.inv_quantity_on_hand BETWEEN 100 AND 500
ORDER BY i.i_item_id
LIMIT 100;
