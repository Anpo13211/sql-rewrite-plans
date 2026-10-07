WITH q1 AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_quarter_name = '2001Q1'), q23 AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_quarter_name IN ('2001Q1', '2001Q2', '2001Q3')), a AS
  (SELECT i.i_item_id,
          i.i_item_desc,
          s.s_state,
          COUNT(ss.ss_quantity) AS ss_count,
          AVG(ss.ss_quantity) AS ss_avg,
          STDDEV_SAMP(ss.ss_quantity) AS ss_stddev,
          COUNT(sr.sr_return_quantity) AS sr_count,
          AVG(sr.sr_return_quantity) AS sr_avg,
          STDDEV_SAMP(sr.sr_return_quantity) AS sr_stddev,
          COUNT(cs.cs_quantity) AS cs_count,
          AVG(cs.cs_quantity) AS cs_avg,
          STDDEV_SAMP(cs.cs_quantity) AS cs_stddev
   FROM store_sales ss
   JOIN store_returns sr ON sr.sr_customer_sk = ss.ss_customer_sk
   AND sr.sr_item_sk = ss.ss_item_sk
   AND sr.sr_ticket_number = ss.ss_ticket_number
   JOIN catalog_sales cs ON cs.cs_bill_customer_sk = sr.sr_customer_sk
   AND cs.cs_item_sk = sr.sr_item_sk
   JOIN item i ON i.i_item_sk = ss.ss_item_sk
   JOIN store s ON s.s_store_sk = ss.ss_store_sk
   WHERE EXISTS
       (SELECT 1
        FROM q1
        WHERE q1.d_date_sk = ss.ss_sold_date_sk)
     AND EXISTS
       (SELECT 1
        FROM q23
        WHERE q23.d_date_sk = sr.sr_returned_date_sk)
     AND EXISTS
       (SELECT 1
        FROM q23
        WHERE q23.d_date_sk = cs.cs_sold_date_sk)
   GROUP BY i.i_item_id,
            i.i_item_desc,
            s.s_state)
SELECT i_item_id,
       i_item_desc,
       s_state,
       ss_count AS store_sales_quantitycount,
       ss_avg AS store_sales_quantityave,
       ss_stddev AS store_sales_quantitystdev,
       ss_stddev / NULLIF(ss_avg, 0) AS store_sales_quantitycov,
       sr_count AS store_returns_quantitycount,
       sr_avg AS store_returns_quantityave,
       sr_stddev AS store_returns_quantitystdev,
       sr_stddev / NULLIF(sr_avg, 0) AS store_returns_quantitycov,
       cs_count AS catalog_sales_quantitycount,
       cs_avg AS catalog_sales_quantityave,
       cs_stddev AS catalog_sales_quantitystdev,
       cs_stddev / NULLIF(cs_avg, 0) AS catalog_sales_quantitycov
FROM a
ORDER BY i_item_id NULLS FIRST,
         i_item_desc NULLS FIRST,
         s_state NULLS FIRST
LIMIT 100;
