sp_help sessions

SELECT start_time
FROM sessions
WHERE TRY_CONVERT(datetime2,start_time) IS NULL
AND start_time IS NOT NULL;

SELECT customer_id
FROM sessions
WHERE TRY_CONVERT(int,customer_id) IS NULL
AND customer_id IS NOT NULL;

SELECT session_id
FROM sessions
WHERE TRY_CONVERT(int,session_id) IS NULL
AND session_id IS NOT NULL;

alter table sessions
alter column start_time datetime2

alter table sessions
alter column customer_id int

alter table sessions
alter column session_id int

sp_help products
select * from  products

SELECT product_id
FROM products
WHERE TRY_CONVERT(int,product_id) IS NULL
AND product_id IS NOT NULL;

SELECT price_usd
FROM products
WHERE TRY_CONVERT(decimal(10,2),price_usd) IS NULL
AND price_usd IS NOT NULL;

SELECT cost_usd
FROM products
WHERE TRY_CONVERT(decimal(10,2),cost_usd) IS NULL
AND cost_usd IS NOT NULL;

SELECT margin_usd
FROM products
WHERE TRY_CONVERT(decimal(10,2),margin_usd) IS NULL
AND margin_usd IS NOT NULL;

alter table products
alter column product_id int

alter table products
alter column cost_usd decimal(10,2)

alter table products
alter column price_usd decimal(10,2)

alter table products
alter column margin_usd decimal(10,2)

sp_help orders
select * from dbo.orders

SELECT order_id
FROM orders
WHERE TRY_CONVERT(int,order_id) IS NULL
AND order_id IS NOT NULL;

SELECT customer_id
FROM orders
WHERE TRY_CONVERT(int,customer_id) IS NULL
AND customer_id IS NOT NULL;

SELECT order_time
FROM orders
WHERE TRY_CONVERT(datetime2,order_time) IS NULL
AND order_time IS NOT NULL;


SELECT discount_pct
FROM orders
WHERE TRY_CONVERT(int,discount_pct) IS NULL
AND discount_pct IS NOT NULL;

SELECT subtotal_usd
FROM orders
WHERE TRY_CONVERT(decimal(10,2),subtotal_usd) IS NULL
AND subtotal_usd IS NOT NULL;

SELECT total_usd
FROM orders
WHERE TRY_CONVERT(decimal(10,2),total_usd) IS NULL
AND total_usd IS NOT NULL;

alter table orders
alter column order_id int

alter table orders
alter column customer_id int

alter table orders
alter column order_time datetime2

alter table orders
alter column discount_pct int

alter table orders
alter column subtotal_usd decimal(10,2)

alter table orders
alter column total_usd decimal(10,2)

select * from dbo.order_items

SELECT order_id
FROM order_items
WHERE TRY_CONVERT(int,order_id) IS NULL
AND order_id IS NOT NULL;

SELECT product_id
FROM order_items
WHERE TRY_CONVERT(int,product_id) IS NULL
AND product_id IS NOT NULL;

SELECT unit_price_usd
FROM order_items
WHERE TRY_CONVERT(decimal(10,2),unit_price_usd) IS NULL
AND unit_price_usd IS NOT NULL;

SELECT quantity
FROM order_items
WHERE TRY_CONVERT(int,quantity) IS NULL
AND quantity IS NOT NULL;

SELECT line_total_usd
FROM order_items
WHERE TRY_CONVERT(decimal(10,2),line_total_usd) IS NULL
AND line_total_usd IS NOT NULL;

alter table order_items
alter column order_id int

alter table order_items
alter column product_id int

alter table order_items
alter column unit_price_usd decimal(10,2)

alter table order_items
alter column quantity int

alter table order_items
alter column line_total_usd decimal(10,2)

select * from dbo.events

SELECT event_id
FROM events
WHERE TRY_CONVERT(int,event_id) IS NULL
AND event_id IS NOT NULL;

SELECT session_id
FROM events
WHERE TRY_CONVERT(int,session_id) IS NULL
AND session_id IS NOT NULL;

SELECT timestamp
FROM events
WHERE TRY_CONVERT(datetime2,timestamp) IS NULL
AND timestamp IS NOT NULL;

SELECT DISTINCT 
       '[' + product_id + ']' AS visible_value,
       LEN(product_id) AS length_value
FROM events
WHERE TRY_CONVERT(decimal(10,2), product_id) IS NULL
AND product_id IS NOT NULL

UPDATE events
SET product_id = NULL
WHERE product_id = '';

SELECT product_id
FROM events
WHERE TRY_CONVERT(decimal(10,1),product_id) IS NULL
AND product_id IS NOT NULL;

SELECT DISTINCT 
       '[' + qty + ']' AS visible_value,
       LEN(qty) AS length_value
FROM events
WHERE TRY_CONVERT(decimal(10,2), qty) IS NULL
AND qty IS NOT NULL

UPDATE events
SET qty = NULL
WHERE qty = '';

SELECT qty
FROM events
WHERE TRY_CONVERT(decimal(10,1),qty) IS NULL
AND qty IS NOT NULL;

SELECT DISTINCT 
       '[' + cart_size + ']' AS visible_value,
       LEN(cart_size) AS length_value
FROM events
WHERE TRY_CONVERT(decimal(10,2), cart_size) IS NULL
AND cart_size IS NOT NULL

UPDATE events
SET cart_size = NULL
WHERE cart_size = '';

SELECT cart_size
FROM events
WHERE TRY_CONVERT(decimal(10,1),cart_size) IS NULL
AND cart_size IS NOT NULL;

SELECT DISTINCT 
       '[' + discount_pct + ']' AS visible_value,
       LEN(discount_pct) AS length_value
FROM events
WHERE TRY_CONVERT(decimal(10,2), discount_pct) IS NULL
AND discount_pct IS NOT NULL

UPDATE events
SET discount_pct = NULL
WHERE discount_pct = '';

SELECT discount_pct
FROM events
WHERE TRY_CONVERT(decimal(10,1),discount_pct) IS NULL
AND discount_pct IS NOT NULL;

SELECT DISTINCT 
       '[' + amount_usd + ']' AS visible_value,
       LEN(amount_usd) AS length_value
FROM events
WHERE TRY_CONVERT(decimal(10,2), amount_usd) IS NULL
AND amount_usd IS NOT NULL

UPDATE events
SET amount_usd = NULL
WHERE amount_usd = '';

SELECT amount_usd
FROM events
WHERE TRY_CONVERT(decimal(10,2),amount_usd) IS NULL
AND amount_usd IS NOT NULL;

alter table events
alter column event_id int

alter table events
alter column session_id int

alter table events
alter column timestamp datetime2

alter table events
alter column product_id decimal(10,1)

alter table events
alter column cart_size decimal(10,1)

alter table events
alter column qty decimal(10,1)

alter table events
alter column discount_pct decimal(10,1)

alter table events
alter column amount_usd decimal(10,2)
sp_help events

select * from dbo.customers

SELECT customer_id
FROM customers
WHERE TRY_CONVERT(int,customer_id) IS NULL
AND customer_id IS NOT NULL;

SELECT age
FROM customers
WHERE TRY_CONVERT(int,age) IS NULL
AND age IS NOT NULL

alter table customers
alter column customer_id int


alter table customers
alter column age int



