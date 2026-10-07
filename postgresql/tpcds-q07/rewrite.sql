WITH filtered_sales AS MATERIALIZED
  (SELECT ss.ss_item_sk,
          ss.ss_quantity,
          ss.ss_list_price,
          ss.ss_coupon_amt,
          ss.ss_sales_price
   FROM store_sales ss
   JOIN date_dim d ON d.d_date_sk = ss.ss_sold_date_sk
   AND d.d_year = 2000
   JOIN customer_demographics cd ON cd.cd_demo_sk = ss.ss_cdemo_sk
   AND cd.cd_gender = 'M'
   AND cd.cd_marital_status = 'S'
   AND cd.cd_education_status = 'College'
   JOIN promotion p ON p.p_promo_sk = ss.ss_promo_sk
   AND (p.p_channel_email = 'N'
        OR p.p_channel_event = 'N'))
SELECT i.i_item_id,
       avg(fs.ss_quantity) AS agg1,
       avg(fs.ss_list_price) AS agg2,
       avg(fs.ss_coupon_amt) AS agg3,
       avg(fs.ss_sales_price) AS agg4
FROM filtered_sales fs
JOIN item i ON i.i_item_sk = fs.ss_item_sk
GROUP BY i.i_item_id
ORDER BY i.i_item_id
LIMIT 100;
