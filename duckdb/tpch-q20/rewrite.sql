WITH target_suppliers AS MATERIALIZED
  (SELECT s.s_suppkey,
          s.s_name,
          s.s_address
   FROM nation n
   JOIN supplier s ON s.s_nationkey = n.n_nationkey
   WHERE n.n_name = 'CANADA'), matching_parts AS MATERIALIZED
  (SELECT p_partkey
   FROM part
   WHERE p_name LIKE 'forest%'), candidate_partsupp AS MATERIALIZED
  (SELECT DISTINCT ps.ps_suppkey,
                   ps.ps_partkey,
                   ps.ps_availqty
   FROM partsupp ps
   JOIN matching_parts p ON p.p_partkey = ps.ps_partkey
   JOIN target_suppliers s ON s.s_suppkey = ps.ps_suppkey), eligible_suppliers AS MATERIALIZED
  (SELECT cps.ps_suppkey
   FROM candidate_partsupp cps
   JOIN lineitem l ON l.l_partkey = cps.ps_partkey
   AND l.l_suppkey = cps.ps_suppkey
   WHERE l.l_shipdate >= DATE '1994-01-01'
     AND l.l_shipdate < DATE '1995-01-01'
   GROUP BY cps.ps_suppkey,
            cps.ps_partkey,
            cps.ps_availqty
   HAVING cps.ps_availqty > 0.5 * SUM(l.l_quantity))
SELECT s.s_name,
       s.s_address
FROM target_suppliers s SEMI
JOIN eligible_suppliers e ON e.ps_suppkey = s.s_suppkey
ORDER BY s.s_name;
