SELECT CASE
           WHEN a.c1 > 74129 THEN a.d1
           ELSE a.n1
       END AS bucket1,
       CASE
           WHEN a.c2 > 122840 THEN a.d2
           ELSE a.n2
       END AS bucket2,
       CASE
           WHEN a.c3 > 56580 THEN a.d3
           ELSE a.n3
       END AS bucket3,
       CASE
           WHEN a.c4 > 10097 THEN a.d4
           ELSE a.n4
       END AS bucket4,
       CASE
           WHEN a.c5 > 165306 THEN a.d5
           ELSE a.n5
       END AS bucket5
FROM reason AS r
CROSS JOIN
  (SELECT count(*) FILTER (
                           WHERE ss_quantity BETWEEN 21 AND 40) AS c1,
          avg(ss_ext_discount_amt) FILTER (
                                           WHERE ss_quantity BETWEEN 1 AND 20) AS d1,
          avg(ss_net_paid) FILTER (
                                   WHERE ss_quantity BETWEEN 21 AND 40) AS n1,
          count(*) FILTER (
                           WHERE ss_quantity BETWEEN 41 AND 60) AS c2,
          avg(ss_ext_discount_amt) FILTER (
                                           WHERE ss_quantity BETWEEN 21 AND 40) AS d2,
          avg(ss_net_paid) FILTER (
                                   WHERE ss_quantity BETWEEN 41 AND 60) AS n2,
          count(*) FILTER (
                           WHERE ss_quantity BETWEEN 61 AND 80) AS c3,
          avg(ss_ext_discount_amt) FILTER (
                                           WHERE ss_quantity BETWEEN 41 AND 60) AS d3,
          avg(ss_net_paid) FILTER (
                                   WHERE ss_quantity BETWEEN 61 AND 80) AS n3,
          count(*) FILTER (
                           WHERE ss_quantity BETWEEN 81 AND 100) AS c4,
          avg(ss_ext_discount_amt) FILTER (
                                           WHERE ss_quantity BETWEEN 61 AND 80) AS d4,
          avg(ss_net_paid) FILTER (
                                   WHERE ss_quantity BETWEEN 81 AND 100) AS n4,
          count(*) FILTER (
                           WHERE ss_quantity BETWEEN 1 AND 20) AS c5,
          avg(ss_ext_discount_amt) FILTER (
                                           WHERE ss_quantity BETWEEN 81 AND 100) AS d5,
          avg(ss_net_paid) FILTER (
                                   WHERE ss_quantity BETWEEN 1 AND 20) AS n5
   FROM store_sales) AS a
WHERE r.r_reason_sk = 1;
