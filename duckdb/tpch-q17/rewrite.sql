WITH selected_parts AS MATERIALIZED
  (SELECT p_partkey
   FROM part
   WHERE p_brand = 'Brand#23'
     AND p_container = 'MED BOX'), relevant_lineitem AS MATERIALIZED
  (SELECT l.l_partkey,
          l.l_quantity,
          l.l_extendedprice
   FROM lineitem AS l
   JOIN selected_parts AS p ON p.p_partkey = l.l_partkey), part_averages AS
  (SELECT l_partkey,
          avg(l_quantity) AS avg_quantity
   FROM relevant_lineitem
   GROUP BY l_partkey)
SELECT sum(r.l_extendedprice) / 7.0 AS avg_yearly
FROM relevant_lineitem AS r
JOIN part_averages AS a ON a.l_partkey = r.l_partkey
WHERE r.l_quantity < 0.2 * a.avg_quantity;
