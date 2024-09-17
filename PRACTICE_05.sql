--Bài 1
select b.continent
, round(avg(a.population),0)
from country as b
join city as a
on a.countrycode = b.code
group by b.continent
--Bài 2
SELECT 
ROUND(1.0*sum(case 
when signup_action = 'Confirmed' then 1
else 0
end)/count(*),2) as confirm_rate
FROM emails as a  
full join texts as b 
on a.email_id = b.email_id
where b.text_id is not null
--Bài 3
with bang1 as 
(select b.age_bucket
, sum(case when a.activity_type ='send' then a.time_spent end) as send_perc
, sum(case when a.activity_type ='open' then a.time_spent end) as open_perc
from activities as a  
join age_breakdown as b 
on a.user_id = b.user_id
where a.activity_type <> 'chat'
group by b.age_bucket)

select age_bucket
, round(100.00*send_perc/(send_perc+open_perc),2) as send_perc
, round(100.00*open_perc/(send_perc+open_perc),2) as open_perc
from bang1
--Bài 4
  --Cách 1
select 
a.product_category,
sum(case when b.customer_id = 1 then 1 else 0 end) as customer_1
, sum(case when b.customer_id = 2 then 1 else 0 end) as customer_2
, sum(case when b.customer_id = 3 then 1 else 0 end) as customer_3
from products as a
LEFT JOIN customer_contracts as b 
on a.product_id = b.product_id
group by a.product_category
order by a.product_category
-- Cách 2
with bang1 as(select b.customer_id, a.product_category, count(a.product_category)
, case when a.product_category = 'Analytics' then 1
when a.product_category = 'Compute' then 2
when a.product_category = 'Containers' then 3
end as conditions
from products as a  
left join customer_contracts as b 
on a.product_id = b.product_id 
group by b.customer_id, a.product_category
order by b.customer_id, a.product_category)

select customer_id
from bang1
group by customer_id
having sum(conditions) >=6
--Cách 3
with bang1 as(select b.customer_id, count(distinct a.product_category)
from products as a  
left join customer_contracts as b 
on a.product_id = b.product_id
group by b.customer_id
order by b.customer_id)

select customer_id
from bang1
where count=3

--Bài 5
select 
a.reports_to as employee_id
, b.name as name
, count(a.employee_id) as reports_count
, round(avg(a.age),0) as average_age
from Employees as a
join Employees as b
on a.reports_to = b.employee_id
where a.reports_to is not null
group by a.reports_to
order by a.reports_to
--Bài 6
select a.product_name as product_name
, sum(b.unit) as unit
from Products as a
join Orders as b
on a.product_id = b.product_id
where month(b.order_date)=2 and year(b.order_date) = 2020 
group by b.product_id
having sum(b.unit) >= 100
--Bài 7
select a.page_id
from pages as a  
left join page_likes as b 
on a.page_id = b.page_id
where b.user_id is null
order by a.page_id

