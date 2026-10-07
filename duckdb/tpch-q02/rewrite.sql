WITH target_parts AS MATERIALIZED
  (SELECT p_partkey,
          p_mfgr
   FROM part
   WHERE p_size = 15
     AND p_type LIKE '%BRASS'), eligible_supply AS MATERIALIZED
  (SELECT tp.p_partkey,
          tp.p_mfgr,
          ps.ps_suppkey,
          ps.ps_supplycost
   FROM target_parts tp
   JOIN partsupp ps ON ps.ps_partkey = tp.p_partkey), outer_suppliers AS MATERIALIZED
  (SELECT s.s_suppkey,
          s.s_acctbal,
          s.s_name,
          s.s_address,
          s.s_phone,
          s.s_comment,
          n.n_name
   FROM supplier s
   JOIN nation n ON n.n_nationkey = s.s_nationkey
   JOIN region r ON r.r_regionkey = n.n_regionkey
   WHERE r.r_name = 'EUROPE'), inner_suppliers AS MATERIALIZED
  (SELECT s.s_suppkey
   FROM supplier s
   JOIN nation n ON n.n_nationkey = s.s_nationkey
   JOIN region r ON r.r_regionkey = n.n_regionkey
   WHERE r.r_name = 'EUROPE'), minimum_cost AS
  (SELECT es.p_partkey,
          MIN(es.ps_supplycost) AS min_supplycost
   FROM eligible_supply es
   JOIN inner_suppliers i ON i.s_suppkey = es.ps_suppkey
   GROUP BY es.p_partkey)
SELECT o.s_acctbal,
       o.s_name,
       o.n_name,
       es.p_partkey,
       es.p_mfgr,
       o.s_address,
       o.s_phone,
       o.s_comment
FROM eligible_supply es
JOIN outer_suppliers o ON o.s_suppkey = es.ps_suppkey
JOIN minimum_cost m ON m.p_partkey = es.p_partkey
AND m.min_supplycost = es.ps_supplycost
ORDER BY o.s_acctbal DESC,
         o.n_name,
         o.s_name,
         es.p_partkey
LIMIT 100;
