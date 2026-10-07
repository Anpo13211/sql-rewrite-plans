SELECT sum(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM lineitem AS l
WHERE (l.l_quantity BETWEEN 1 AND 1+10
       AND l.l_shipmode IN ('AIR', 'AIR REG')
       AND l.l_shipinstruct = 'DELIVER IN PERSON'
       AND l.l_partkey IN
         (SELECT p_partkey
          FROM part
          WHERE p_brand = 'Brand#12'
            AND p_container IN ('SM CASE', 'SM BOX', 'SM PACK', 'SM PKG')
            AND p_size BETWEEN 1 AND 5))
  OR (l.l_quantity BETWEEN 10 AND 10+10
      AND l.l_shipmode IN ('AIR', 'AIR REG')
      AND l.l_shipinstruct = 'DELIVER IN PERSON'
      AND l.l_partkey IN
        (SELECT p_partkey
         FROM part
         WHERE p_brand = 'Brand#23'
           AND p_container IN ('MED BAG', 'MED BOX', 'MED PKG', 'MED PACK')
           AND p_size BETWEEN 1 AND 10))
  OR (l.l_quantity BETWEEN 20 AND 20+10
      AND l.l_shipmode IN ('AIR', 'AIR REG')
      AND l.l_shipinstruct = 'DELIVER IN PERSON'
      AND l.l_partkey IN
        (SELECT p_partkey
         FROM part
         WHERE p_brand = 'Brand#34'
           AND p_container IN ('LG CASE', 'LG BOX', 'LG PACK', 'LG PKG')
           AND p_size BETWEEN 1 AND 15));
