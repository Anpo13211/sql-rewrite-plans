WITH per_part AS
  (SELECT ps.ps_partkey,
          SUM(ps.ps_supplycost * ps.ps_availqty) AS value
   FROM partsupp AS ps
   WHERE ps.ps_suppkey IN
       (SELECT s.s_suppkey
        FROM supplier AS s
        WHERE s.s_nationkey =
            (SELECT n.n_nationkey
             FROM nation AS n
             WHERE n.n_name = 'GERMANY'))
   GROUP BY ps.ps_partkey)
SELECT ps_partkey,
       value
FROM
  (SELECT per_part.*,
          SUM(value) OVER () AS total_value
   FROM per_part) AS ranked
WHERE value > total_value * 0.0001000000
ORDER BY value DESC;
