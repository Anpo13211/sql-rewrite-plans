WITH candidates AS MATERIALIZED
  (SELECT c.c_customer_sk,
          c.c_current_cdemo_sk
   FROM customer c
   JOIN customer_address ca ON ca.ca_address_sk=c.c_current_addr_sk
   WHERE ca.ca_county IN ('Rush County', 'Toole County', 'Jefferson County', 'Dona Ana County', 'La Porte County'))
SELECT cd.cd_gender,
       cd.cd_marital_status,
       cd.cd_education_status,
       COUNT(*) AS cnt1,
       cd.cd_purchase_estimate,
       COUNT(*) AS cnt2,
       cd.cd_credit_rating,
       COUNT(*) AS cnt3,
       cd.cd_dep_count,
       COUNT(*) AS cnt4,
       cd.cd_dep_employed_count,
       COUNT(*) AS cnt5,
       cd.cd_dep_college_count,
       COUNT(*) AS cnt6
FROM candidates c
JOIN customer_demographics cd ON cd.cd_demo_sk=c.c_current_cdemo_sk
WHERE EXISTS
    (SELECT 1
     FROM store_sales ss
     JOIN date_dim d ON d.d_date_sk=ss.ss_sold_date_sk
     WHERE ss.ss_customer_sk=c.c_customer_sk
       AND d.d_year = 2002
       AND d.d_moy BETWEEN 1 AND 1 + 3)
  AND EXISTS
    (SELECT 1
     FROM
       (SELECT ws.ws_bill_customer_sk AS customer_sk
        FROM web_sales ws
        JOIN date_dim d ON d.d_date_sk=ws.ws_sold_date_sk
        WHERE ws.ws_bill_customer_sk=c.c_customer_sk
          AND d.d_year = 2002
          AND d.d_moy BETWEEN 1 AND 1 + 3
        UNION ALL SELECT cs.cs_ship_customer_sk
        FROM catalog_sales cs
        JOIN date_dim d ON d.d_date_sk=cs.cs_sold_date_sk
        WHERE cs.cs_ship_customer_sk=c.c_customer_sk
          AND d.d_year = 2002
          AND d.d_moy BETWEEN 1 AND 1 + 3) channel_sales)
GROUP BY cd.cd_gender,
         cd.cd_marital_status,
         cd.cd_education_status,
         cd.cd_purchase_estimate,
         cd.cd_credit_rating,
         cd.cd_dep_count,
         cd.cd_dep_employed_count,
         cd.cd_dep_college_count
ORDER BY cd.cd_gender,
         cd.cd_marital_status,
         cd.cd_education_status,
         cd.cd_purchase_estimate,
         cd.cd_credit_rating,
         cd.cd_dep_count,
         cd.cd_dep_employed_count,
         cd.cd_dep_college_count
LIMIT 100;
