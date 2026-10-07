WITH store_buyers AS MATERIALIZED
  (SELECT DISTINCT ss.ss_customer_sk AS customer_sk
   FROM date_dim d
   JOIN store_sales ss ON ss.ss_sold_date_sk = d.d_date_sk
   WHERE d.d_year = 2001
     AND d.d_moy BETWEEN 4 AND 4 + 2), web_buyers AS MATERIALIZED
  (SELECT DISTINCT ws.ws_bill_customer_sk AS customer_sk
   FROM date_dim d
   JOIN web_sales ws ON ws.ws_sold_date_sk = d.d_date_sk
   WHERE d.d_year = 2001
     AND d.d_moy BETWEEN 4 AND 4 + 2), catalog_buyers AS MATERIALIZED
  (SELECT DISTINCT cs.cs_ship_customer_sk AS customer_sk
   FROM date_dim d
   JOIN catalog_sales cs ON cs.cs_sold_date_sk = d.d_date_sk
   WHERE d.d_year = 2001
     AND d.d_moy BETWEEN 4 AND 4 + 2), eligible AS MATERIALIZED
  (SELECT customer_sk
   FROM store_buyers
   EXCEPT SELECT customer_sk
   FROM web_buyers
   EXCEPT SELECT customer_sk
   FROM catalog_buyers), grouped AS
  (SELECT cd.cd_gender,
          cd.cd_marital_status,
          cd.cd_education_status,
          cd.cd_purchase_estimate,
          cd.cd_credit_rating,
          COUNT(*) AS cnt
   FROM eligible e
   JOIN customer c ON c.c_customer_sk = e.customer_sk
   JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
   JOIN customer_demographics cd ON cd.cd_demo_sk = c.c_current_cdemo_sk
   WHERE ca.ca_state IN ('KY', 'GA', 'NM')
   GROUP BY cd.cd_gender,
            cd.cd_marital_status,
            cd.cd_education_status,
            cd.cd_purchase_estimate,
            cd.cd_credit_rating)
SELECT cd_gender,
       cd_marital_status,
       cd_education_status,
       cnt AS cnt1,
       cd_purchase_estimate,
       cnt AS cnt2,
       cd_credit_rating,
       cnt AS cnt3
FROM grouped
ORDER BY cd_gender,
         cd_marital_status,
         cd_education_status,
         cd_purchase_estimate,
         cd_credit_rating
LIMIT 100;
