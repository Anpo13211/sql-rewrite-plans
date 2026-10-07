WITH store_customers AS MATERIALIZED
  (SELECT DISTINCT ss.ss_customer_sk AS customer_sk
   FROM store_sales ss
   JOIN date_dim d ON d.d_date_sk = ss.ss_sold_date_sk
   AND d.d_year = 2002
   AND d.d_qoy < 4), online_customers AS MATERIALIZED
  (SELECT ws.ws_bill_customer_sk AS customer_sk
   FROM web_sales ws
   JOIN date_dim d ON d.d_date_sk = ws.ws_sold_date_sk
   AND d.d_year = 2002
   AND d.d_qoy < 4
   UNION SELECT cs.cs_ship_customer_sk
   FROM catalog_sales cs
   JOIN date_dim d ON d.d_date_sk = cs.cs_sold_date_sk
   AND d.d_year = 2002
   AND d.d_qoy < 4), grouped AS MATERIALIZED
  (SELECT ca.ca_state,
          cd.cd_gender,
          cd.cd_marital_status,
          cd.cd_dep_count,
          cd.cd_dep_employed_count,
          cd.cd_dep_college_count,
          count(*) AS cnt
   FROM store_customers sc
   JOIN online_customers oc USING (customer_sk)
   JOIN customer c ON c.c_customer_sk = sc.customer_sk
   JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
   JOIN customer_demographics cd ON cd.cd_demo_sk = c.c_current_cdemo_sk
   GROUP BY ca.ca_state,
            cd.cd_gender,
            cd.cd_marital_status,
            cd.cd_dep_count,
            cd.cd_dep_employed_count,
            cd.cd_dep_college_count)
SELECT ca_state,
       cd_gender,
       cd_marital_status,
       cd_dep_count,
       cnt AS cnt1,
       cd_dep_count AS min1,
       cd_dep_count AS max1,
       cd_dep_count::numeric AS avg1,
       cd_dep_employed_count,
       cnt AS cnt2,
       cd_dep_employed_count AS min2,
       cd_dep_employed_count AS max2,
       cd_dep_employed_count::numeric AS avg2,
       cd_dep_college_count,
       cnt AS cnt3,
       cd_dep_college_count AS min3,
       cd_dep_college_count AS max3,
       cd_dep_college_count::numeric AS avg3
FROM grouped
ORDER BY ca_state NULLS FIRST,
         cd_gender NULLS FIRST,
         cd_marital_status NULLS FIRST,
         cd_dep_count NULLS FIRST,
         cd_dep_employed_count NULLS FIRST,
         cd_dep_college_count NULLS FIRST
LIMIT 100;
