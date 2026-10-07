WITH ss AS NOT MATERIALIZED
  (SELECT i.i_manufact_id,
          s.ss_ext_sales_price AS sales_price
   FROM date_dim d
   JOIN store_sales s ON s.ss_sold_date_sk = d.d_date_sk
   JOIN customer_address a ON a.ca_address_sk = s.ss_addr_sk
   JOIN item i ON i.i_item_sk = s.ss_item_sk
   WHERE d.d_year = 1998
     AND d.d_moy = 5
     AND a.ca_gmt_offset = -5
     AND i.i_manufact_id IN
       (SELECT i_manufact_id
        FROM item
        WHERE i_category IN ('Electronics'))), cs AS NOT MATERIALIZED
  (SELECT i.i_manufact_id,
          c.cs_ext_sales_price AS sales_price
   FROM date_dim d
   JOIN catalog_sales c ON c.cs_sold_date_sk = d.d_date_sk
   JOIN customer_address a ON a.ca_address_sk = c.cs_bill_addr_sk
   JOIN item i ON i.i_item_sk = c.cs_item_sk
   WHERE d.d_year = 1998
     AND d.d_moy = 5
     AND a.ca_gmt_offset = -5
     AND i.i_manufact_id IN
       (SELECT i_manufact_id
        FROM item
        WHERE i_category IN ('Electronics'))), ws AS NOT MATERIALIZED
  (SELECT i.i_manufact_id,
          w.ws_ext_sales_price AS sales_price
   FROM date_dim d
   JOIN web_sales w ON w.ws_sold_date_sk = d.d_date_sk
   JOIN customer_address a ON a.ca_address_sk = w.ws_bill_addr_sk
   JOIN item i ON i.i_item_sk = w.ws_item_sk
   WHERE d.d_year = 1998
     AND d.d_moy = 5
     AND a.ca_gmt_offset = -5
     AND i.i_manufact_id IN
       (SELECT i_manufact_id
        FROM item
        WHERE i_category IN ('Electronics')))
SELECT i_manufact_id,
       SUM(sales_price) AS total_sales
FROM
  (SELECT i_manufact_id,
          sales_price
   FROM ss
   UNION ALL SELECT i_manufact_id,
                    sales_price
   FROM cs
   UNION ALL SELECT i_manufact_id,
                    sales_price
   FROM ws) channel_rows
GROUP BY i_manufact_id
ORDER BY total_sales
LIMIT 100;
