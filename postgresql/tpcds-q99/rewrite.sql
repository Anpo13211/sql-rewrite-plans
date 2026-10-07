WITH filtered_sales AS MATERIALIZED
  (SELECT cs.cs_warehouse_sk,
          cs.cs_ship_mode_sk,
          cs.cs_call_center_sk,
          cs.cs_ship_date_sk - cs.cs_sold_date_sk AS ship_delay
   FROM date_dim d
   JOIN catalog_sales cs ON cs.cs_ship_date_sk = d.d_date_sk
   WHERE d.d_month_seq BETWEEN 1200 AND 1200 + 11), fact AS MATERIALIZED
  (SELECT cs_warehouse_sk,
          cs_ship_mode_sk,
          cs_call_center_sk,
          COUNT(*) FILTER (
                           WHERE ship_delay <= 30) AS c30,
          COUNT(*) FILTER (
                           WHERE ship_delay BETWEEN 31 AND 60) AS c60,
          COUNT(*) FILTER (
                           WHERE ship_delay BETWEEN 61 AND 90) AS c90,
          COUNT(*) FILTER (
                           WHERE ship_delay BETWEEN 91 AND 120) AS c120,
          COUNT(*) FILTER (
                           WHERE ship_delay > 120) AS c_over120
   FROM filtered_sales
   GROUP BY cs_warehouse_sk,
            cs_ship_mode_sk,
            cs_call_center_sk)
SELECT SUBSTRING(w.w_warehouse_name
                 FROM 1
                 FOR 20) AS w_substr,
       sm.sm_type,
       LOWER(cc.cc_name) AS cc_name_lower,
       SUM(f.c30) AS "30 days",
       SUM(f.c60) AS "31-60 days",
       SUM(f.c90) AS "61-90 days",
       SUM(f.c120) AS "91-120 days",
       SUM(f.c_over120) AS ">120 days"
FROM fact f
JOIN warehouse w ON w.w_warehouse_sk = f.cs_warehouse_sk
JOIN ship_mode sm ON sm.sm_ship_mode_sk = f.cs_ship_mode_sk
JOIN call_center cc ON cc.cc_call_center_sk = f.cs_call_center_sk
GROUP BY SUBSTRING(w.w_warehouse_name
                   FROM 1
                   FOR 20),
         sm.sm_type,
         cc.cc_name
ORDER BY w_substr NULLS FIRST,
         sm.sm_type NULLS FIRST,
         cc_name_lower NULLS FIRST
LIMIT 100;
