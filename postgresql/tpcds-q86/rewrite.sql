WITH filtered_sales AS MATERIALIZED
  (SELECT ws.ws_item_sk,
          ws.ws_net_paid
   FROM date_dim d
   JOIN web_sales ws ON ws.ws_sold_date_sk = d.d_date_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200+11), item_paid AS
  (SELECT ws_item_sk,
          sum(ws_net_paid) AS total_sum
   FROM filtered_sales
   GROUP BY ws_item_sk),
                                             rollup_totals AS
  (SELECT sum(ip.total_sum) AS total_sum,
          i.i_category,
          i.i_class,
          grouping(i.i_category) + grouping(i.i_class) AS lochierarchy,
          grouping(i.i_class) AS class_grouping
   FROM item_paid ip
   JOIN item i ON i.i_item_sk = ip.ws_item_sk
   GROUP BY ROLLUP (i.i_category,
                    i.i_class))
SELECT total_sum,
       i_category,
       i_class,
       lochierarchy,
       rank() OVER (PARTITION BY lochierarchy, CASE
                                                   WHEN class_grouping = 0 THEN i_category
                                               END
                    ORDER BY total_sum DESC) AS rank_within_parent
FROM rollup_totals
ORDER BY lochierarchy DESC NULLS FIRST,
         CASE
             WHEN lochierarchy = 0 THEN i_category
         END NULLS FIRST, rank_within_parent NULLS FIRST
LIMIT 100;
