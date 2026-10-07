WITH flags AS NOT MATERIALIZED
  (SELECT ss_list_price,
          ss_quantity BETWEEN 0 AND 5
   AND (ss_list_price BETWEEN 8 AND 8 + 10
        OR ss_coupon_amt BETWEEN 459 AND 459 + 1000
        OR ss_wholesale_cost BETWEEN 57 AND 57 + 20) AS p1,
       ss_quantity BETWEEN 6 AND 10
   AND (ss_list_price BETWEEN 90 AND 90 + 10
        OR ss_coupon_amt BETWEEN 2323 AND 2323 + 1000
        OR ss_wholesale_cost BETWEEN 31 AND 31 + 20) AS p2,
       ss_quantity BETWEEN 11 AND 15
   AND (ss_list_price BETWEEN 142 AND 142 + 10
        OR ss_coupon_amt BETWEEN 12214 AND 12214 + 1000
        OR ss_wholesale_cost BETWEEN 79 AND 79 + 20) AS p3,
       ss_quantity BETWEEN 16 AND 20
   AND (ss_list_price BETWEEN 135 AND 135 + 10
        OR ss_coupon_amt BETWEEN 6071 AND 6071 + 1000
        OR ss_wholesale_cost BETWEEN 38 AND 38 + 20) AS p4,
       ss_quantity BETWEEN 21 AND 25
   AND (ss_list_price BETWEEN 122 AND 122 + 10
        OR ss_coupon_amt BETWEEN 836 AND 836 + 1000
        OR ss_wholesale_cost BETWEEN 17 AND 17 + 20) AS p5,
       ss_quantity BETWEEN 26 AND 30
   AND (ss_list_price BETWEEN 154 AND 154 + 10
        OR ss_coupon_amt BETWEEN 7326 AND 7326 + 1000
        OR ss_wholesale_cost BETWEEN 7 AND 7 + 20) AS p6
   FROM store_sales), relevant AS MATERIALIZED
  (SELECT *
   FROM flags
   WHERE p1
     OR p2
     OR p3
     OR p4
     OR p5
     OR p6)
SELECT avg(ss_list_price) FILTER (
                                  WHERE p1) AS B1_LP,
       count(ss_list_price) FILTER (
                                    WHERE p1) AS B1_CNT,
       count(DISTINCT ss_list_price) FILTER (
                                             WHERE p1) AS B1_CNTD,
       avg(ss_list_price) FILTER (
                                  WHERE p2) AS B2_LP,
       count(ss_list_price) FILTER (
                                    WHERE p2) AS B2_CNT,
       count(DISTINCT ss_list_price) FILTER (
                                             WHERE p2) AS B2_CNTD,
       avg(ss_list_price) FILTER (
                                  WHERE p3) AS B3_LP,
       count(ss_list_price) FILTER (
                                    WHERE p3) AS B3_CNT,
       count(DISTINCT ss_list_price) FILTER (
                                             WHERE p3) AS B3_CNTD,
       avg(ss_list_price) FILTER (
                                  WHERE p4) AS B4_LP,
       count(ss_list_price) FILTER (
                                    WHERE p4) AS B4_CNT,
       count(DISTINCT ss_list_price) FILTER (
                                             WHERE p4) AS B4_CNTD,
       avg(ss_list_price) FILTER (
                                  WHERE p5) AS B5_LP,
       count(ss_list_price) FILTER (
                                    WHERE p5) AS B5_CNT,
       count(DISTINCT ss_list_price) FILTER (
                                             WHERE p5) AS B5_CNTD,
       avg(ss_list_price) FILTER (
                                  WHERE p6) AS B6_LP,
       count(ss_list_price) FILTER (
                                    WHERE p6) AS B6_CNT,
       count(DISTINCT ss_list_price) FILTER (
                                             WHERE p6) AS B6_CNTD
FROM relevant
LIMIT 100;
