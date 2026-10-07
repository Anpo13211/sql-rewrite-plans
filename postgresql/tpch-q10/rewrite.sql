WITH filtered_orders AS NOT MATERIALIZED
  (SELECT o.o_orderkey,
          o.o_custkey
   FROM orders AS o
   WHERE o.o_orderdate >= DATE '1993-10-01'
     AND o.o_orderdate < DATE '1994-01-01'), filtered_lineitem AS NOT MATERIALIZED
  (SELECT l.l_orderkey,
          l.l_extendedprice,
          l.l_discount
   FROM lineitem AS l
   WHERE l.l_returnflag = 'R'), customer_revenue AS
  (SELECT o.o_custkey,
          SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
   FROM filtered_orders AS o
   JOIN filtered_lineitem AS l ON l.l_orderkey = o.o_orderkey
   GROUP BY o.o_custkey)
SELECT c.c_custkey,
       c.c_name,
       r.revenue,
       c.c_acctbal,
       n.n_name,
       c.c_address,
       c.c_phone,
       c.c_comment
FROM customer_revenue AS r
JOIN customer AS c ON c.c_custkey = r.o_custkey
JOIN nation AS n ON n.n_nationkey = c.c_nationkey
ORDER BY r.revenue DESC
LIMIT 20;
