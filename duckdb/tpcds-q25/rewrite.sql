WITH m AS
  (SELECT ss.ss_item_sk,
          ss.ss_store_sk,
          SUM(ss.ss_net_profit) AS store_sales_profit,
          SUM(sr.sr_net_loss) AS store_returns_loss,
          SUM(cs.cs_net_profit) AS catalog_sales_profit
   FROM
     (SELECT d_date_sk
      FROM date_dim
      WHERE d_date_sk BETWEEN 2450816 AND 2452642
        AND d_moy = 4
        AND d_year = 2001) d1
   JOIN store_sales ss ON ss.ss_sold_date_sk = d1.d_date_sk
   JOIN store_returns sr ON sr.sr_customer_sk = ss.ss_customer_sk
   AND sr.sr_item_sk = ss.ss_item_sk
   AND sr.sr_ticket_number = ss.ss_ticket_number
   JOIN
     (SELECT d_date_sk
      FROM date_dim
      WHERE d_date_sk BETWEEN 2450820 AND 2452822
        AND d_moy BETWEEN 4 AND 10
        AND d_year = 2001) d2 ON d2.d_date_sk = sr.sr_returned_date_sk
   JOIN catalog_sales cs ON cs.cs_bill_customer_sk = sr.sr_customer_sk
   AND cs.cs_item_sk = sr.sr_item_sk
   JOIN
     (SELECT d_date_sk
      FROM date_dim
      WHERE d_date_sk BETWEEN 2450815 AND 2452653
        AND d_moy BETWEEN 4 AND 10
        AND d_year = 2001) d3 ON d3.d_date_sk = cs.cs_sold_date_sk
   GROUP BY ss.ss_item_sk,
            ss.ss_store_sk)
SELECT i.i_item_id,
       i.i_item_desc,
       s.s_store_id,
       s.s_store_name,
       m.store_sales_profit,
       m.store_returns_loss,
       m.catalog_sales_profit
FROM m
JOIN item i ON i.i_item_sk = m.ss_item_sk
JOIN store s ON s.s_store_sk = m.ss_store_sk
ORDER BY i.i_item_id,
         i.i_item_desc,
         s.s_store_id,
         s.s_store_name
LIMIT 100;
