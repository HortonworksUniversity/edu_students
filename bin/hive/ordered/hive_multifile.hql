FROM ORDERS o
INSERT OVERWRITE DIRECTORY '2010_orders' SELECT o.* WHERE substr(order_date,0,4) = '2010'
INSERT OVERWRITE DIRECTORY 'software' SELECT o.* WHERE itemlist LIKE '%Software%';