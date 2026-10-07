WITH filtered_sales AS MATERIALIZED
  (SELECT cs.cs_item_sk,
          cs.cs_ext_sales_price
   FROM catalog_sales cs
   WHERE cs.cs_sold_date_sk IN
       (SELECT d.d_date_sk
        FROM date_dim d
        WHERE d.d_date BETWEEN DATE '1999-02-22' AND DATE '1999-03-24')), grouped AS
  (SELECT i.i_item_id,
          i.i_item_desc,
          i.i_category,
          i.i_class,
          i.i_current_price,
          sum(fs.cs_ext_sales_price) AS itemrevenue
   FROM filtered_sales fs
   JOIN item i ON i.i_item_sk = fs.cs_item_sk
   WHERE i.i_category IN ('Sports', 'Books', 'Home')
   GROUP BY i.i_item_id,
            i.i_item_desc,
            i.i_category,
            i.i_class,
            i.i_current_price)
SELECT i_item_id,
       i_item_desc,
       i_category,
       i_class,
       i_current_price,
       itemrevenue,
       itemrevenue * 100.0000 / sum(itemrevenue) OVER (PARTITION BY i_class) AS revenueratio
FROM grouped
ORDER BY i_category NULLS FIRST,
         i_class NULLS FIRST,
         i_item_id NULLS FIRST,
         i_item_desc NULLS FIRST,
         revenueratio NULLS FIRST
LIMIT 100;
