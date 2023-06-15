--1) Which product has the highest price? Only return a single row.

select * from products where price = (select max(price) from products) 

--2) Which customer has made the most orders?

with cte as (select customer_id,count(order_id) as total_cnt from orders group by customer_id)

select concat(c.first_name,' ',c.last_name) as customer_name from customers c 
join cte o on c.customer_id=o.customer_id where o.total_cnt = (select max(o.total_cnt) from cte o)

--3) What’s the total revenue per product?

with cte as (select p.product_name,o.quantity*p.price as revenue from order_items o join products p on o.product_id=p.product_id)
select product_name,sum(revenue) as total_revenue from cte group by product_name

--4) Find the day with the highest revenue.

with cte as
(select i.order_id,i.quantity*p.price as revenue from order_items i join products p on i.product_id=p.product_id), 
cte2 as (select order_id,sum(revenue) as total_revenue from cte group by order_id) 
select top 1 o.order_date from orders o join cte2 c on o.order_id=c.order_id order by c.total_revenue desc

--5) Find the first order (by date) for each customer.

with cte as (select customer_id,order_id,row_number() over(partition by customer_id order by order_date) as rn from orders)
select customer_id,order_id from cte where rn=1

--6) Find the top 3 customers who have ordered the most distinct products

select top 3 concat(c.first_name, ' ', c.last_name) as customer_name from customers c
join orders o on c.customer_id = o.customer_id
join order_items i on o.order_id = i.order_id
group by c.customer_id,c.first_name, c.last_name
order by count(distinct i.product_id) desc

--7) Which product has been bought the least in terms of quantity?

with cte as (select p.product_name,i.product_id,sum(quantity) as prod_quantity from order_items i 
join products p on i.product_id=p.product_id 
group by i.product_id,p.product_name) 
select product_name from cte where prod_quantity = (select min(prod_quantity) from cte)

--8) What is the median order total?

with cte as (select i.order_id,sum(i.quantity*p.price) as order_total from orders o
join order_items i on o.order_id=i.order_id join products p on i.product_id=p.product_id group by o.order_id,i.order_id)
select avg(order_total) as median  from  
(select *,row_number() over (order by order_total) as rn,count(1) over() as total_cnt from cte) a
where rn between total_cnt*1.0/2 and total_cnt*1.0/2+1 

--9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

select i.order_id,sum(i.quantity*p.price) as total, case 
       when sum(i.quantity*p.price)>300 then 'Expensive'
       when sum(i.quantity*p.price)>100 and sum(i.quantity*p.price)<300 then 'Affordable'
	   else 'Cheap' end as order_type from order_items i 
join products p on i.product_id=p.product_id group by i.order_id


--10) Find customers who have ordered the product with the highest price.

 with cte as (select c.first_name,c.last_name,p.price from customers c 
join orders o on c.customer_id=o.customer_id 
join order_items i on o.order_id=i.order_id 
join products p on i.product_id=p.product_id ) 
select concat(first_name,' ',last_name) as customer_name from cte where price=(select max(price) from cte)
