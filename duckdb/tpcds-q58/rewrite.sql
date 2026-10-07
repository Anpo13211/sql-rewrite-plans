WITH week_keys AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_week_seq =
       (SELECT d_week_seq
        FROM date_dim
        WHERE d_date = '2000-01-03')), channel_item AS MATERIALIZED
  (SELECT 'ss' AS channel,
          s.ss_item_sk AS item_sk,
          sum(s.ss_ext_sales_price) AS revenue
   FROM store_sales s SEMI
   JOIN week_keys d ON d.d_date_sk = s.ss_sold_date_sk
   GROUP BY s.ss_item_sk
   UNION ALL SELECT 'cs',
                    c.cs_item_sk,
                    sum(c.cs_ext_sales_price)
   FROM catalog_sales c SEMI
   JOIN week_keys d ON d.d_date_sk = c.cs_sold_date_sk
   GROUP BY c.cs_item_sk
   UNION ALL SELECT 'ws',
                    w.ws_item_sk,
                    sum(w.ws_ext_sales_price)
   FROM web_sales w SEMI
   JOIN week_keys d ON d.d_date_sk = w.ws_sold_date_sk
   GROUP BY w.ws_item_sk), revenue AS
  (SELECT i.i_item_id AS item_id,
          sum(ci.revenue) FILTER (
                                  WHERE ci.channel = 'ss') AS ss_item_rev,
          sum(ci.revenue) FILTER (
                                  WHERE ci.channel = 'cs') AS cs_item_rev,
          sum(ci.revenue) FILTER (
                                  WHERE ci.channel = 'ws') AS ws_item_rev
   FROM channel_item ci
   JOIN item i ON i.i_item_sk = ci.item_sk
   GROUP BY i.i_item_id)
SELECT item_id,
       ss_item_rev,
       ss_item_rev / ((ss_item_rev + cs_item_rev + ws_item_rev) / 3) * 100 AS ss_dev,
       cs_item_rev,
       cs_item_rev / ((ss_item_rev + cs_item_rev + ws_item_rev) / 3) * 100 AS cs_dev,
       ws_item_rev,
       ws_item_rev / ((ss_item_rev + cs_item_rev + ws_item_rev) / 3) * 100 AS ws_dev,
       (ss_item_rev + cs_item_rev + ws_item_rev) / 3 AS average
FROM revenue
WHERE ss_item_rev BETWEEN 0.9 * cs_item_rev AND 1.1 * cs_item_rev
  AND ss_item_rev BETWEEN 0.9 * ws_item_rev AND 1.1 * ws_item_rev
  AND cs_item_rev BETWEEN 0.9 * ss_item_rev AND 1.1 * ss_item_rev
  AND cs_item_rev BETWEEN 0.9 * ws_item_rev AND 1.1 * ws_item_rev
  AND ws_item_rev BETWEEN 0.9 * ss_item_rev AND 1.1 * ss_item_rev
  AND ws_item_rev BETWEEN 0.9 * cs_item_rev AND 1.1 * cs_item_rev
ORDER BY item_id NULLS FIRST,
         ss_item_rev NULLS FIRST
LIMIT 100;
