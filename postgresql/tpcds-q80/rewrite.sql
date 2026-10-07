WITH bounds AS MATERIALIZED
  (SELECT min(d_date_sk) AS lo,
          max(d_date_sk) AS hi
   FROM date_dim
   WHERE d_date BETWEEN DATE '2000-08-23' AND DATE '2000-09-22'), ssr AS
  (SELECT s.s_store_id AS store_id,
          sum(ss.ss_ext_sales_price) AS sales,
          sum(coalesce(sr.sr_return_amt, 0)) AS returns_,
          sum(ss.ss_net_profit - coalesce(sr.sr_net_loss, 0)) AS profit
   FROM bounds b
   JOIN store_sales ss ON ss.ss_sold_date_sk BETWEEN b.lo AND b.hi
   JOIN store s ON s.s_store_sk = ss.ss_store_sk
   LEFT JOIN store_returns sr ON sr.sr_item_sk = ss.ss_item_sk
   AND sr.sr_ticket_number = ss.ss_ticket_number
   WHERE EXISTS
       (SELECT 1
        FROM item i
        WHERE i.i_item_sk = ss.ss_item_sk
          AND i.i_current_price > 50)
     AND EXISTS
       (SELECT 1
        FROM promotion p
        WHERE p.p_promo_sk = ss.ss_promo_sk
          AND p.p_channel_tv = 'N')
   GROUP BY s.s_store_id),
                                                                  csr AS
  (SELECT cp.cp_catalog_page_id AS catalog_page_id,
          sum(cs.cs_ext_sales_price) AS sales,
          sum(coalesce(cr.cr_return_amount, 0)) AS returns_,
          sum(cs.cs_net_profit - coalesce(cr.cr_net_loss, 0)) AS profit
   FROM bounds b
   JOIN catalog_sales cs ON cs.cs_sold_date_sk BETWEEN b.lo AND b.hi
   JOIN catalog_page cp ON cp.cp_catalog_page_sk = cs.cs_catalog_page_sk
   LEFT JOIN catalog_returns cr ON cr.cr_item_sk = cs.cs_item_sk
   AND cr.cr_order_number = cs.cs_order_number
   WHERE EXISTS
       (SELECT 1
        FROM item i
        WHERE i.i_item_sk = cs.cs_item_sk
          AND i.i_current_price > 50)
     AND EXISTS
       (SELECT 1
        FROM promotion p
        WHERE p.p_promo_sk = cs.cs_promo_sk
          AND p.p_channel_tv = 'N')
   GROUP BY cp.cp_catalog_page_id),
                                                                  wsr AS
  (SELECT w.web_site_id,
          sum(ws.ws_ext_sales_price) AS sales,
          sum(coalesce(wr.wr_return_amt, 0)) AS returns_,
          sum(ws.ws_net_profit - coalesce(wr.wr_net_loss, 0)) AS profit
   FROM bounds b
   JOIN web_sales ws ON ws.ws_sold_date_sk BETWEEN b.lo AND b.hi
   JOIN web_site w ON w.web_site_sk = ws.ws_web_site_sk
   LEFT JOIN web_returns wr ON wr.wr_item_sk = ws.ws_item_sk
   AND wr.wr_order_number = ws.ws_order_number
   WHERE EXISTS
       (SELECT 1
        FROM item i
        WHERE i.i_item_sk = ws.ws_item_sk
          AND i.i_current_price > 50)
     AND EXISTS
       (SELECT 1
        FROM promotion p
        WHERE p.p_promo_sk = ws.ws_promo_sk
          AND p.p_channel_tv = 'N')
   GROUP BY w.web_site_id),
                                                                  channels AS
  (SELECT 'store channel' AS channel,
          concat('store', store_id) AS id,
          sales,
          returns_,
          profit
   FROM ssr
   UNION ALL SELECT 'catalog channel',
                    concat('catalog_page', catalog_page_id),
                    sales,
                    returns_,
                    profit
   FROM csr
   UNION ALL SELECT 'web channel',
                    concat('web_site', web_site_id),
                    sales,
                    returns_,
                    profit
   FROM wsr)
SELECT channel,
       id,
       sum(sales) AS sales,
       sum(returns_) AS returns_,
       sum(profit) AS profit
FROM channels
GROUP BY ROLLUP (channel,
                 id)
ORDER BY channel NULLS FIRST,
         id NULLS FIRST
LIMIT 100;
