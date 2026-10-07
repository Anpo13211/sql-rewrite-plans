WITH stores AS MATERIALIZED
  (SELECT s_store_sk,
          s_store_name,
          s_store_id
   FROM store
   WHERE s_gmt_offset = -5), dates AS MATERIALIZED
  (SELECT d_date_sk,
          d_day_name
   FROM date_dim
   WHERE d_year = 2000), store_day AS
  (SELECT ss.ss_store_sk,
          d.d_day_name,
          SUM(ss.ss_sales_price) AS day_sales
   FROM store_sales ss
   JOIN dates d ON d.d_date_sk = ss.ss_sold_date_sk
   JOIN stores s ON s.s_store_sk = ss.ss_store_sk
   GROUP BY ss.ss_store_sk,
            d.d_day_name)
SELECT s.s_store_name,
       s.s_store_id,
       SUM(x.day_sales) FILTER (
                                WHERE x.d_day_name = 'Sunday') AS sun_sales,
       SUM(x.day_sales) FILTER (
                                WHERE x.d_day_name = 'Monday') AS mon_sales,
       SUM(x.day_sales) FILTER (
                                WHERE x.d_day_name = 'Tuesday') AS tue_sales,
       SUM(x.day_sales) FILTER (
                                WHERE x.d_day_name = 'Wednesday') AS wed_sales,
       SUM(x.day_sales) FILTER (
                                WHERE x.d_day_name = 'Thursday') AS thu_sales,
       SUM(x.day_sales) FILTER (
                                WHERE x.d_day_name = 'Friday') AS fri_sales,
       SUM(x.day_sales) FILTER (
                                WHERE x.d_day_name = 'Saturday') AS sat_sales
FROM store_day x
JOIN stores s ON s.s_store_sk = x.ss_store_sk
GROUP BY s.s_store_name,
         s.s_store_id
ORDER BY s.s_store_name,
         s.s_store_id,
         sun_sales,
         mon_sales,
         tue_sales,
         wed_sales,
         thu_sales,
         fri_sales,
         sat_sales
LIMIT 100;
