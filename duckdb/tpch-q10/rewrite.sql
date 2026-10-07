WITH revenue_by_customer AS
  (SELECT o.o_custkey AS c_custkey,
          SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
   FROM
     (SELECT o_orderkey,
             o_custkey
      FROM orders
      WHERE o_orderdate >= DATE '1993-10-01'
        AND o_orderdate < DATE '1994-01-01') o
   JOIN
     (SELECT l_orderkey,
             l_extendedprice,
             l_discount
      FROM lineitem
      WHERE l_returnflag = 'R') l ON l.l_orderkey = o.o_orderkey
   GROUP BY o.o_custkey)
SELECT c.c_custkey,
       c.c_name,
       r.revenue,
       c.c_acctbal,
       n.n_name,
       c.c_address,
       c.c_phone,
       c.c_comment
FROM revenue_by_customer r
JOIN customer c ON c.c_custkey = r.c_custkey
JOIN nation n ON n.n_nationkey = c.c_nationkey
ORDER BY r.revenue DESC
LIMIT 20;
