WITH eligible_ids AS MATERIALIZED
  (SELECT DISTINCT i_item_id
   FROM item
   WHERE i_category = 'Music'), sales_items AS MATERIALIZED
  (SELECT i.i_item_sk,
          i.i_item_id
   FROM item i
   JOIN eligible_ids e USING (i_item_id)), valid_addresses AS MATERIALIZED
  (SELECT ca_address_sk
   FROM customer_address
   WHERE ca_gmt_offset = -5), date_bounds AS MATERIALIZED
  (SELECT min(d_date_sk) AS lo,
          max(d_date_sk) AS hi
   FROM date_dim
   WHERE d_year = 1998
     AND d_moy = 9), channel_sales(sold_date_sk, item_sk, address_sk, amount) AS
  (SELECT ss_sold_date_sk,
          ss_item_sk,
          ss_addr_sk,
          ss_ext_sales_price
   FROM store_sales
   UNION ALL SELECT cs_sold_date_sk,
                    cs_item_sk,
                    cs_bill_addr_sk,
                    cs_ext_sales_price
   FROM catalog_sales
   UNION ALL SELECT ws_sold_date_sk,
                    ws_item_sk,
                    ws_bill_addr_sk,
                    ws_ext_sales_price
   FROM web_sales)
SELECT i.i_item_id,
       sum(s.amount) AS total_sales
FROM date_bounds b
JOIN channel_sales s ON s.sold_date_sk BETWEEN b.lo AND b.hi
JOIN sales_items i ON i.i_item_sk = s.item_sk
JOIN valid_addresses a ON a.ca_address_sk = s.address_sk
GROUP BY i.i_item_id
ORDER BY i.i_item_id
LIMIT 100;
