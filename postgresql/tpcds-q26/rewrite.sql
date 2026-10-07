WITH filtered_sales AS MATERIALIZED
  (SELECT cs.cs_item_sk,
          cs.cs_quantity,
          cs.cs_list_price,
          cs.cs_coupon_amt,
          cs.cs_sales_price
   FROM date_dim d
   JOIN catalog_sales cs ON cs.cs_sold_date_sk = d.d_date_sk
   JOIN customer_demographics cd ON cd.cd_demo_sk = cs.cs_bill_cdemo_sk
   JOIN promotion p ON p.p_promo_sk = cs.cs_promo_sk
   WHERE d.d_year = 2000
     AND cd.cd_gender = 'M'
     AND cd.cd_marital_status = 'S'
     AND cd.cd_education_status = 'College'
     AND (p.p_channel_email = 'N'
          OR p.p_channel_event = 'N'))
SELECT i.i_item_id,
       avg(fs.cs_quantity) AS agg1,
       avg(fs.cs_list_price) AS agg2,
       avg(fs.cs_coupon_amt) AS agg3,
       avg(fs.cs_sales_price) AS agg4
FROM filtered_sales fs
JOIN item i ON i.i_item_sk = fs.cs_item_sk
GROUP BY i.i_item_id
ORDER BY i.i_item_id
LIMIT 100;
