WITH filtered_dates AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_year = 2001
     AND d_qoy = 2), eligible_addresses AS MATERIALIZED
  (SELECT ca_address_sk
   FROM customer_address
   WHERE SUBSTRING(ca_zip, 1, 5) IN ('85669',
                                     '86197',
                                     '88274',
                                     '83405',
                                     '86475',
                                     '85392',
                                     '85460',
                                     '80348',
                                     '81792')
     OR ca_state IN ('CA', 'WA', 'GA')), filtered_sales AS MATERIALIZED
  (SELECT cs.cs_bill_customer_sk,
          cs.cs_sales_price
   FROM catalog_sales cs
   JOIN filtered_dates d ON d.d_date_sk = cs.cs_sold_date_sk), sales_by_customer AS
  (SELECT fs.cs_bill_customer_sk,
          SUM(fs.cs_sales_price) AS all_sales,
          SUM(fs.cs_sales_price) FILTER (
                                         WHERE fs.cs_sales_price > 500) AS threshold_sales
   FROM filtered_sales fs
   GROUP BY fs.cs_bill_customer_sk)
SELECT ca.ca_zip,
       SUM(CASE
               WHEN ea.ca_address_sk IS NOT NULL THEN sbc.all_sales
               ELSE sbc.threshold_sales
           END)
FROM sales_by_customer sbc
JOIN customer c ON c.c_customer_sk = sbc.cs_bill_customer_sk
JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
LEFT JOIN eligible_addresses ea ON ea.ca_address_sk = ca.ca_address_sk
WHERE ea.ca_address_sk IS NOT NULL
  OR sbc.threshold_sales IS NOT NULL
GROUP BY ca.ca_zip
ORDER BY ca.ca_zip NULLS FIRST
LIMIT 100;
