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
