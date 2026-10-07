SELECT pc.c_count,
       count(*) AS custdist
FROM
  (SELECT c.c_custkey,
          count(o.o_orderkey) FILTER (
                                      WHERE o.o_comment NOT LIKE '%special%requests%') AS c_count
   FROM customer AS c
   LEFT JOIN orders AS o ON o.o_custkey = c.c_custkey
   GROUP BY c.c_custkey) AS pc
GROUP BY pc.c_count
ORDER BY custdist DESC,
         pc.c_count DESC;
