SELECT 100.00 * COALESCE(SUM(l.l_extendedprice * (1 - l.l_discount)) FILTER (
                                                                             WHERE promo.p_partkey IS NOT NULL), 0::numeric) / SUM(l.l_extendedprice * (1 - l.l_discount)) AS promo_revenue
FROM lineitem AS l
LEFT JOIN
  (SELECT p_partkey
   FROM part
   WHERE p_type LIKE 'PROMO%') AS promo ON promo.p_partkey = l.l_partkey
WHERE l.l_shipdate >= DATE '1995-09-01'
  AND l.l_shipdate < DATE '1995-10-01';
