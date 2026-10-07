WITH dates AS MATERIALIZED
  (SELECT d_date_sk,
          d_year,
          d_qoy
   FROM date_dim), items AS MATERIALIZED
  (SELECT i_item_sk,
          i_category
   FROM item)
SELECT channel,
       col_name,
       d_year,
       d_qoy,
       i_category,
       sales_cnt,
       sales_amt
FROM
  (SELECT 'store' AS channel,
          'ss_store_sk' AS col_name,
          d.d_year,
          d.d_qoy,
          i.i_category,
          COUNT(*) AS sales_cnt,
          SUM(ss.ss_ext_sales_price) AS sales_amt
   FROM store_sales ss
   JOIN dates d ON d.d_date_sk = ss.ss_sold_date_sk
   JOIN items i ON i.i_item_sk = ss.ss_item_sk
   WHERE ss.ss_store_sk IS NULL
   GROUP BY d.d_year,
            d.d_qoy,
            i.i_category
   UNION ALL SELECT 'web' AS channel,
                    'ws_ship_customer_sk' AS col_name,
                    d.d_year,
                    d.d_qoy,
                    i.i_category,
                    COUNT(*) AS sales_cnt,
                    SUM(ws.ws_ext_sales_price) AS sales_amt
   FROM web_sales ws
   JOIN dates d ON d.d_date_sk = ws.ws_sold_date_sk
   JOIN items i ON i.i_item_sk = ws.ws_item_sk
   WHERE ws.ws_ship_customer_sk IS NULL
   GROUP BY d.d_year,
            d.d_qoy,
            i.i_category
   UNION ALL SELECT 'catalog' AS channel,
                    'cs_ship_addr_sk' AS col_name,
                    d.d_year,
                    d.d_qoy,
                    i.i_category,
                    COUNT(*) AS sales_cnt,
                    SUM(cs.cs_ext_sales_price) AS sales_amt
   FROM catalog_sales cs
   JOIN dates d ON d.d_date_sk = cs.cs_sold_date_sk
   JOIN items i ON i.i_item_sk = cs.cs_item_sk
   WHERE cs.cs_ship_addr_sk IS NULL
   GROUP BY d.d_year,
            d.d_qoy,
            i.i_category) q
ORDER BY channel NULLS FIRST,
         col_name NULLS FIRST,
         d_year NULLS FIRST,
         d_qoy NULLS FIRST,
         i_category NULLS FIRST
LIMIT 100;
