WITH filtered_dates AS MATERIALIZED
  (SELECT d_date_sk,
          d_year
   FROM date_dim
   WHERE d_moy = 11
     AND d_date_sk BETWEEN 2450816 AND 2452642)
SELECT d.d_year,
       i.i_brand_id AS brand_id,
       i.i_brand AS brand,
       SUM(s.ss_ext_sales_price) AS sum_agg
FROM filtered_dates d
JOIN store_sales s ON s.ss_sold_date_sk = d.d_date_sk
JOIN item i ON i.i_item_sk = s.ss_item_sk
WHERE i.i_manufact_id = 128
GROUP BY d.d_year,
         i.i_brand_id,
         i.i_brand
ORDER BY d.d_year,
         sum_agg DESC,
         brand_id
LIMIT 100;
