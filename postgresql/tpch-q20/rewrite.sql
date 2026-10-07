WITH target_suppliers AS MATERIALIZED
  (SELECT s.s_suppkey,
          s.s_name,
          s.s_address
   FROM supplier s
   JOIN nation n ON n.n_nationkey = s.s_nationkey
   WHERE n.n_name = 'CANADA'), candidate_pairs AS MATERIALIZED
  (SELECT ps.ps_partkey,
          ps.ps_suppkey,
          MAX(ps.ps_availqty) AS ps_availqty
   FROM target_suppliers ts
   JOIN partsupp ps ON ps.ps_suppkey = ts.s_suppkey
   JOIN part p ON p.p_partkey = ps.ps_partkey
   AND p.p_name LIKE 'forest%'
   GROUP BY ps.ps_partkey,
            ps.ps_suppkey), qualifying_suppliers AS MATERIALIZED
  (SELECT DISTINCT q.ps_suppkey
   FROM
     (SELECT cp.ps_partkey,
             cp.ps_suppkey
      FROM candidate_pairs cp
      JOIN lineitem l ON l.l_partkey = cp.ps_partkey
      AND l.l_suppkey = cp.ps_suppkey
      AND l.l_shipdate >= DATE '1994-01-01'
      AND l.l_shipdate < DATE '1995-01-01'
      GROUP BY cp.ps_partkey,
               cp.ps_suppkey,
               cp.ps_availqty
      HAVING cp.ps_availqty > 0.5 * SUM(l.l_quantity)) q)
SELECT ts.s_name,
       ts.s_address
FROM target_suppliers ts
JOIN qualifying_suppliers qs ON qs.ps_suppkey = ts.s_suppkey
ORDER BY ts.s_name;
