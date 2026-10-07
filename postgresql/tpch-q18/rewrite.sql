SELECT c.c_name,
       c.c_custkey,
       o.o_orderkey,
       o.o_orderdate,
       o.o_totalprice,
       q.total_quantity AS SUM
FROM orders AS o
JOIN customer AS c ON c.c_custkey = o.o_custkey
CROSS JOIN LATERAL
  (SELECT SUM(l.l_quantity) AS total_quantity
   FROM lineitem AS l
   WHERE l.l_orderkey = o.o_orderkey) AS q
WHERE q.total_quantity > 300
ORDER BY o.o_totalprice DESC,
         o.o_orderdate
LIMIT 100;
