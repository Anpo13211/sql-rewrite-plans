WITH store_buyers AS
  (SELECT ss.ss_customer_sk AS customer_sk
   FROM store_sales ss
   JOIN date_dim d ON d.d_date_sk = ss.ss_sold_date_sk
   WHERE d.d_year = 2002
     AND d.d_qoy < 4
   GROUP BY ss.ss_customer_sk),
     other_buyers AS
  (SELECT customer_sk
   FROM
     (SELECT ws.ws_bill_customer_sk AS customer_sk
      FROM web_sales ws
      JOIN date_dim d ON d.d_date_sk = ws.ws_sold_date_sk
      WHERE d.d_year = 2002
        AND d.d_qoy < 4
      UNION ALL SELECT cs.cs_ship_customer_sk
      FROM catalog_sales cs
      JOIN date_dim d ON d.d_date_sk = cs.cs_sold_date_sk
      WHERE d.d_year = 2002
        AND d.d_qoy < 4) u
   GROUP BY customer_sk),
     eligible AS
  (SELECT s.customer_sk
   FROM store_buyers s
   JOIN other_buyers o ON o.customer_sk = s.customer_sk),
     grouped AS
  (SELECT ca.ca_state,
          demo.cd_gender,
          demo.cd_marital_status,
          demo.cd_dep_count,
          demo.cd_dep_employed_count,
          demo.cd_dep_college_count,
          COUNT(*) AS cnt
   FROM customer c
   JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
   JOIN customer_demographics demo ON demo.cd_demo_sk = c.c_current_cdemo_sk
   WHERE c.c_customer_sk IN
       (SELECT customer_sk
        FROM eligible)
   GROUP BY ca.ca_state,
            demo.cd_gender,
            demo.cd_marital_status,
            demo.cd_dep_count,
            demo.cd_dep_employed_count,
            demo.cd_dep_college_count)
SELECT ca_state,
       cd_gender,
       cd_marital_status,
       cd_dep_count,
       cnt AS cnt1,
       cd_dep_count AS min1,
       cd_dep_count AS max1,
       CAST(cd_dep_count AS DOUBLE) AS avg1,
       cd_dep_employed_count,
       cnt AS cnt2,
       cd_dep_employed_count AS min2,
       cd_dep_employed_count AS max2,
       CAST(cd_dep_employed_count AS DOUBLE) AS avg2,
       cd_dep_college_count,
       cnt AS cnt3,
       cd_dep_college_count AS min3,
       cd_dep_college_count AS max3,
       CAST(cd_dep_college_count AS DOUBLE) AS avg3
FROM grouped
ORDER BY ca_state NULLS FIRST,
         cd_gender NULLS FIRST,
         cd_marital_status NULLS FIRST,
         cd_dep_count NULLS FIRST,
         cd_dep_employed_count NULLS FIRST,
         cd_dep_college_count NULLS FIRST
LIMIT 100;
