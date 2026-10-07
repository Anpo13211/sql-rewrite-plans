WITH eligible_dates AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_date BETWEEN '2000-01-27' AND cast('2000-04-26' AS date)), eligible_items AS MATERIALIZED
  (SELECT i_item_sk
   FROM item
   WHERE i_manufact_id = 350), scoped AS MATERIALIZED
  (SELECT ws.ws_item_sk,
          ws.ws_ext_discount_amt
   FROM web_sales ws
   JOIN eligible_dates d ON d.d_date_sk = ws.ws_sold_date_sk
   JOIN eligible_items i ON i.i_item_sk = ws.ws_item_sk), item_avg AS
  (SELECT ws_item_sk,
          avg(ws_ext_discount_amt) AS avg_discount
   FROM scoped
   GROUP BY ws_item_sk)
SELECT sum(s.ws_ext_discount_amt) AS "Excess Discount Amount"
FROM scoped s
JOIN item_avg a ON a.ws_item_sk = s.ws_item_sk
AND s.ws_ext_discount_amt > 1.3 * a.avg_discount
LIMIT 100;
