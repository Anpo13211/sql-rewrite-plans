SELECT COUNT(DISTINCT ws.ws_order_number) AS "order count",
       SUM(ws.ws_ext_ship_cost) AS "total shipping cost",
       SUM(ws.ws_net_profit) AS "total net profit"
FROM web_sales ws
JOIN date_dim d ON d.d_date_sk = ws.ws_ship_date_sk
AND d.d_date BETWEEN '1999-02-01' AND DATE '1999-04-02'
JOIN customer_address ca ON ca.ca_address_sk = ws.ws_ship_addr_sk
AND ca.ca_state = 'IL'
JOIN web_site site ON site.web_site_sk = ws.ws_web_site_sk
AND site.web_company_name = 'pri'
WHERE EXISTS
    (SELECT 1
     FROM web_returns wr
     WHERE wr.wr_order_number = ws.ws_order_number)
  AND EXISTS
    (SELECT 1
     FROM web_sales ws2
     WHERE ws2.ws_order_number = ws.ws_order_number
       AND ws2.ws_warehouse_sk <> ws.ws_warehouse_sk)
LIMIT 100;
