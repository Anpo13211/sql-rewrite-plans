WITH order_counts AS MATERIALIZED
  (SELECT o_custkey,
          COUNT(o_orderkey) AS c_count
   FROM orders
   WHERE o_comment NOT LIKE '%special%requests%'
   GROUP BY o_custkey), buckets AS
  (SELECT c_count,
          COUNT(*) AS custdist
   FROM order_counts
   GROUP BY c_count),
                        combined AS
  (SELECT c_count,
          custdist
   FROM buckets
   UNION ALL SELECT CAST(FALSE AS BIGINT) AS c_count,

     (SELECT COUNT(*)
      FROM customer) -
     (SELECT COUNT(*)
      FROM order_counts) AS custdist)
SELECT c_count,
       SUM(custdist) AS custdist
FROM combined
GROUP BY c_count
ORDER BY custdist DESC,
         c_count DESC;
