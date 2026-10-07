WITH main_store_profit AS MATERIALIZED
  (SELECT ss.ss_store_sk,
          sum(ss.ss_net_profit) AS profit
   FROM store_sales ss
   JOIN date_dim d ON d.d_date_sk = ss.ss_sold_date_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200+11
   GROUP BY ss.ss_store_sk), eligible_states AS MATERIALIZED
  (SELECT DISTINCT s.s_state
   FROM store_sales ss
   JOIN date_dim d ON d.d_date_sk = ss.ss_sold_date_sk
   JOIN store s ON s.s_store_sk = ss.ss_store_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200+11
     AND 1200+11 >= 1
     AND s.s_state IS NOT NULL)
SELECT sum(msp.profit) AS total_sum,
       s.s_state,
       s.s_county,
       grouping(s.s_state) + grouping(s.s_county) AS lochierarchy,
       rank() OVER (PARTITION BY grouping(s.s_state) + grouping(s.s_county), CASE
                                                                                 WHEN grouping(s.s_county) = 0 THEN s.s_state
                                                                             END
                    ORDER BY sum(msp.profit) DESC) AS rank_within_parent
FROM main_store_profit msp
JOIN store s ON s.s_store_sk = msp.ss_store_sk
WHERE EXISTS
    (SELECT 1
     FROM eligible_states e
     WHERE e.s_state = s.s_state)
GROUP BY ROLLUP (s.s_state,
                 s.s_county)
ORDER BY lochierarchy DESC,
         CASE
             WHEN grouping(s.s_state) + grouping(s.s_county) = 0 THEN s.s_state
         END,
         rank_within_parent
LIMIT 100;
