WITH date_keys AS MATERIALIZED
  (SELECT d_date_sk,
          d_date
   FROM date_dim
   WHERE d_date >= DATE '2000-02-10'
     AND d_date <= DATE '2000-04-10'), x AS
  (SELECT w.w_warehouse_name,
          i.i_item_id,
          sum(CASE
                  WHEN dk.d_date < DATE '2000-03-11' THEN inv.inv_quantity_on_hand
                  ELSE 0
              END) AS inv_before,
          sum(CASE
                  WHEN dk.d_date >= DATE '2000-03-11' THEN inv.inv_quantity_on_hand
                  ELSE 0
              END) AS inv_after
   FROM inventory inv
   JOIN date_keys dk ON dk.d_date_sk=inv.inv_date_sk
   JOIN item i ON i.i_item_sk=inv.inv_item_sk
   JOIN warehouse w ON w.w_warehouse_sk=inv.inv_warehouse_sk
   WHERE i.i_current_price >= 0.99
     AND i.i_current_price <= 1.49
   GROUP BY w.w_warehouse_name,
            i.i_item_id)
SELECT *
FROM x
WHERE CASE
          WHEN inv_before > 0 THEN (inv_after*1.000)/inv_before
          ELSE NULL
      END BETWEEN 2.000/3.000 AND 3.000/2.000
ORDER BY w_warehouse_name NULLS FIRST,
         i_item_id NULLS FIRST
LIMIT 100;
