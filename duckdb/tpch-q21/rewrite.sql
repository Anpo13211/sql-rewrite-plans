WITH target_suppliers AS MATERIALIZED
  (SELECT s.s_suppkey,
          s.s_name
   FROM supplier s
   JOIN nation n ON n.n_nationkey = s.s_nationkey
   WHERE n.n_name = 'SAUDI ARABIA'), candidate_orders AS MATERIALIZED
  (SELECT l.l_orderkey
   FROM lineitem l
   JOIN orders o ON o.o_orderkey = l.l_orderkey
   JOIN target_suppliers ts ON ts.s_suppkey = l.l_suppkey
   WHERE o.o_orderstatus = 'F'
     AND l.l_receiptdate > l.l_commitdate
   GROUP BY l.l_orderkey), stats AS
  (SELECT l.l_orderkey,
          MIN(l.l_suppkey) AS all_min,
          MAX(l.l_suppkey) AS all_max,
          MIN(l.l_suppkey) FILTER (
                                   WHERE l.l_receiptdate > l.l_commitdate) AS late_suppkey,
          MAX(l.l_suppkey) FILTER (
                                   WHERE l.l_receiptdate > l.l_commitdate) AS late_max,
          COUNT(*) FILTER (
                           WHERE l.l_receiptdate > l.l_commitdate) AS late_count
   FROM lineitem l
   JOIN candidate_orders c ON c.l_orderkey = l.l_orderkey
   GROUP BY l.l_orderkey
   HAVING MIN(l.l_suppkey) <> MAX(l.l_suppkey)
   AND MIN(l.l_suppkey) FILTER (
                                WHERE l.l_receiptdate > l.l_commitdate) = MAX(l.l_suppkey) FILTER (
                                                                                                   WHERE l.l_receiptdate > l.l_commitdate))
SELECT ts.s_name,
       SUM(st.late_count) AS numwait
FROM stats st
JOIN target_suppliers ts ON ts.s_suppkey = st.late_suppkey
GROUP BY ts.s_name
ORDER BY numwait DESC,
         ts.s_name
LIMIT 100;
