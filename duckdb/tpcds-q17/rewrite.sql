WITH d1k AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_quarter_name = '2001Q1'
     AND d_date_sk BETWEEN 2450816 AND 2452642), d2k AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_quarter_name IN ('2001Q1', '2001Q2', '2001Q3')
     AND d_date_sk BETWEEN 2450820 AND 2452822), d3k AS MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_quarter_name IN ('2001Q1', '2001Q2', '2001Q3')
     AND d_date_sk BETWEEN 2450815 AND 2452653), ss AS MATERIALIZED
  (SELECT ss_customer_sk,
          ss_item_sk,
          ss_store_sk,
          ss_ticket_number,
          ss_quantity
   FROM store_sales
   JOIN d1k ON d_date_sk = ss_sold_date_sk), sr AS MATERIALIZED
  (SELECT sr_customer_sk,
          sr_item_sk,
          sr_ticket_number,
          sr_return_quantity
   FROM store_returns
   JOIN d2k ON d_date_sk = sr_returned_date_sk), cs AS MATERIALIZED
  (SELECT cs_bill_customer_sk,
          cs_item_sk,
          cs_quantity
   FROM catalog_sales
   JOIN d3k ON d_date_sk = cs_sold_date_sk), a AS
  (SELECT i.i_item_id,
          i.i_item_desc,
          s.s_state,
          count(ss.ss_quantity) AS ss_n,
          avg(ss.ss_quantity) AS ss_avg,
          stddev_samp(ss.ss_quantity) AS ss_sd,
          count(sr.sr_return_quantity) AS sr_n,
          avg(sr.sr_return_quantity) AS sr_avg,
          stddev_samp(sr.sr_return_quantity) AS sr_sd,
          count(cs.cs_quantity) AS cs_n,
          avg(cs.cs_quantity) AS cs_avg,
          stddev_samp(cs.cs_quantity) AS cs_sd
   FROM ss
   JOIN sr ON sr.sr_customer_sk = ss.ss_customer_sk
   AND sr.sr_item_sk = ss.ss_item_sk
   AND sr.sr_ticket_number = ss.ss_ticket_number
   JOIN cs ON cs.cs_bill_customer_sk = sr.sr_customer_sk
   AND cs.cs_item_sk = sr.sr_item_sk
   JOIN item i ON i.i_item_sk = ss.ss_item_sk
   JOIN store s ON s.s_store_sk = ss.ss_store_sk
   GROUP BY i.i_item_id,
            i.i_item_desc,
            s.s_state)
SELECT i_item_id,
       i_item_desc,
       s_state,
       ss_n AS store_sales_quantitycount,
       ss_avg AS store_sales_quantityave,
       ss_sd AS store_sales_quantitystdev,
       ss_sd / NULLIF(ss_avg, 0) AS store_sales_quantitycov,
       sr_n AS store_returns_quantitycount,
       sr_avg AS store_returns_quantityave,
       sr_sd AS store_returns_quantitystdev,
       sr_sd / NULLIF(sr_avg, 0) AS store_returns_quantitycov,
       cs_n AS catalog_sales_quantitycount,
       cs_avg AS catalog_sales_quantityave,
       cs_sd AS catalog_sales_quantitystdev,
       cs_sd / NULLIF(cs_avg, 0) AS catalog_sales_quantitycov
FROM a
ORDER BY i_item_id NULLS FIRST,
         i_item_desc NULLS FIRST,
         s_state NULLS FIRST
LIMIT 100;
