WITH matched AS
  (SELECT (t.t_hour BETWEEN 8 AND 8 + 1
           AND h.hd_dep_count = 6
           AND p.wp_char_count BETWEEN 5000 AND 5200) AS a_match,
          (t.t_hour BETWEEN 19 AND 19 + 1
           AND h.hd_dep_count = 6
           AND p.wp_char_count BETWEEN 5000 AND 5200) AS p_match
   FROM web_sales ws
   JOIN time_dim t ON t.t_time_sk = ws.ws_sold_time_sk
   JOIN household_demographics h ON h.hd_demo_sk = ws.ws_ship_hdemo_sk
   JOIN web_page p ON p.wp_web_page_sk = ws.ws_web_page_sk),
     counts AS
  (SELECT count(*) FILTER (
                           WHERE a_match) AS amc,
          count(*) FILTER (
                           WHERE p_match) AS pmc
   FROM matched
   WHERE a_match
     OR p_match)
SELECT CASE
           WHEN pmc = 0 THEN NULL
           ELSE amc::decimal(15, 4) / pmc::decimal(15, 4)
       END AS am_pm_ratio
FROM counts
LIMIT 100;
