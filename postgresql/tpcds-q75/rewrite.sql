WITH fi AS MATERIALIZED
  (SELECT i_item_sk,
          i_brand_id,
          i_class_id,
          i_category_id,
          i_manufact_id
   FROM item
   WHERE i_category='Books'), dy AS MATERIALIZED
  (SELECT d_date_sk,
          d_year
   FROM date_dim
   WHERE d_year IN (2002,2002-1)), RAW AS NOT MATERIALIZED
  (SELECT d.d_year,
          i.i_brand_id,
          i.i_class_id,
          i.i_category_id,
          i.i_manufact_id,
          cs.cs_quantity-COALESCE(cr.cr_return_quantity, 0) AS sales_cnt,
          cs.cs_ext_sales_price-COALESCE(cr.cr_return_amount, 0.0) AS sales_amt
   FROM dy d
   JOIN catalog_sales cs ON cs.cs_sold_date_sk=d.d_date_sk
   JOIN fi i ON i.i_item_sk=cs.cs_item_sk
   LEFT JOIN catalog_returns cr ON cr.cr_order_number=cs.cs_order_number
   AND cr.cr_item_sk=cs.cs_item_sk
   UNION ALL SELECT d.d_year,
                    i.i_brand_id,
                    i.i_class_id,
                    i.i_category_id,
                    i.i_manufact_id,
                    ss.ss_quantity-COALESCE(sr.sr_return_quantity, 0),
                    ss.ss_ext_sales_price-COALESCE(sr.sr_return_amt, 0.0)
   FROM dy d
   JOIN store_sales ss ON ss.ss_sold_date_sk=d.d_date_sk
   JOIN fi i ON i.i_item_sk=ss.ss_item_sk
   LEFT JOIN store_returns sr ON sr.sr_ticket_number=ss.ss_ticket_number
   AND sr.sr_item_sk=ss.ss_item_sk
   UNION ALL SELECT d.d_year,
                    i.i_brand_id,
                    i.i_class_id,
                    i.i_category_id,
                    i.i_manufact_id,
                    ws.ws_quantity-COALESCE(wr.wr_return_quantity, 0),
                    ws.ws_ext_sales_price-COALESCE(wr.wr_return_amt, 0.0)
   FROM dy d
   JOIN web_sales ws ON ws.ws_sold_date_sk=d.d_date_sk
   JOIN fi i ON i.i_item_sk=ws.ws_item_sk
   LEFT JOIN web_returns wr ON wr.wr_order_number=ws.ws_order_number
   AND wr.wr_item_sk=ws.ws_item_sk), a AS MATERIALIZED
  (SELECT d_year,
          i_brand_id,
          i_class_id,
          i_category_id,
          i_manufact_id,
          SUM(sales_cnt) AS sales_cnt,
          SUM(sales_amt) AS sales_amt
   FROM
     (SELECT d_year,
             i_brand_id,
             i_class_id,
             i_category_id,
             i_manufact_id,
             sales_cnt,
             sales_amt
      FROM RAW
      GROUP BY d_year,
               i_brand_id,
               i_class_id,
               i_category_id,
               i_manufact_id,
               sales_cnt,
               sales_amt) x
   GROUP BY d_year,
            i_brand_id,
            i_class_id,
            i_category_id,
            i_manufact_id), c AS
  (SELECT *
   FROM a
   WHERE d_year=2002),
                            p AS
  (SELECT *
   FROM a
   WHERE d_year=2002-1)
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
FROM c
JOIN p USING (i_brand_id,
              i_class_id,
              i_category_id,
              i_manufact_id)
WHERE CAST(c.sales_cnt AS DECIMAL(17, 2))/CAST(p.sales_cnt AS DECIMAL(17, 2))<0.9
ORDER BY sales_cnt_diff,
         sales_amt_diff
LIMIT 100;
