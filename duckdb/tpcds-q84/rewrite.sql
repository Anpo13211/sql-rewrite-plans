SELECT c.c_customer_id AS customer_id,
       concat(coalesce(c.c_last_name, ''), ', ', coalesce(c.c_first_name, '')) AS customername
FROM customer_address AS ca
JOIN customer AS c ON c.c_current_addr_sk = ca.ca_address_sk
JOIN household_demographics AS hd ON hd.hd_demo_sk = c.c_current_hdemo_sk
JOIN income_band AS ib ON ib.ib_income_band_sk = hd.hd_income_band_sk
AND ib.ib_lower_bound >= 38128
AND ib.ib_upper_bound <= 38128+50000
JOIN store_returns AS sr ON sr.sr_cdemo_sk = c.c_current_cdemo_sk
WHERE ca.ca_city = 'Edgewood'
ORDER BY c.c_customer_id NULLS FIRST
LIMIT 100;
