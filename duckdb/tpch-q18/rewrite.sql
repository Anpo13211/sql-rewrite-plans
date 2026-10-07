WITH line_totals AS
  (SELECT l_orderkey,
          SUM(l_quantity) AS total_quantity
   FROM lineitem
   GROUP BY l_orderkey
   HAVING SUM(l_quantity) > 300)
SELECT c.c_name,
       c.c_custkey,
       o.o_orderkey,
       o.o_orderdate,
       o.o_totalprice,
       lt.total_quantity AS "sum(l_quantity)"
FROM line_totals lt
JOIN orders o ON o.o_orderkey = lt.l_orderkey
JOIN customer c ON c.c_custkey = o.o_custkey
ORDER BY o.o_totalprice DESC,
         o.o_orderdate
LIMIT 100;
