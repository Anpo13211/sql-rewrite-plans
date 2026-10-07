WITH item_stats AS MATERIALIZED
  (SELECT ss_item_sk AS item_sk,
          AVG(ss_net_profit) AS rank_col,
          SUM(ss_net_profit) FILTER (
                                     WHERE ss_addr_sk IS NULL) AS addr_profit,
          COUNT(ss_net_profit) FILTER (
                                       WHERE ss_addr_sk IS NULL) AS addr_count
   FROM store_sales
   WHERE ss_store_sk = 4
   GROUP BY ss_item_sk), cutoff AS
  (SELECT SUM(addr_profit) / NULLIF(SUM(addr_count), 0) AS rank_col
   FROM item_stats),
                         qualified AS MATERIALIZED
  (SELECT s.item_sk,
          s.rank_col
   FROM item_stats s
   CROSS JOIN cutoff c
   WHERE s.rank_col > 0.9 * c.rank_col), ascending AS MATERIALIZED
  (SELECT item_sk,
          RANK() OVER (
                       ORDER BY rank_col ASC) AS rnk
   FROM qualified), descending AS MATERIALIZED
  (SELECT item_sk,
          RANK() OVER (
                       ORDER BY rank_col DESC) AS rnk
   FROM qualified)
SELECT a.rnk,
       i1.i_product_name AS best_performing,
       i2.i_product_name AS worst_performing
FROM ascending a
JOIN descending d ON d.rnk = a.rnk
AND d.rnk < 11
JOIN item i1 ON i1.i_item_sk = a.item_sk
JOIN item i2 ON i2.i_item_sk = d.item_sk
WHERE a.rnk < 11
ORDER BY a.rnk
LIMIT 100;
