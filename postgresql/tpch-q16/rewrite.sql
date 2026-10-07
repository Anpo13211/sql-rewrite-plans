WITH excluded_supplier AS MATERIALIZED
  (SELECT s.s_suppkey
   FROM supplier AS s
   WHERE s.s_comment LIKE '%Customer%Complaints%'), unique_suppliers AS
  (SELECT p.p_brand,
          p.p_type,
          p.p_size,
          ps.ps_suppkey
   FROM part AS p
   JOIN partsupp AS ps ON ps.ps_partkey = p.p_partkey
   WHERE p.p_brand <> 'Brand#45'
     AND p.p_type NOT LIKE 'MEDIUM POLISHED%'
     AND p.p_size IN (49, 14, 23, 45, 19, 3, 36, 9)
     AND NOT EXISTS
       (SELECT 1
        FROM excluded_supplier AS es
        WHERE es.s_suppkey = ps.ps_suppkey)
   GROUP BY p.p_brand,
            p.p_type,
            p.p_size,
            ps.ps_suppkey)
SELECT p_brand,
       p_type,
       p_size,
       count(*) AS supplier_cnt
FROM unique_suppliers
GROUP BY p_brand,
         p_type,
         p_size
ORDER BY supplier_cnt DESC,
         p_brand,
         p_type,
         p_size;
