WITH fact_rollup AS MATERIALIZED
  (SELECT ws.ws_warehouse_sk,
          ws.ws_ship_mode_sk,
          ws.ws_web_site_sk,
          count(*) FILTER (
                           WHERE ws.ws_ship_date_sk - ws.ws_sold_date_sk <= 30) AS c30,
          count(*) FILTER (
                           WHERE ws.ws_ship_date_sk - ws.ws_sold_date_sk BETWEEN 31 AND 60) AS c31_60,
          count(*) FILTER (
                           WHERE ws.ws_ship_date_sk - ws.ws_sold_date_sk BETWEEN 61 AND 90) AS c61_90,
          count(*) FILTER (
                           WHERE ws.ws_ship_date_sk - ws.ws_sold_date_sk BETWEEN 91 AND 120) AS c91_120,
          count(*) FILTER (
                           WHERE ws.ws_ship_date_sk - ws.ws_sold_date_sk > 120) AS c120_plus
   FROM web_sales ws
   JOIN
     (SELECT d_date_sk
      FROM date_dim
      WHERE d_month_seq BETWEEN 1200 AND 1200+11) d ON d.d_date_sk = ws.ws_ship_date_sk
   GROUP BY ws.ws_warehouse_sk,
            ws.ws_ship_mode_sk,
            ws.ws_web_site_sk)
SELECT substring(w.w_warehouse_name
                 FROM 1
                 FOR 20) AS w_substr,
       sm.sm_type,
       web.web_name,
       sum(fr.c30) AS "30 days",
       sum(fr.c31_60) AS "31-60 days",
       sum(fr.c61_90) AS "61-90 days",
       sum(fr.c91_120) AS "91-120 days",
       sum(fr.c120_plus) AS ">120 days"
FROM fact_rollup fr
JOIN warehouse w ON w.w_warehouse_sk = fr.ws_warehouse_sk
JOIN ship_mode sm ON sm.sm_ship_mode_sk = fr.ws_ship_mode_sk
JOIN web_site web ON web.web_site_sk = fr.ws_web_site_sk
GROUP BY substring(w.w_warehouse_name
                   FROM 1
                   FOR 20),
         sm.sm_type,
         web.web_name
ORDER BY 1 NULLS FIRST, 2 NULLS FIRST, 3 NULLS FIRST
LIMIT 100;
