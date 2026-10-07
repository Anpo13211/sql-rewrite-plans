WITH week_dates AS MATERIALIZED
  (SELECT d.d_date_sk
   FROM date_dim AS target
   JOIN date_dim AS d ON d.d_week_seq = target.d_week_seq
   WHERE target.d_date = '2000-01-03'), channel_rows AS
  (SELECT ss.ss_item_sk AS item_sk,
          1 AS channel_id,
          ss.ss_ext_sales_price AS revenue
   FROM week_dates AS wd
   JOIN store_sales AS ss ON ss.ss_sold_date_sk = wd.d_date_sk
   UNION ALL SELECT cs.cs_item_sk,
                    2,
                    cs.cs_ext_sales_price
   FROM week_dates AS wd
   JOIN catalog_sales AS cs ON cs.cs_sold_date_sk = wd.d_date_sk
   UNION ALL SELECT ws.ws_item_sk,
                    3,
                    ws.ws_ext_sales_price
   FROM week_dates AS wd
   JOIN web_sales AS ws ON ws.ws_sold_date_sk = wd.d_date_sk),
                               item_revenue AS
  (SELECT i.i_item_id AS item_id,
          SUM(r.revenue) FILTER (
                                 WHERE r.channel_id = 1) AS ss_item_rev,
          SUM(r.revenue) FILTER (
                                 WHERE r.channel_id = 2) AS cs_item_rev,
          SUM(r.revenue) FILTER (
                                 WHERE r.channel_id = 3) AS ws_item_rev
   FROM channel_rows AS r
   JOIN item AS i ON i.i_item_sk = r.item_sk
   GROUP BY i.i_item_id
   HAVING COUNT(*) FILTER (
                           WHERE r.channel_id = 1) > 0
   AND COUNT(*) FILTER (
                        WHERE r.channel_id = 2) > 0
   AND COUNT(*) FILTER (
                        WHERE r.channel_id = 3) > 0)
SELECT item_id,
       ss_item_rev,
       ss_item_rev / ((ss_item_rev + cs_item_rev + ws_item_rev) / 3) * 100 AS ss_dev,
       cs_item_rev,
       cs_item_rev / ((ss_item_rev + cs_item_rev + ws_item_rev) / 3) * 100 AS cs_dev,
       ws_item_rev,
       ws_item_rev / ((ss_item_rev + cs_item_rev + ws_item_rev) / 3) * 100 AS ws_dev,
       (ss_item_rev + cs_item_rev + ws_item_rev) / 3 AS average
FROM item_revenue
WHERE ss_item_rev BETWEEN 0.9 * cs_item_rev AND 1.1 * cs_item_rev
  AND ss_item_rev BETWEEN 0.9 * ws_item_rev AND 1.1 * ws_item_rev
  AND cs_item_rev BETWEEN 0.9 * ss_item_rev AND 1.1 * ss_item_rev
  AND cs_item_rev BETWEEN 0.9 * ws_item_rev AND 1.1 * ws_item_rev
  AND ws_item_rev BETWEEN 0.9 * ss_item_rev AND 1.1 * ss_item_rev
  AND ws_item_rev BETWEEN 0.9 * cs_item_rev AND 1.1 * cs_item_rev
ORDER BY item_id NULLS FIRST,
         ss_item_rev NULLS FIRST
LIMIT 100;
