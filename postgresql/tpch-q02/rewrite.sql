SELECT s.s_acctbal,
       s.s_name,
       n.n_name,
       p.p_partkey,
       p.p_mfgr,
       s.s_address,
       s.s_phone,
       s.s_comment
FROM
  (SELECT p_partkey,
          p_mfgr
   FROM part
   WHERE p_size = 15
     AND p_type LIKE '%BRASS') p
JOIN LATERAL
  (SELECT MIN(ps2.ps_supplycost) AS min_supplycost
   FROM partsupp ps2
   JOIN supplier s2 ON s2.s_suppkey = ps2.ps_suppkey
   JOIN nation n2 ON n2.n_nationkey = s2.s_nationkey
   JOIN region r2 ON r2.r_regionkey = n2.n_regionkey
   AND r2.r_name = 'EUROPE'
   WHERE ps2.ps_partkey = p.p_partkey) mc ON TRUE
JOIN partsupp ps ON ps.ps_partkey = p.p_partkey
AND ps.ps_supplycost = mc.min_supplycost
JOIN supplier s ON s.s_suppkey = ps.ps_suppkey
JOIN nation n ON n.n_nationkey = s.s_nationkey
JOIN region r ON r.r_regionkey = n.n_regionkey
AND r.r_name = 'EUROPE'
ORDER BY s.s_acctbal DESC,
         n.n_name,
         s.s_name,
         p.p_partkey
LIMIT 100;
