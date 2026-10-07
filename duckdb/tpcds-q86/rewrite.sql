WITH sales_by_item AS
  (SELECT ws.ws_item_sk,
          SUM(ws.ws_net_paid) AS item_total
   FROM web_sales AS ws
   JOIN
     (SELECT d_date_sk
      FROM date_dim
      WHERE d_month_seq BETWEEN 1200 AND 1200+11) AS d ON d.d_date_sk = ws.ws_sold_date_sk
   GROUP BY ws.ws_item_sk),
     base AS MATERIALIZED
  (SELECT i.i_category,
          i.i_class,
          SUM(s.item_total) AS total_sum
   FROM sales_by_item AS s
   JOIN item AS i ON i.i_item_sk = s.ws_item_sk
   GROUP BY i.i_category,
            i.i_class), levels AS
  (SELECT total_sum,
          i_category,
          i_class,
          0 AS lochierarchy
   FROM base
   UNION ALL SELECT SUM(total_sum),
                    i_category,
                    NULL::VARCHAR,
                    1
   FROM base
   GROUP BY i_category
   UNION ALL SELECT SUM(total_sum),
                    NULL::VARCHAR,
                    NULL::VARCHAR,
                    2
   FROM base),
                        ranked AS
  (SELECT total_sum,
          i_category,
          i_class,
          lochierarchy,
          RANK() OVER (PARTITION BY lochierarchy, CASE
                                                      WHEN lochierarchy = 0 THEN i_category
                                                  END
                       ORDER BY total_sum DESC) AS rank_within_parent
   FROM levels)
SELECT total_sum,
       i_category,
       i_class,
       lochierarchy,
       rank_within_parent
FROM ranked
ORDER BY lochierarchy DESC NULLS FIRST,
         CASE
             WHEN lochierarchy = 0 THEN i_category
         END NULLS FIRST, rank_within_parent NULLS FIRST
LIMIT 100;
