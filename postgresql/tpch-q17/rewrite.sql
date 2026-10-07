SELECT sum(x.l_extendedprice) / 7.0 AS avg_yearly
FROM
  (SELECT l.l_extendedprice,
          l.l_quantity,
          avg(l.l_quantity) OVER (PARTITION BY l.l_partkey) AS avg_quantity
   FROM lineitem l
   WHERE EXISTS
       (SELECT 1
        FROM part p
        WHERE p.p_partkey = l.l_partkey
          AND p.p_brand = 'Brand#23'
          AND p.p_container = 'MED BOX')) x
WHERE x.l_quantity < 0.2 * x.avg_quantity;
