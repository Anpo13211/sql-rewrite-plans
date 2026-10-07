WITH item_rollup AS MATERIALIZED
  (SELECT CASE
              WHEN GROUPING(i.i_item_id) = 1 THEN NULL
              ELSE i.i_item_id
          END AS i_item_id,
          GROUPING(i.i_item_id)::integer AS item_group,
          AVG(ss.ss_quantity) AS agg1,
          AVG(ss.ss_list_price) AS agg2,
          AVG(ss.ss_coupon_amt) AS agg3,
          AVG(ss.ss_sales_price) AS agg4
   FROM store_sales ss
   JOIN date_dim d ON d.d_date_sk = ss.ss_sold_date_sk
   AND d.d_year = 2002
   JOIN customer_demographics cd ON cd.cd_demo_sk = ss.ss_cdemo_sk
   AND cd.cd_gender = 'M'
   AND cd.cd_marital_status = 'S'
   AND cd.cd_education_status = 'College'
   JOIN store s ON s.s_store_sk = ss.ss_store_sk
   AND s.s_state = 'TN'
   JOIN item i ON i.i_item_sk = ss.ss_item_sk
   GROUP BY GROUPING
   SETS ((i.i_item_id), ()))
SELECT r.i_item_id,
       x.s_state,
       x.g_state,
       r.agg1,
       r.agg2,
       r.agg3,
       r.agg4
FROM item_rollup r
CROSS JOIN LATERAL
  (SELECT 'TN'::varchar AS s_state,
          0 AS g_state
   WHERE r.item_group = 0
   UNION ALL SELECT NULL::varchar AS s_state,
                    1 AS g_state) x
ORDER BY r.i_item_id NULLS FIRST,
         x.s_state NULLS FIRST
LIMIT 100;
