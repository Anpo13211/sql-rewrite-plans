WITH store_dates AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_year = 2002
     AND d_moy BETWEEN 1 AND 1 + 3), web_dates AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_year = 2002
     AND d_moy BETWEEN 1 AND 1 + 3), catalog_dates AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_year = 2002
     AND d_moy BETWEEN 1 AND 1 + 3), store_customers AS MATERIALIZED
  (SELECT DISTINCT ss.ss_customer_sk AS customer_sk
   FROM store_sales ss
   JOIN store_dates d ON d.d_date_sk = ss.ss_sold_date_sk), online_customers AS MATERIALIZED
  (SELECT ws.ws_bill_customer_sk AS customer_sk
   FROM web_sales ws
   JOIN web_dates d ON d.d_date_sk = ws.ws_sold_date_sk
   UNION SELECT cs.cs_ship_customer_sk
   FROM catalog_sales cs
   JOIN catalog_dates d ON d.d_date_sk = cs.cs_sold_date_sk), eligible AS MATERIALIZED
  (SELECT c.c_current_cdemo_sk
   FROM customer c
   JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk SEMI
   JOIN store_customers s ON s.customer_sk = c.c_customer_sk SEMI
   JOIN online_customers o ON o.customer_sk = c.c_customer_sk
   WHERE ca.ca_county IN ('Rush County', 'Toole County', 'Jefferson County', 'Dona Ana County', 'La Porte County')), grouped AS
  (SELECT cd.cd_gender,
          cd.cd_marital_status,
          cd.cd_education_status,
          cd.cd_purchase_estimate,
          cd.cd_credit_rating,
          cd.cd_dep_count,
          cd.cd_dep_employed_count,
          cd.cd_dep_college_count,
          count(*) AS cnt
   FROM eligible e
   JOIN customer_demographics cd ON cd.cd_demo_sk = e.c_current_cdemo_sk
   GROUP BY cd.cd_gender,
            cd.cd_marital_status,
            cd.cd_education_status,
            cd.cd_purchase_estimate,
            cd.cd_credit_rating,
            cd.cd_dep_count,
            cd.cd_dep_employed_count,
            cd.cd_dep_college_count)
SELECT cd_gender,
       cd_marital_status,
       cd_education_status,
       cnt AS cnt1,
       cd_purchase_estimate,
       cnt AS cnt2,
       cd_credit_rating,
       cnt AS cnt3,
       cd_dep_count,
       cnt AS cnt4,
       cd_dep_employed_count,
       cnt AS cnt5,
       cd_dep_college_count,
       cnt AS cnt6
FROM grouped
ORDER BY cd_gender,
         cd_marital_status,
         cd_education_status,
         cd_purchase_estimate,
         cd_credit_rating,
         cd_dep_count,
         cd_dep_employed_count,
         cd_dep_college_count
LIMIT 100;
