WITH return_by_address AS MATERIALIZED
  (SELECT cr.cr_returning_customer_sk,
          cr.cr_returning_addr_sk,
          SUM(cr.cr_return_amt_inc_tax) AS address_total
   FROM catalog_returns cr
   WHERE cr.cr_returned_date_sk IN
       (SELECT d.d_date_sk
        FROM date_dim d
        WHERE d.d_year = 2000)
   GROUP BY cr.cr_returning_customer_sk,
            cr.cr_returning_addr_sk), customer_totals AS MATERIALIZED
  (SELECT r.cr_returning_customer_sk AS ctr_customer_sk,
          ra.ca_state AS ctr_state,
          SUM(r.address_total) AS ctr_total_return
   FROM return_by_address r
   JOIN customer_address ra ON ra.ca_address_sk = r.cr_returning_addr_sk
   GROUP BY r.cr_returning_customer_sk,
            ra.ca_state), state_thresholds AS MATERIALIZED
  (SELECT ctr_state,
          AVG(ctr_total_return) * 1.2 AS minimum_return
   FROM customer_totals
   GROUP BY ctr_state), target_customers AS
  (SELECT c.c_customer_sk,
          c.c_customer_id,
          c.c_salutation,
          c.c_first_name,
          c.c_last_name,
          ca.ca_street_number,
          ca.ca_street_name,
          ca.ca_street_type,
          ca.ca_suite_number,
          ca.ca_city,
          ca.ca_county,
          ca.ca_state,
          ca.ca_zip,
          ca.ca_country,
          ca.ca_gmt_offset,
          ca.ca_location_type
   FROM customer_address ca
   JOIN customer c ON c.c_current_addr_sk = ca.ca_address_sk
   WHERE ca.ca_state = 'GA')
SELECT tc.c_customer_id,
       tc.c_salutation,
       tc.c_first_name,
       tc.c_last_name,
       tc.ca_street_number,
       tc.ca_street_name,
       tc.ca_street_type,
       tc.ca_suite_number,
       tc.ca_city,
       tc.ca_county,
       tc.ca_state,
       tc.ca_zip,
       tc.ca_country,
       tc.ca_gmt_offset,
       tc.ca_location_type,
       ct.ctr_total_return
FROM customer_totals ct
JOIN state_thresholds st ON st.ctr_state = ct.ctr_state
AND ct.ctr_total_return > st.minimum_return
JOIN target_customers tc ON tc.c_customer_sk = ct.ctr_customer_sk
ORDER BY tc.c_customer_id,
         ct.ctr_total_return
LIMIT 100;
