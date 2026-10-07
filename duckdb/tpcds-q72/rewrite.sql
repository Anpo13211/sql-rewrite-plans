WITH eligible_sales AS MATERIALIZED
  (SELECT cs.cs_item_sk,
          cs.cs_quantity,
          cs.cs_promo_sk,
          d1.d_week_seq
   FROM catalog_sales cs
   JOIN date_dim d1 ON d1.d_date_sk = cs.cs_sold_date_sk
   AND d1.d_year = 1999
   JOIN customer_demographics cd ON cd.cd_demo_sk = cs.cs_bill_cdemo_sk
   AND cd.cd_marital_status = 'D'
   JOIN household_demographics hd ON hd.hd_demo_sk = cs.cs_bill_hdemo_sk
   AND hd.hd_buy_potential = '>10000'
   WHERE cs.cs_ship_date_sk > cs.cs_sold_date_sk + 5)
SELECT i.i_item_desc,
       w.w_warehouse_name,
       es.d_week_seq,
       count_if(es.cs_promo_sk IS NULL) AS no_promo,
       count_if(es.cs_promo_sk IS NOT NULL) AS promo,
       count(*) AS total_cnt
FROM eligible_sales es
JOIN inventory inv ON inv.inv_item_sk = es.cs_item_sk
AND inv.inv_quantity_on_hand < es.cs_quantity
JOIN date_dim d2 ON d2.d_date_sk = inv.inv_date_sk
AND d2.d_week_seq = es.d_week_seq
JOIN item i ON i.i_item_sk = es.cs_item_sk
JOIN warehouse w ON w.w_warehouse_sk = inv.inv_warehouse_sk
GROUP BY i.i_item_desc,
         w.w_warehouse_name,
         es.d_week_seq
ORDER BY total_cnt DESC NULLS FIRST,
         i.i_item_desc NULLS FIRST,
         w.w_warehouse_name NULLS FIRST,
         es.d_week_seq NULLS FIRST
LIMIT 100;
