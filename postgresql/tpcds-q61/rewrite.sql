WITH filtered_sales AS MATERIALIZED
  (SELECT ss.ss_customer_sk,
          ss.ss_item_sk,
          ss.ss_store_sk,
          ss.ss_promo_sk,
          ss.ss_ext_sales_price
   FROM date_dim d
   JOIN store_sales ss ON ss.ss_sold_date_sk = d.d_date_sk
   WHERE d.d_year = 1998
     AND d.d_moy = 11), filtered_promotions AS MATERIALIZED
  (SELECT p_promo_sk
   FROM promotion
   WHERE p_channel_dmail = 'Y'
     OR p_channel_email = 'Y'
     OR p_channel_tv = 'Y'), a AS
  (SELECT SUM(fs.ss_ext_sales_price) FILTER (
                                             WHERE fp.p_promo_sk IS NOT NULL) AS promotions,
          SUM(fs.ss_ext_sales_price) AS total
   FROM filtered_sales fs
   JOIN store s ON s.s_store_sk = fs.ss_store_sk
   AND s.s_gmt_offset = -5
   JOIN item i ON i.i_item_sk = fs.ss_item_sk
   AND i.i_category = 'Jewelry'
   JOIN customer c ON c.c_customer_sk = fs.ss_customer_sk
   JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
   AND ca.ca_gmt_offset = -5
   LEFT JOIN filtered_promotions fp ON fp.p_promo_sk = fs.ss_promo_sk)
SELECT promotions,
       total,
       CAST(promotions AS decimal(15, 4)) / CAST(total AS decimal(15, 4)) * 100
FROM a
LIMIT 100;
