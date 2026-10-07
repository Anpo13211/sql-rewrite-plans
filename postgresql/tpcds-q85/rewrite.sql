SELECT SUBSTRING(r.r_reason_desc, 1, 20),
       AVG(ws.ws_quantity) AS avg1,
       AVG(wr.wr_refunded_cash) AS avg2,
       AVG(wr.wr_fee)
FROM web_sales ws
JOIN web_returns wr ON wr.wr_item_sk=ws.ws_item_sk
AND wr.wr_order_number=ws.ws_order_number
JOIN reason r ON r.r_reason_sk=wr.wr_reason_sk
WHERE EXISTS
    (SELECT 1
     FROM date_dim d
     WHERE d.d_date_sk=ws.ws_sold_date_sk
       AND d.d_year=2000)
  AND EXISTS
    (SELECT 1
     FROM web_page wp
     WHERE wp.wp_web_page_sk=ws.ws_web_page_sk)
  AND EXISTS
    (SELECT 1
     FROM customer_demographics cd1
     JOIN customer_demographics cd2 ON cd2.cd_demo_sk=wr.wr_returning_cdemo_sk
     AND cd2.cd_marital_status=cd1.cd_marital_status
     AND cd2.cd_education_status=cd1.cd_education_status
     WHERE cd1.cd_demo_sk=wr.wr_refunded_cdemo_sk
       AND ((cd1.cd_marital_status='M'
             AND cd1.cd_education_status='Advanced Degree'
             AND ws.ws_sales_price BETWEEN 100.00 AND 150.00)
            OR (cd1.cd_marital_status='S'
                AND cd1.cd_education_status='College'
                AND ws.ws_sales_price BETWEEN 50.00 AND 100.00)
            OR (cd1.cd_marital_status='W'
                AND cd1.cd_education_status='2 yr Degree'
                AND ws.ws_sales_price BETWEEN 150.00 AND 200.00)))
  AND EXISTS
    (SELECT 1
     FROM customer_address ca
     WHERE ca.ca_address_sk=wr.wr_refunded_addr_sk
       AND ((ca.ca_country='United States'
             AND ca.ca_state IN ('IN', 'OH', 'NJ')
             AND ws.ws_net_profit BETWEEN 100 AND 200)
            OR (ca.ca_country='United States'
                AND ca.ca_state IN ('WI', 'CT', 'KY')
                AND ws.ws_net_profit BETWEEN 150 AND 300)
            OR (ca.ca_country='United States'
                AND ca.ca_state IN ('LA', 'IA', 'AR')
                AND ws.ws_net_profit BETWEEN 50 AND 250)))
GROUP BY r.r_reason_desc
ORDER BY SUBSTRING(r.r_reason_desc,1,20),
         AVG(ws.ws_quantity),
         AVG(wr.wr_refunded_cash),
         AVG(wr.wr_fee)
LIMIT 100;
