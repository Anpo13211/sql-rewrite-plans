SELECT l.l_shipmode,
       COUNT(*) FILTER (
                        WHERE o.o_orderpriority IN ('1-URGENT', '2-HIGH')) AS high_line_count,
       COUNT(o.o_orderpriority) - COUNT(*) FILTER (
                                                   WHERE o.o_orderpriority IN ('1-URGENT', '2-HIGH')) AS low_line_count
FROM
  (SELECT l_orderkey,
          l_shipmode
   FROM lineitem
   WHERE l_receiptdate >= DATE '1994-01-01'
     AND l_receiptdate < DATE '1995-01-01'
     AND l_shipmode IN ('MAIL', 'SHIP')
     AND l_commitdate < l_receiptdate
     AND l_shipdate < l_commitdate) AS l
JOIN orders AS o ON o.o_orderkey = l.l_orderkey
GROUP BY l.l_shipmode
ORDER BY l.l_shipmode;
