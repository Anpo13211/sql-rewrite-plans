WITH dates1 AS MATERIALIZED
  (SELECT d_date_sk,
          d_moy
   FROM date_dim
   WHERE d_year = 2001
     AND d_moy = 1), dates2 AS MATERIALIZED
  (SELECT d_date_sk,
          d_moy
   FROM date_dim
   WHERE d_year = 2001
     AND d_moy = 1+1), month1 AS MATERIALIZED
  (SELECT inv.inv_warehouse_sk AS warehouse_sk,
          inv.inv_item_sk AS item_sk,
          MIN(d.d_moy) AS d_moy,
          STDDEV_SAMP(inv.inv_quantity_on_hand) * 1.000 AS stdev,
          AVG(inv.inv_quantity_on_hand) AS mean
   FROM dates1 d
   JOIN inventory inv ON inv.inv_date_sk = d.d_date_sk
   GROUP BY inv.inv_warehouse_sk,
            inv.inv_item_sk), month2 AS MATERIALIZED
  (SELECT inv.inv_warehouse_sk AS warehouse_sk,
          inv.inv_item_sk AS item_sk,
          MIN(d.d_moy) AS d_moy,
          STDDEV_SAMP(inv.inv_quantity_on_hand) * 1.000 AS stdev,
          AVG(inv.inv_quantity_on_hand) AS mean
   FROM dates2 d
   JOIN inventory inv ON inv.inv_date_sk = d.d_date_sk
   GROUP BY inv.inv_warehouse_sk,
            inv.inv_item_sk)
SELECT a.warehouse_sk AS wsk1,
       a.item_sk AS isk1,
       a.d_moy AS dmoy1,
       a.mean AS mean1,
       a.stdev / NULLIF(a.mean, 0) AS cov1,
       b.warehouse_sk,
       b.item_sk,
       b.d_moy,
       b.mean,
       b.stdev / NULLIF(b.mean, 0) AS cov
FROM month1 a
JOIN month2 b USING (warehouse_sk,
                     item_sk)
JOIN item i ON i.i_item_sk = a.item_sk
JOIN warehouse w ON w.w_warehouse_sk = a.warehouse_sk
WHERE CASE a.mean
          WHEN 0 THEN 0
          ELSE a.stdev / a.mean
      END > 1
  AND CASE b.mean
          WHEN 0 THEN 0
          ELSE b.stdev / b.mean
      END > 1
ORDER BY wsk1 NULLS FIRST,
         isk1 NULLS FIRST;
