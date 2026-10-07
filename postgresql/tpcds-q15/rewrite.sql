WITH sales_by_customer AS MATERIALIZED
  (SELECT cs.cs_bill_customer_sk,
          SUM(cs.cs_sales_price) AS all_sales,
          SUM(cs.cs_sales_price) FILTER (
                                         WHERE cs.cs_sales_price > 500) AS high_sales
   FROM date_dim d
   JOIN catalog_sales cs ON cs.cs_sold_date_sk = d.d_date_sk
   AND d.d_qoy = 2
   AND d.d_year = 2001
   GROUP BY cs.cs_bill_customer_sk)
SELECT ca.ca_zip,
       SUM(CASE
               WHEN SUBSTRING(ca.ca_zip, 1, 5) IN ('85669', '86197', '88274', '83405', '86475', '85392', '85460', '80348', '81792')
                    OR ca.ca_state IN ('CA', 'WA', 'GA') THEN s.all_sales
               ELSE s.high_sales
           END)
FROM sales_by_customer s
JOIN customer c ON c.c_customer_sk = s.cs_bill_customer_sk
JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
WHERE SUBSTRING(ca.ca_zip, 1, 5) IN ('85669',
                                     '86197',
                                     '88274',
                                     '83405',
                                     '86475',
                                     '85392',
                                     '85460',
                                     '80348',
                                     '81792')
  OR ca.ca_state IN ('CA', 'WA', 'GA')
  OR s.high_sales IS NOT NULL
GROUP BY ca.ca_zip
ORDER BY ca.ca_zip NULLS FIRST
LIMIT 100;
