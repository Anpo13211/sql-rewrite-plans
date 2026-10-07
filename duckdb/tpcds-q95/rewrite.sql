WITH filtered_sales AS MATERIALIZED
  (SELECT ws.ws_order_number,
          ws.ws_ext_ship_cost,
          ws.ws_net_profit
   FROM web_sales ws
   JOIN date_dim d ON d.d_date_sk = ws.ws_ship_date_sk
   JOIN customer_address ca ON ca.ca_address_sk = ws.ws_ship_addr_sk
   JOIN web_site site ON site.web_site_sk = ws.ws_web_site_sk
   WHERE d.d_date BETWEEN '1999-02-01' AND CAST('1999-04-02' AS DATE)
     AND ca.ca_state = 'IL'
     AND site.web_company_name = 'pri'), returned_candidates AS MATERIALIZED
  (SELECT DISTINCT wr.wr_order_number
   FROM web_returns wr SEMI
   JOIN filtered_sales fs ON fs.ws_order_number = wr.wr_order_number), eligible_orders AS MATERIALIZED
  (SELECT ws.ws_order_number
   FROM web_sales ws SEMI
   JOIN returned_candidates rc ON rc.wr_order_number = ws.ws_order_number
   GROUP BY ws.ws_order_number
   HAVING MIN(ws.ws_warehouse_sk) <> MAX(ws.ws_warehouse_sk)), order_totals AS
  (SELECT fs.ws_order_number,
          SUM(fs.ws_ext_ship_cost) AS ship_cost,
          SUM(fs.ws_net_profit) AS net_profit
   FROM filtered_sales fs SEMI
   JOIN eligible_orders eo ON eo.ws_order_number = fs.ws_order_number
   GROUP BY fs.ws_order_number)
SELECT COUNT(*) AS "order count",
       SUM(ship_cost) AS "total shipping cost",
       SUM(net_profit) AS "total net profit"
FROM order_totals
LIMIT 100;
