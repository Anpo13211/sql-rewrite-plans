WITH web_sales_filtered AS NOT MATERIALIZED
  (SELECT ws_item_sk,
          ws_order_number,
          ws_quantity,
          ws_net_paid
   FROM web_sales
   WHERE ws_net_profit>1
     AND ws_net_paid>0
     AND ws_quantity>0
     AND ws_sold_date_sk IN
       (SELECT d_date_sk
        FROM date_dim
        WHERE d_year=2001
          AND d_moy=12)), catalog_sales_filtered AS NOT MATERIALIZED
  (SELECT cs_item_sk,
          cs_order_number,
          cs_quantity,
          cs_net_paid
   FROM catalog_sales
   WHERE cs_net_profit>1
     AND cs_net_paid>0
     AND cs_quantity>0
     AND cs_sold_date_sk IN
       (SELECT d_date_sk
        FROM date_dim
        WHERE d_year=2001
          AND d_moy=12)), store_sales_filtered AS NOT MATERIALIZED
  (SELECT ss_item_sk,
          ss_ticket_number,
          ss_quantity,
          ss_net_paid
   FROM store_sales
   WHERE ss_net_profit>1
     AND ss_net_paid>0
     AND ss_quantity>0
     AND ss_sold_date_sk IN
       (SELECT d_date_sk
        FROM date_dim
        WHERE d_year=2001
          AND d_moy=12)), base(channel, item, return_qty, sales_qty, return_amt, net_paid) AS
  (SELECT 'web',
          ws.ws_item_sk,
          COALESCE(wr.wr_return_quantity, 0),
          ws.ws_quantity,
          wr.wr_return_amt,
          ws.ws_net_paid
   FROM web_sales_filtered ws
   JOIN web_returns wr ON wr.wr_order_number=ws.ws_order_number
   AND wr.wr_item_sk=ws.ws_item_sk
   WHERE wr.wr_return_amt>10000
   UNION ALL SELECT 'catalog',
                    cs.cs_item_sk,
                    COALESCE(cr.cr_return_quantity, 0),
                    cs.cs_quantity,
                    cr.cr_return_amount,
                    cs.cs_net_paid
   FROM catalog_sales_filtered cs
   JOIN catalog_returns cr ON cr.cr_order_number=cs.cs_order_number
   AND cr.cr_item_sk=cs.cs_item_sk
   WHERE cr.cr_return_amount>10000
   UNION ALL SELECT 'store',
                    ss.ss_item_sk,
                    COALESCE(sr.sr_return_quantity, 0),
                    ss.ss_quantity,
                    sr.sr_return_amt,
                    ss.ss_net_paid
   FROM store_sales_filtered ss
   JOIN store_returns sr ON sr.sr_ticket_number=ss.ss_ticket_number
   AND sr.sr_item_sk=ss.ss_item_sk
   WHERE sr.sr_return_amt>10000),
                           ratios AS
  (SELECT channel,
          item,
          SUM(return_qty)::decimal(15, 4)/NULLIF(SUM(sales_qty)::decimal(15, 4), 0) return_ratio,
          SUM(return_amt)::decimal(15, 4)/NULLIF(SUM(net_paid)::decimal(15, 4), 0) currency_ratio
   FROM base
   GROUP BY channel,
            item),
                           ranked AS
  (SELECT channel,
          item,
          return_ratio,
          RANK() OVER (PARTITION BY channel
                       ORDER BY return_ratio) return_rank,
          RANK() OVER (PARTITION BY channel
                       ORDER BY currency_ratio) currency_rank
   FROM ratios)
SELECT channel,
       item,
       return_ratio,
       return_rank,
       currency_rank
FROM ranked
WHERE (channel='web'
       AND (return_rank<=10
            OR currency_rank<=10))
  OR (channel='catalog'
      AND (return_rank<=10
           OR currency_rank<=10))
  OR (channel='store'
      AND (return_rank<=10
           OR currency_rank<=10))
ORDER BY 1 NULLS FIRST,4 NULLS FIRST,5 NULLS FIRST,2 NULLS FIRST
LIMIT 100;
