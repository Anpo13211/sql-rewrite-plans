WITH filtered_sales AS MATERIALIZED
  (SELECT ss.ss_item_sk,
          ss.ss_net_profit,
          ss.ss_ext_sales_price
   FROM date_dim d
   JOIN store_sales ss ON ss.ss_sold_date_sk=d.d_date_sk
   JOIN store s ON s.s_store_sk=ss.ss_store_sk
   WHERE d.d_year=2001
     AND s.s_state='TN'), agg AS
  (SELECT (SUM(f.ss_net_profit)*1.0000)/SUM(f.ss_ext_sales_price) AS gross_margin,
          i.i_category,
          i.i_class,
          GROUPING(i.i_category) AS t_category,
          GROUPING(i.i_class) AS t_class,
          GROUPING(i.i_category)+GROUPING(i.i_class) AS lochierarchy
   FROM filtered_sales f
   JOIN item i ON i.i_item_sk=f.ss_item_sk
   GROUP BY ROLLUP(i.i_category, i.i_class)),
                         ranked AS
  (SELECT gross_margin,
          i_category,
          i_class,
          lochierarchy,
          RANK() OVER (PARTITION BY lochierarchy, CASE
                                                      WHEN t_class=0 THEN i_category
                                                  END
                       ORDER BY gross_margin) AS rank_within_parent
   FROM agg)
SELECT gross_margin,
       i_category,
       i_class,
       lochierarchy,
       rank_within_parent
FROM ranked
ORDER BY lochierarchy DESC NULLS FIRST,
         CASE
             WHEN lochierarchy=0 THEN i_category
         END NULLS FIRST,rank_within_parent NULLS FIRST
LIMIT 100;
