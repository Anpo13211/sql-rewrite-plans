WITH filtered_orders AS NOT MATERIALIZED
  (SELECT o.o_orderkey,
          o.o_custkey
   FROM orders o
   WHERE o.o_orderdate >= CAST('1994-01-01' AS date)
     AND o.o_orderdate < CAST('1995-01-01' AS date))
SELECT n.n_name,
       SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM region r
JOIN nation n ON n.n_regionkey = r.r_regionkey
JOIN supplier s ON s.s_nationkey = n.n_nationkey
JOIN lineitem l ON l.l_suppkey = s.s_suppkey
JOIN filtered_orders o ON o.o_orderkey = l.l_orderkey
JOIN customer c ON c.c_custkey = o.o_custkey
AND c.c_nationkey = n.n_nationkey
WHERE r.r_name = 'ASIA'
GROUP BY n.n_nationkey,
         n.n_name
ORDER BY revenue DESC;
