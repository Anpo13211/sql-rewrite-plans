WITH date_keys AS NOT MATERIALIZED
  (SELECT d_date_sk
   FROM date_dim
   WHERE d_qoy = 2
     AND d_year = 2001), selected_ids AS MATERIALIZED
  (SELECT DISTINCT i_item_id
   FROM item
   WHERE i_item_sk IN (2, 3, 5, 7, 11, 13, 17, 19, 23, 29)), eligible_items AS MATERIALIZED
  (SELECT i.i_item_sk
   FROM item i
   JOIN selected_ids s USING (i_item_id)), branch_totals AS
  (SELECT ca.ca_zip,
          ca.ca_city,
          SUM(ws.ws_sales_price) AS sales_total
   FROM date_keys d
   JOIN web_sales ws ON ws.ws_sold_date_sk = d.d_date_sk
   JOIN customer c ON c.c_customer_sk = ws.ws_bill_customer_sk
   JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
   JOIN item i ON i.i_item_sk = ws.ws_item_sk
   WHERE SUBSTRING(ca.ca_zip, 1, 5) IN ('85669',
                                        '86197',
                                        '88274',
                                        '83405',
                                        '86475',
                                        '85392',
                                        '85460',
                                        '80348',
                                        '81792')
   GROUP BY ca.ca_zip,
            ca.ca_city
   UNION ALL SELECT ca.ca_zip,
                    ca.ca_city,
                    SUM(ws.ws_sales_price) AS sales_total
   FROM date_keys d
   JOIN web_sales ws ON ws.ws_sold_date_sk = d.d_date_sk
   JOIN eligible_items ei ON ei.i_item_sk = ws.ws_item_sk
   JOIN customer c ON c.c_customer_sk = ws.ws_bill_customer_sk
   JOIN customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
   WHERE (SUBSTRING(ca.ca_zip, 1, 5) IN ('85669',
                                         '86197',
                                         '88274',
                                         '83405',
                                         '86475',
                                         '85392',
                                         '85460',
                                         '80348',
                                         '81792')) IS NOT TRUE
   GROUP BY ca.ca_zip,
            ca.ca_city)
SELECT ca_zip,
       ca_city,
       SUM(sales_total) AS SUM
FROM branch_totals
GROUP BY ca_zip,
         ca_city
ORDER BY ca_zip,
         ca_city
LIMIT 100;
