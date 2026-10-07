WITH fi AS MATERIALIZED
  (SELECT i_item_sk,
          i_brand_id,
          i_class_id,
          i_category_id,
          i_manufact_id
   FROM item
   WHERE i_category='Books'),fd AS MATERIALIZED
  (SELECT d_date_sk,
          d_year
   FROM date_dim
   WHERE d_year IN (2002,2002-1)),cs AS MATERIALIZED
  (SELECT d_year,
          i_brand_id,
          i_class_id,
          i_category_id,
          i_manufact_id,
          cs_order_number,
          cs_item_sk,
          cs_quantity,
          cs_ext_sales_price
   FROM catalog_sales
   JOIN fi ON cs_item_sk=i_item_sk
   JOIN fd ON cs_sold_date_sk=d_date_sk),ss AS MATERIALIZED
  (SELECT d_year,
          i_brand_id,
          i_class_id,
          i_category_id,
          i_manufact_id,
          ss_ticket_number,
          ss_item_sk,
          ss_quantity,
          ss_ext_sales_price
   FROM store_sales
   JOIN fi ON ss_item_sk=i_item_sk
   JOIN fd ON ss_sold_date_sk=d_date_sk),ws AS MATERIALIZED
  (SELECT d_year,
          i_brand_id,
          i_class_id,
          i_category_id,
          i_manufact_id,
          ws_order_number,
          ws_item_sk,
          ws_quantity,
          ws_ext_sales_price
   FROM web_sales
   JOIN fi ON ws_item_sk=i_item_sk
   JOIN fd ON ws_sold_date_sk=d_date_sk),sales_detail AS
  (SELECT d_year,
          i_brand_id,
          i_class_id,
          i_category_id,
          i_manufact_id,
          cs_quantity-COALESCE(cr_return_quantity, 0) AS sales_cnt,
          cs_ext_sales_price-COALESCE(cr_return_amount, 0.0) AS sales_amt
   FROM cs
   LEFT JOIN catalog_returns ON cr_order_number=cs_order_number
   AND cr_item_sk=cs_item_sk
   UNION SELECT d_year,
                i_brand_id,
                i_class_id,
                i_category_id,
                i_manufact_id,
                ss_quantity-COALESCE(sr_return_quantity, 0),
                ss_ext_sales_price-COALESCE(sr_return_amt, 0.0)
   FROM ss
   LEFT JOIN store_returns ON sr_ticket_number=ss_ticket_number
   AND sr_item_sk=ss_item_sk
   UNION SELECT d_year,
                i_brand_id,
                i_class_id,
                i_category_id,
                i_manufact_id,
                ws_quantity-COALESCE(wr_return_quantity, 0),
                ws_ext_sales_price-COALESCE(wr_return_amt, 0.0)
   FROM ws
   LEFT JOIN web_returns ON wr_order_number=ws_order_number
   AND wr_item_sk=ws_item_sk),
                                         all_sales AS MATERIALIZED
  (SELECT d_year,
          i_brand_id,
          i_class_id,
          i_category_id,
          i_manufact_id,
          SUM(sales_cnt) AS sales_cnt,
          SUM(sales_amt) AS sales_amt
   FROM sales_detail
   GROUP BY ALL)
SELECT p.d_year AS prev_year,
       c.d_year AS year_,
       c.i_brand_id,
       c.i_class_id,
       c.i_category_id,
       c.i_manufact_id,
       p.sales_cnt AS prev_yr_cnt,
       c.sales_cnt AS curr_yr_cnt,
       c.sales_cnt-p.sales_cnt AS sales_cnt_diff,
       c.sales_amt-p.sales_amt AS sales_amt_diff
FROM all_sales c
JOIN all_sales p USING (i_brand_id,
                        i_class_id,
                        i_category_id,
                        i_manufact_id)
WHERE c.d_year=2002
  AND p.d_year=2002-1
  AND CAST(c.sales_cnt AS DECIMAL(17, 2))/CAST(p.sales_cnt AS DECIMAL(17, 2))<0.9
ORDER BY sales_cnt_diff,
         sales_amt_diff
LIMIT 100;
