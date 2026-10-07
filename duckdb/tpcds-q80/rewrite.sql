WITH d AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_date BETWEEN DATE '2000-08-23' AND DATE '2000-09-22'), i AS MATERIALIZED
  (SELECT i_item_sk
   FROM item
   WHERE i_current_price > 50), p AS MATERIALIZED
  (SELECT p_promo_sk
   FROM promotion
   WHERE p_channel_tv = 'N'), u AS
  (SELECT 'store channel' channel,
                          concat('store', s_store_id) id,
                          sum(ss_ext_sales_price) sales,
                          sum(coalesce(sr_return_amt, 0)) returns_,
                          sum(ss_net_profit-coalesce(sr_net_loss, 0)) profit
   FROM store_sales
   JOIN d ON d_date_sk=ss_sold_date_sk
   JOIN i ON i_item_sk=ss_item_sk
   JOIN p ON p_promo_sk=ss_promo_sk
   JOIN store ON s_store_sk=ss_store_sk
   LEFT JOIN store_returns ON sr_item_sk=ss_item_sk
   AND sr_ticket_number=ss_ticket_number
   GROUP BY s_store_id
   UNION ALL SELECT 'catalog channel',
                    concat('catalog_page', cp_catalog_page_id),
                    sum(cs_ext_sales_price),
                    sum(coalesce(cr_return_amount, 0)),
                    sum(cs_net_profit-coalesce(cr_net_loss, 0))
   FROM catalog_sales
   JOIN d ON d_date_sk=cs_sold_date_sk
   JOIN i ON i_item_sk=cs_item_sk
   JOIN p ON p_promo_sk=cs_promo_sk
   JOIN catalog_page ON cp_catalog_page_sk=cs_catalog_page_sk
   LEFT JOIN catalog_returns ON cr_item_sk=cs_item_sk
   AND cr_order_number=cs_order_number
   GROUP BY cp_catalog_page_id
   UNION ALL SELECT 'web channel',
                    concat('web_site', web_site_id),
                    sum(ws_ext_sales_price),
                    sum(coalesce(wr_return_amt, 0)),
                    sum(ws_net_profit-coalesce(wr_net_loss, 0))
   FROM web_sales
   JOIN d ON d_date_sk=ws_sold_date_sk
   JOIN i ON i_item_sk=ws_item_sk
   JOIN p ON p_promo_sk=ws_promo_sk
   JOIN web_site ON web_site_sk=ws_web_site_sk
   LEFT JOIN web_returns ON wr_item_sk=ws_item_sk
   AND wr_order_number=ws_order_number
   GROUP BY web_site_id)
SELECT channel,
       id,
       sum(sales) sales,
       sum(returns_) returns_,
       sum(profit) profit
FROM u
GROUP BY GROUPING
SETS ((channel,
       id),(channel),())
ORDER BY channel NULLS FIRST,
         id NULLS FIRST
LIMIT 100;
