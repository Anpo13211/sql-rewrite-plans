SELECT w.w_state,
       i.i_item_id,
       SUM(CASE
               WHEN d.d_date < DATE '2000-03-11' THEN cs.cs_sales_price - COALESCE(cr.cr_refunded_cash, 0)
               ELSE 0
           END) AS sales_before,
       SUM(CASE
               WHEN d.d_date >= DATE '2000-03-11' THEN cs.cs_sales_price - COALESCE(cr.cr_refunded_cash, 0)
               ELSE 0
           END) AS sales_after
FROM catalog_sales cs
JOIN date_dim d ON d.d_date_sk = cs.cs_sold_date_sk
JOIN item i ON i.i_item_sk = cs.cs_item_sk
JOIN warehouse w ON w.w_warehouse_sk = cs.cs_warehouse_sk
LEFT JOIN catalog_returns cr ON cr.cr_order_number = cs.cs_order_number
AND cr.cr_item_sk = cs.cs_item_sk
WHERE d.d_date BETWEEN DATE '2000-02-10' AND DATE '2000-04-10'
  AND i.i_current_price BETWEEN 0.99 AND 1.49
GROUP BY w.w_state,
         i.i_item_id
ORDER BY w.w_state,
         i.i_item_id
LIMIT 100;
