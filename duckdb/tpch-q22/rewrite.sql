WITH phone_customers AS MATERIALIZED
  (SELECT c_custkey,
          substring(c_phone
                    FROM 1
                    FOR 2) AS cntrycode,
          c_acctbal
   FROM customer
   WHERE substring(c_phone
                   FROM 1
                   FOR 2) IN ('13',
                              '31',
                              '23',
                              '29',
                              '30',
                              '18',
                              '17')), avg_bal AS
  (SELECT avg(c_acctbal) AS value
   FROM phone_customers
   WHERE c_acctbal > 0.0),
                                      order_customers AS
  (SELECT o_custkey
   FROM orders
   GROUP BY o_custkey)
SELECT p.cntrycode,
       count(*) AS numcust,
       sum(p.c_acctbal) AS totacctbal
FROM phone_customers p ANTI
JOIN order_customers o ON o.o_custkey = p.c_custkey
CROSS JOIN avg_bal a
WHERE p.c_acctbal > 0.0
  AND p.c_acctbal > a.value
GROUP BY p.cntrycode
ORDER BY p.cntrycode;
