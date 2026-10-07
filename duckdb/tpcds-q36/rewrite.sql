WITH filtered_sales AS MATERIALIZED
  (SELECT ss_item_sk,
          ss_net_profit,
          ss_ext_sales_price
   FROM store_sales
   WHERE ss_sold_date_sk IN
       (SELECT d_date_sk
        FROM date_dim
        WHERE d_year = 2001)
     AND ss_store_sk IN
       (SELECT s_store_sk
        FROM store
        WHERE s_state = 'TN')), ROLLUP AS
  (SELECT (SUM(f.ss_net_profit) * 1.0000) / SUM(f.ss_ext_sales_price) AS gross_margin,
          i.i_category,
          i.i_class,
          GROUPING(i.i_class) AS t_class,
          GROUPING(i.i_category) + GROUPING(i.i_class) AS lochierarchy
   FROM filtered_sales f
   JOIN item i ON i.i_item_sk = f.ss_item_sk
   GROUP BY GROUPING
   SETS ((i.i_category,
          i.i_class), (i.i_category), ()))
SELECT gross_margin,
       i_category,
       i_class,
       lochierarchy,
       RANK() OVER (PARTITION BY lochierarchy, CASE
                                                   WHEN t_class = 0 THEN i_category
                                               END
                    ORDER BY gross_margin ASC) AS rank_within_parent
FROM ROLLUP
ORDER BY lochierarchy DESC NULLS FIRST,
         CASE
             WHEN lochierarchy = 0 THEN i_category
         END NULLS FIRST, rank_within_parent NULLS FIRST
LIMIT 100;
