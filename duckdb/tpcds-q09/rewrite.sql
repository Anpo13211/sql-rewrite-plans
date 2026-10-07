WITH quantity_stats AS
  (SELECT ss_quantity AS qty,
          count(*) AS ROW_COUNT,
          sum(ss_ext_discount_amt) AS discount_sum,
          count(ss_ext_discount_amt) AS discount_count,
          sum(ss_net_paid) AS net_sum,
          count(ss_net_paid) AS net_count
   FROM store_sales
   GROUP BY ss_quantity),
     metrics AS
  (SELECT coalesce(sum(ROW_COUNT) FILTER (
                                          WHERE qty BETWEEN 1 AND 20), 0) AS c1,
          sum(discount_sum) FILTER (
                                    WHERE qty BETWEEN 1 AND 20)/nullif(sum(discount_count) FILTER (
                                                                                                   WHERE qty BETWEEN 1 AND 20), 0) AS d1,
          sum(net_sum) FILTER (
                               WHERE qty BETWEEN 1 AND 20)/nullif(sum(net_count) FILTER (
                                                                                            WHERE qty BETWEEN 21 AND 40), 0) AS n1,
          coalesce(sum(ROW_COUNT) FILTER (
                                          WHERE qty BETWEEN 21 AND 40), 0) AS c2,
          sum(discount_sum) FILTER (
                                    WHERE qty BETWEEN 21 AND 40)/nullif(sum(discount_count) FILTER (
                                                                                                    WHERE qty BETWEEN 21 AND 40), 0) AS d2,
          sum(net_sum) FILTER (
                               WHERE qty BETWEEN 41 AND 60)/nullif(sum(net_count) FILTER (
                                                                                            WHERE qty BETWEEN 41 AND 60), 0) AS n2,
          coalesce(sum(ROW_COUNT) FILTER (
                                          WHERE qty BETWEEN 61 AND 80), 0) AS c3,
          sum(discount_sum) FILTER (
                                    WHERE qty BETWEEN 41 AND 60)/nullif(sum(discount_count) FILTER (
                                                                                                    WHERE qty BETWEEN 41 AND 60), 0) AS d3,
          sum(net_sum) FILTER (
                               WHERE qty BETWEEN 61 AND 80)/nullif(sum(net_count) FILTER (
                                                                                            WHERE qty BETWEEN 81 AND 100), 0) AS n3,
          coalesce(sum(ROW_COUNT) FILTER (
                                          WHERE qty BETWEEN 81 AND 100), 0) AS c4,
          sum(discount_sum) FILTER (
                                    WHERE qty BETWEEN 61 AND 80)/nullif(sum(discount_count) FILTER (
                                                                                                    WHERE qty BETWEEN 61 AND 80), 0) AS d4,
          sum(net_sum) FILTER (
                               WHERE qty BETWEEN 81 AND 100)/nullif(sum(net_count) FILTER (
                                                                                            WHERE qty BETWEEN 81 AND 100), 0) AS n4,
          coalesce(sum(ROW_COUNT) FILTER (
                                          WHERE qty BETWEEN 81 AND 100), 0) AS c5,
          sum(discount_sum) FILTER (
                                    WHERE qty BETWEEN 81 AND 100)/nullif(sum(discount_count) FILTER (
                                                                                                     WHERE qty BETWEEN 81 AND 100), 0) AS d5,
          sum(net_sum) FILTER (
                               WHERE qty BETWEEN 81 AND 100)/nullif(sum(net_count) FILTER (
                                                                                            WHERE qty BETWEEN 81 AND 100), 0) AS n5
   FROM quantity_stats)
SELECT CASE
           WHEN c1 > 165306 THEN d1
           ELSE n1
       END AS bucket1,
       CASE
           WHEN c2 > 10097 THEN d2
           ELSE n2
       END AS bucket2,
       CASE
           WHEN c3 > 56580 THEN d3
           ELSE n3
       END AS bucket3,
       CASE
           WHEN c4 > 122840 THEN d4
           ELSE n4
       END AS bucket4,
       CASE
           WHEN c5 > 74129 THEN d5
           ELSE n5
       END AS bucket5
FROM metrics
JOIN reason ON r_reason_sk = 1;
