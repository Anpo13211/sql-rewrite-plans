WITH ss AS MATERIALIZED
  (SELECT s.ss_customer_sk,
          s.ss_item_sk,
          s.ss_ticket_number,
          s.ss_store_sk,
          s.ss_net_profit
   FROM store_sales s
   JOIN date_dim d ON d.d_date_sk = s.ss_sold_date_sk
   WHERE d.d_moy = 4
     AND d.d_year = 2001), sr AS MATERIALIZED
  (SELECT r.sr_customer_sk,
          r.sr_item_sk,
          r.sr_ticket_number,
          r.sr_net_loss
   FROM store_returns r
   JOIN date_dim d ON d.d_date_sk = r.sr_returned_date_sk
   WHERE d.d_moy BETWEEN 4 AND 10
     AND d.d_year = 2001), cs AS MATERIALIZED
  (SELECT c.cs_bill_customer_sk,
          c.cs_item_sk,
          c.cs_net_profit
   FROM catalog_sales c
   JOIN date_dim d ON d.d_date_sk = c.cs_sold_date_sk
   WHERE d.d_moy BETWEEN 4 AND 10
     AND d.d_year = 2001)
SELECT i.i_item_id,
       i.i_item_desc,
       st.s_store_id,
       st.s_store_name,
       sum(ss.ss_net_profit) AS store_sales_profit,
       sum(sr.sr_net_loss) AS store_returns_loss,
       sum(cs.cs_net_profit) AS catalog_sales_profit
FROM ss
JOIN sr ON sr.sr_customer_sk = ss.ss_customer_sk
AND sr.sr_item_sk = ss.ss_item_sk
AND sr.sr_ticket_number = ss.ss_ticket_number
JOIN cs ON cs.cs_bill_customer_sk = sr.sr_customer_sk
AND cs.cs_item_sk = sr.sr_item_sk
JOIN item i ON i.i_item_sk = ss.ss_item_sk
JOIN store st ON st.s_store_sk = ss.ss_store_sk
GROUP BY i.i_item_id,
         i.i_item_desc,
         st.s_store_id,
         st.s_store_name
ORDER BY i.i_item_id,
         i.i_item_desc,
         st.s_store_id,
         st.s_store_name
LIMIT 100;
