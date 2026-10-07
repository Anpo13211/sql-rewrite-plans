WITH f AS MATERIALIZED
  (SELECT i_item_sk item_sk,
          i_product_name product_name
   FROM item
   WHERE i_color IN ('purple', 'burlywood', 'indian', 'spring', 'floral', 'medium')
     AND i_current_price BETWEEN 64 AND 64+10
     AND i_current_price BETWEEN 64+1 AND 64+15),co AS MATERIALIZED
  (SELECT cs_item_sk item_sk,
          cs_order_number order_no,
          sum(cs_ext_list_price) sale,
          count(*) n
   FROM catalog_sales
   JOIN f ON item_sk=cs_item_sk
   GROUP BY 1,
            2),ro AS MATERIALIZED
  (SELECT cr_item_sk item_sk,
          cr_order_number order_no,
          sum(cr_refunded_cash+cr_reversed_charge+cr_store_credit) refund,
          count(*) n
   FROM catalog_returns
   JOIN f ON item_sk=cr_item_sk
   GROUP BY 1,
            2),u AS MATERIALIZED
  (SELECT co.item_sk
   FROM co
   JOIN ro USING(item_sk,
                 order_no)
   GROUP BY co.item_sk
   HAVING sum(co.sale*ro.n)>2*sum(ro.refund*co.n)),r AS MATERIALIZED
  (SELECT sr_item_sk item_sk,
          sr_ticket_number ticket_no,
          count(*) n
   FROM store_returns
   JOIN u ON item_sk=sr_item_sk
   GROUP BY 1,
            2),x AS MATERIALIZED
  (SELECT f.product_name,
          f.item_sk,
          s.s_store_name store_name,
          s.s_zip store_zip,
          a1.ca_street_number b_street_number,
          a1.ca_street_name b_street_name,
          a1.ca_city b_city,
          a1.ca_zip b_zip,
          a2.ca_street_number c_street_number,
          a2.ca_street_name c_street_name,
          a2.ca_city c_city,
          a2.ca_zip c_zip,
          d1.d_year syear,
          d2.d_year fsyear,
          d3.d_year s2year,
          sum(r.n) cnt,
          sum(ss.ss_wholesale_cost*r.n) s1,
          sum(ss.ss_list_price*r.n) s2,
          sum(ss.ss_coupon_amt*r.n) s3
   FROM store_sales ss
   JOIN r ON r.item_sk=ss.ss_item_sk
   AND r.ticket_no=ss.ss_ticket_number
   JOIN f ON f.item_sk=ss.ss_item_sk
   JOIN date_dim d1 ON d1.d_date_sk=ss.ss_sold_date_sk
   AND d1.d_year IN (1999,1999+1)
   JOIN store s ON s.s_store_sk=ss.ss_store_sk
   JOIN customer c ON c.c_customer_sk=ss.ss_customer_sk
   JOIN customer_demographics cd1 ON cd1.cd_demo_sk=ss.ss_cdemo_sk
   JOIN customer_demographics cd2 ON cd2.cd_demo_sk=c.c_current_cdemo_sk
   AND cd1.cd_marital_status<>cd2.cd_marital_status
   JOIN household_demographics hd1 ON hd1.hd_demo_sk=ss.ss_hdemo_sk
   JOIN household_demographics hd2 ON hd2.hd_demo_sk=c.c_current_hdemo_sk
   JOIN customer_address a1 ON a1.ca_address_sk=ss.ss_addr_sk
   JOIN customer_address a2 ON a2.ca_address_sk=c.c_current_addr_sk
   JOIN date_dim d2 ON d2.d_date_sk=c.c_first_sales_date_sk
   JOIN date_dim d3 ON d3.d_date_sk=c.c_first_shipto_date_sk
   JOIN promotion p ON p.p_promo_sk=ss.ss_promo_sk
   JOIN income_band ib1 ON ib1.ib_income_band_sk=hd1.hd_income_band_sk
   JOIN income_band ib2 ON ib2.ib_income_band_sk=hd2.hd_income_band_sk
   GROUP BY ALL)
SELECT a.product_name,
       a.store_name,
       a.store_zip,
       a.b_street_number,
       a.b_street_name,
       a.b_city,
       a.b_zip,
       a.c_street_number,
       a.c_street_name,
       a.c_city,
       a.c_zip,
       a.syear cs1syear,
       a.cnt cs1cnt,
       a.s1 s11,
       a.s2 s21,
       a.s3 s31,
       b.s1 s12,
       b.s2 s22,
       b.s3 s32,
       b.syear,
       b.cnt
FROM x a
JOIN x b ON a.item_sk=b.item_sk
AND a.store_name=b.store_name
AND a.store_zip=b.store_zip
AND b.cnt<=a.cnt
WHERE a.syear=1999
  AND b.syear=1999+1
ORDER BY a.product_name,
         a.store_name,
         b.cnt,
         a.s1,
         b.s1;
