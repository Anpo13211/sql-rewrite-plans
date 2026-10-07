WITH filtered_sales AS NOT MATERIALIZED
  (SELECT cs.cs_item_sk,
          cs.cs_quantity,
          cs.cs_list_price,
          cs.cs_coupon_amt,
          cs.cs_sales_price
   FROM catalog_sales cs SEMI
   JOIN
     (SELECT d_date_sk
      FROM date_dim
      WHERE d_year = 2000) d ON d.d_date_sk = cs.cs_sold_date_sk SEMI
   JOIN
     (SELECT cd_demo_sk
      FROM customer_demographics
      WHERE cd_gender = 'M'
        AND cd_marital_status = 'S'
        AND cd_education_status = 'College') cd ON cd.cd_demo_sk = cs.cs_bill_cdemo_sk SEMI
   JOIN
     (SELECT p_promo_sk
      FROM promotion
      WHERE p_channel_email = 'N'
        OR p_channel_event = 'N') p ON p.p_promo_sk = cs.cs_promo_sk)
SELECT i.i_item_id,
       AVG(s.cs_quantity) AS agg1,
       AVG(s.cs_list_price) AS agg2,
       AVG(s.cs_coupon_amt) AS agg3,
       AVG(s.cs_sales_price) AS agg4
FROM filtered_sales s
JOIN item i ON i.i_item_sk = s.cs_item_sk
GROUP BY i.i_item_id
ORDER BY i.i_item_id
LIMIT 100;
