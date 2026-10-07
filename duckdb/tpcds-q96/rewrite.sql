SELECT count(*)
FROM store_sales AS ss SEMI
JOIN
  (SELECT t_time_sk
   FROM time_dim
   WHERE t_hour = 20
     AND t_minute >= 30) AS td ON td.t_time_sk = ss.ss_sold_time_sk SEMI
JOIN
  (SELECT hd_demo_sk
   FROM household_demographics
   WHERE hd_dep_count = 7) AS hd ON hd.hd_demo_sk = ss.ss_hdemo_sk SEMI
JOIN
  (SELECT s_store_sk
   FROM store
   WHERE s_store_name = 'ese') AS s ON s.s_store_sk = ss.ss_store_sk
LIMIT 100;
