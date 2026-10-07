SELECT s.s_name,
       COUNT(*) AS numwait
FROM supplier s
JOIN lineitem l1 ON l1.l_suppkey = s.s_suppkey
JOIN orders o ON o.o_orderkey = l1.l_orderkey
AND o.o_orderstatus = 'F'
WHERE s.s_nationkey =
    (SELECT n.n_nationkey
     FROM nation n
     WHERE n.n_name = 'SAUDI ARABIA')
  AND l1.l_receiptdate > l1.l_commitdate
  AND EXISTS
    (SELECT 1
     FROM lineitem l2
     WHERE l2.l_orderkey = l1.l_orderkey
       AND l2.l_suppkey <> l1.l_suppkey)
  AND NOT EXISTS
    (SELECT 1
     FROM lineitem l3
     WHERE l3.l_orderkey = l1.l_orderkey
       AND l3.l_suppkey <> l1.l_suppkey
       AND l3.l_receiptdate > l3.l_commitdate)
GROUP BY s.s_name
ORDER BY numwait DESC,
         s.s_name
LIMIT 100;
