--- 1. Date range of orders ---
     first_order     |     last_order      
---------------------+---------------------
 2016-09-04 21:15:19 | 2018-10-17 17:30:18
(1 row)

--- 2. Orders by status ---
 order_status | orders 
--------------+--------
 delivered    |  96478
 shipped      |   1107
 canceled     |    625
 unavailable  |    609
 invoiced     |    314
 processing   |    301
 created      |      5
 approved     |      2
(8 rows)

--- 3. Missing values in orders ---
 total_orders | no_approved_date | no_carrier_date | no_delivery_date
--------------+------------------+-----------------+------------------
        99441 |              160 |            1783 |             2965
(1 row)

--- 4. Is order_id really unique? ---
 total_rows | distinct_orders 
------------+-----------------
      99441 |           99441
(1 row)

--- 5. Delivered orders with no delivery date ---
 suspicious_orders 
-------------------
                 8
(1 row)

--- 6. Delivered BEFORE purchased (impossible) ---
 impossible_orders 
-------------------
                 0
(1 row)

--- 7. Orders that have more than one review ---
 orders_with_multiple_reviews 
------------------------------
                          547
(1 row)

--- 8. Orders with no items at all ---
 orders_without_items 
----------------------
                  775
(1 row)

--- 9. Products with no category ---
 no_category | total_products 
-------------+----------------
         610 |          32951
(1 row)

--- 10. Categories with no English translation ---
             product_category_name
-----------------------------------------------
 portateis_cozinha_e_preparadores_de_alimentos
 pc_gamer
(2 rows)

--- 11. Price range of items ---
 cheapest | most_expensive | average 
----------+----------------+---------
     0.85 |        6735.00 |  120.65
(1 row)



--- 1. Orders per month ---
  month  | orders 
---------+--------
 2016-09 |      4
 2016-10 |    324
 2016-12 |      1
 2017-01 |    800
 2017-02 |   1780
 2017-03 |   2682
 2017-04 |   2404
 2017-05 |   3700
 2017-06 |   3245
 2017-07 |   4026
 2017-08 |   4331
 2017-09 |   4285
 2017-10 |   4631
 2017-11 |   7544
 2017-12 |   5673
 2018-01 |   7269
 2018-02 |   6728
 2018-03 |   7211
 2018-04 |   6939
 2018-05 |   6873
 2018-06 |   6167
 2018-07 |   6292
 2018-08 |   6512
 2018-09 |     16
 2018-10 |      4
(25 rows)

--- 2. Orders without items, by status ---
 order_status | orders 
--------------+--------
 unavailable  |    603
 canceled     |    164
 created      |      5
 invoiced     |      2
 shipped      |      1
(5 rows)

--- 3. Non-delivered orders that HAVE a delivery date ---
 order_status | orders 
--------------+--------
 canceled     |      6
(1 row)

--- 4. Shipped to carrier BEFORE purchase (impossible) ---
 impossible_orders 
-------------------
               166
(1 row)

--- 5. Customer rows vs real people ---
 customer_rows | real_people 
---------------+-------------
         99441 |       96096
(1 row)

--- 6. Review score spread ---
 review_score | reviews 
--------------+---------
 1            |   11424
 2            |    3151
 3            |    8179
 4            |   19142
 5            |   57328
(5 rows)

--- 7. Payment types and values ---
 payment_type | payments | smallest | largest  
--------------+----------+----------+----------
 credit_card  |    76795 |     0.01 | 13664.08
 boleto       |    19784 |    11.62 |  7274.88
 voucher      |     5775 |     0.00 |  3184.34
 debit_card   |     1529 |    13.38 |  4445.50
 not_defined  |        3 |     0.00 |     0.00
(5 rows)

--- 8. Geolocation: rows vs distinct zip prefixes ---
  rows   | distinct_zip_prefixes 
---------+-----------------------
 1000163 |                 19015
(1 row)

--- 9. The 5 most expensive items ---
             order_id             |            product_id            |  price  | freight_value 
----------------------------------+----------------------------------+---------+---------------
 0812eb902a67711a1cb742b3cdaa65ae | 489ae2aa008f021502940f251d4cce7f | 6735.00 | 194.31
 fefacc66af859508bf1a7934eab1e97f | 69c590f7ffc7bf8db97190b6cb6ed62e | 6729.00 | 193.21
 f5136e38d1a14a4dbd87dff67da82701 | 1bdf5e6731585cf01aa8169c7028d6ad | 6499.00 | 227.66
 a96610ab360d42a2e5335a3998b4718a | a6492cc69376c469ab6f61d8f44de961 | 4799.00 | 151.34
 199af31afc78c699f0dbf71fb178d4d4 | c3ed642d592594bb648ff4a04cee2747 | 4690.00 | 74.34
(5 rows)
