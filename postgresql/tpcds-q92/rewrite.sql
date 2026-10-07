WITH selected_items AS MATERIALIZED
  (SELECT i_item_sk
   FROM item
   WHERE i_manufact_id = 350), scored_sales AS
  (SELECT ws.ws_ext_discount_amt,
          avg(ws.ws_ext_discount_amt) OVER (PARTITION BY ws.ws_item_sk) AS avg_discount
   FROM selected_items i
   JOIN web_sales ws ON ws.ws_item_sk = i.i_item_sk
   JOIN date_dim d ON d.d_date_sk = ws.ws_sold_date_sk
   AND d.d_date BETWEEN '2000-01-27' AND cast('2000-04-26' AS date))
SELECT sum(ws_ext_discount_amt) FILTER (
                                        WHERE ws_ext_discount_amt > 1.3 * avg_discount) AS "Excess Discount Amount"
FROM scored_sales
LIMIT 100;
