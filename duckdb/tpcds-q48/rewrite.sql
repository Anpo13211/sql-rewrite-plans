SELECT SUM(ss.ss_quantity)
FROM store_sales AS ss
JOIN customer_demographics AS cd ON cd.cd_demo_sk = ss.ss_cdemo_sk
JOIN customer_address AS ca ON ca.ca_address_sk = ss.ss_addr_sk
WHERE ss.ss_sold_date_sk IN
    (SELECT d.d_date_sk
     FROM date_dim AS d
     WHERE d.d_year = 2000)
  AND ss.ss_store_sk IN
    (SELECT s.s_store_sk
     FROM store AS s)
  AND ((cd.cd_marital_status = 'M'
        AND cd.cd_education_status = '4 yr Degree'
        AND ss.ss_sales_price BETWEEN 100.00 AND 150.00)
       OR (cd.cd_marital_status = 'D'
           AND cd.cd_education_status = '2 yr Degree'
           AND ss.ss_sales_price BETWEEN 50.00 AND 100.00)
       OR (cd.cd_marital_status = 'S'
           AND cd.cd_education_status = 'College'
           AND ss.ss_sales_price BETWEEN 150.00 AND 200.00))
  AND ((ca.ca_country = 'United States'
        AND ca.ca_state IN ('CO', 'OH', 'TX')
        AND ss.ss_net_profit BETWEEN 0 AND 2000)
       OR (ca.ca_country = 'United States'
           AND ca.ca_state IN ('OR', 'MN', 'KY')
           AND ss.ss_net_profit BETWEEN 150 AND 3000)
       OR (ca.ca_country = 'United States'
           AND ca.ca_state IN ('VA', 'CA', 'MS')
           AND ss.ss_net_profit BETWEEN 50 AND 25000));
