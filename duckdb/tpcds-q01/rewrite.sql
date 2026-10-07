WITH totals AS MATERIALIZED
  (SELECT sr.sr_customer_sk,
          sr.sr_store_sk,
          SUM(sr.sr_return_amt) AS total_return
   FROM store_returns AS sr
   JOIN date_dim AS d ON d.d_date_sk = sr.sr_returned_date_sk
   AND d.d_year = 2000
   JOIN store AS s ON s.s_store_sk = sr.sr_store_sk
   AND s.s_state = 'TN'
   GROUP BY sr.sr_customer_sk,
            sr.sr_store_sk), thresholds AS
  (SELECT sr_store_sk,
          1.2 * AVG(total_return) AS threshold
   FROM totals
   GROUP BY sr_store_sk)
SELECT c.c_customer_id
FROM totals AS t
JOIN thresholds AS h ON h.sr_store_sk = t.sr_store_sk
AND t.total_return > h.threshold
JOIN customer AS c ON c.c_customer_sk = t.sr_customer_sk
ORDER BY c.c_customer_id
LIMIT 100;
