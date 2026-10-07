WITH tagged AS
  (SELECT ss_customer_sk AS customer_sk,
          ss_item_sk AS item_sk,
          CASE
              WHEN ss_item_sk IS NULL THEN 1
              ELSE 0
          END AS null_side,
          1 AS store_flag,
          0 AS catalog_flag
   FROM store_sales
   JOIN date_dim ON d_date_sk = ss_sold_date_sk
   WHERE d_month_seq BETWEEN 1200 AND 1200 + 11
     AND ss_customer_sk IS NOT NULL
   UNION ALL SELECT cs_bill_customer_sk AS customer_sk,
                    cs_item_sk AS item_sk,
                    CASE
                        WHEN cs_item_sk IS NULL THEN 2
                        ELSE 0
                    END AS null_side,
                    0 AS store_flag,
                    1 AS catalog_flag
   FROM catalog_sales
   JOIN date_dim ON d_date_sk = cs_sold_date_sk
   WHERE d_month_seq BETWEEN 1200 AND 1200 + 11
     AND cs_bill_customer_sk IS NOT NULL),
     pairs AS
  (SELECT customer_sk,
          item_sk,
          null_side,
          max(store_flag) AS store_flag,
          max(catalog_flag) AS catalog_flag
   FROM tagged
   GROUP BY customer_sk,
            item_sk,
            null_side)
SELECT sum(CASE
               WHEN store_flag = 1
                    AND catalog_flag = 0 THEN 1
               ELSE 0
           END) AS store_only,
       sum(CASE
               WHEN store_flag = 0
                    AND catalog_flag = 1 THEN 1
               ELSE 0
           END) AS catalog_only,
       sum(CASE
               WHEN store_flag = 1
                    AND catalog_flag = 1 THEN 1
               ELSE 0
           END) AS store_and_catalog
FROM pairs
LIMIT 100;
