WITH ss_keys AS NOT MATERIALIZED
  (SELECT i.i_item_sk,
          i.i_item_id
   FROM item i
   WHERE i.i_item_id IN
       (SELECT i_item_id
        FROM item
        WHERE i_color IN ('slate', 'blanched', 'burnished'))),cs_keys AS NOT MATERIALIZED
  (SELECT i.i_item_sk,
          i.i_item_id
   FROM item i
   WHERE i.i_item_id IN
       (SELECT i_item_id
        FROM item
        WHERE i_color IN ('slate', 'blanched', 'burnished'))),ws_keys AS NOT MATERIALIZED
  (SELECT i.i_item_sk,
          i.i_item_id
   FROM item i
   WHERE i.i_item_id IN
       (SELECT i_item_id
        FROM item
        WHERE i_color IN ('slate', 'blanched', 'burnished')))
SELECT x.i_item_id,
       SUM(x.sales_amount) AS total_sales
FROM
  (SELECT k.i_item_id,
          s.ss_ext_sales_price AS sales_amount
   FROM store_sales s
   JOIN ss_keys k ON k.i_item_sk=s.ss_item_sk
   WHERE s.ss_sold_date_sk IN
       (SELECT d_date_sk
        FROM date_dim
        WHERE d_year = 2001
          AND d_moy = 2)
     AND s.ss_addr_sk IN
       (SELECT ca_address_sk
        FROM customer_address
        WHERE ca_gmt_offset = -5)
   UNION ALL SELECT k.i_item_id,
                    s.cs_ext_sales_price
   FROM catalog_sales s
   JOIN cs_keys k ON k.i_item_sk=s.cs_item_sk
   WHERE s.cs_sold_date_sk IN
       (SELECT d_date_sk
        FROM date_dim
        WHERE d_year = 2001
          AND d_moy = 2)
     AND s.cs_bill_addr_sk IN
       (SELECT ca_address_sk
        FROM customer_address
        WHERE ca_gmt_offset = -5)
   UNION ALL SELECT k.i_item_id,
                    s.ws_ext_sales_price
   FROM web_sales s
   JOIN ws_keys k ON k.i_item_sk=s.ws_item_sk
   WHERE s.ws_sold_date_sk IN
       (SELECT d_date_sk
        FROM date_dim
        WHERE d_year = 2001
          AND d_moy = 2)
     AND s.ws_bill_addr_sk IN
       (SELECT ca_address_sk
        FROM customer_address
        WHERE ca_gmt_offset = -5)) x
GROUP BY x.i_item_id
ORDER BY total_sales NULLS FIRST,
         x.i_item_id NULLS FIRST
LIMIT 100;
