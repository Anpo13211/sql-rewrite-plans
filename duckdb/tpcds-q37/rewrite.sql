WITH candidate_items AS MATERIALIZED
  (SELECT i_item_sk,
          i_item_id,
          i_item_desc,
          i_current_price
   FROM item
   WHERE i_current_price BETWEEN 68 AND 68 + 30
     AND i_manufact_id IN ('677', '940', '694', '808'))
SELECT DISTINCT i.i_item_id,
                i.i_item_desc,
                i.i_current_price
FROM candidate_items i
WHERE EXISTS
    (SELECT 1
     FROM inventory inv
     JOIN date_dim d ON d.d_date_sk = inv.inv_date_sk
     WHERE inv.inv_item_sk = i.i_item_sk
       AND inv.inv_quantity_on_hand BETWEEN 100 AND 500
       AND d.d_date BETWEEN CAST('2000-02-01' AS DATE) AND CAST('2000-04-01' AS DATE))
ORDER BY i.i_item_id
LIMIT 100;
