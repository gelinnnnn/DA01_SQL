--Bài 1
with bang as(SELECT company_id, title, description, count(job_id) as so_luong
from job_listings 
group by company_id, title, description)
select count(*) as duplicate_companies
from bang
where so_luong > 1
--Bài 2
  --Cách 1
with bang1 as (SELECT category, product, sum(spend) as total_spend
from product_spend
where extract (year from transaction_date) = 2022 and category = 'appliance'
group by category, product
order by total_spend desc 
limit 2), bang2 as (SELECT category, product, sum(spend) as total_spend
from product_spend
where extract (year from transaction_date) = 2022 and category = 'electronics'
group by category, product
order by total_spend desc 
limit 2)

select category, product, total_spend
from bang1
UNION ALL
select category, product, total_spend
from bang2

  --Cách 2
  WITH cte AS (
    SELECT category, product, SUM(spend) AS total_spend, RANK() OVER(
           PARTITION BY category ORDER BY SUM(spend) DESC) AS ranking
    FROM product_spend
    WHERE EXTRACT(YEAR FROM DATE(transaction_date)) = 2022
    GROUP BY category, product
)
SELECT category, product, total_spend
FROM cte 
WHERE ranking <= 2
--Bài 3
with bang as (SELECT count(*) as so_luong 
FROM callers
group by policy_holder_id)

select count(*) as policy_holder_count
from bang
where so_luong >=3

--Bài 4
select a.page_id
from pages as a  
left join page_likes as b 
on a.page_id = b.page_id
where b.user_id is null
order by a.page_id
--Bài 5
  --Cách 1
with bang as(SELECT extract(month from event_date) as month
, user_id
FROM user_actions
where extract(month from event_date) = 6 or extract(month from event_date) = 7
group by user_id, extract(month from event_date))

select b.month as month
,count(b.user_id) as monthly_active_users 
from bang as a
left join bang as b  
on a. month = b.month - 1 and a.user_id = b.user_id
where b.user_id is not null
group by b.month

--Cách 2
select extract(month from event_date) as month
, count(distinct user_id)
from user_actions
where user_id in (select user_id
from user_actions
where extract (month from event_date) = 6 and extract (year from event_date) = 2022)
and extract(month from event_date) = 7
group by extract(month from event_date)
--Bài 6 (****)
select date_format(trans_date, '%Y-%m') as month
, country
, count(*) as trans_count
, count(case when state = 'approved' then 1 else null end) as approved_count
, sum(amount) as trans_total_amount
, sum(case when state = 'approved' then amount else 0 end) as approved_total_amount
from Transactions
group by (date_format(trans_date, '%Y-%m')), country

--Bài 7
with bang as(select *
, rank () over (partition by product_id order by year) as thu_tu
from Sales)

select product_id
, year as first_year
, quantity
, price
from bang
where thu_tu = 1

--Bài 8
with bang as (select a.product_key, b.customer_id
from Product as a
left join Customer as b
on a.product_key = b.product_key)

select customer_id
from bang
group by customer_id
having count(distinct product_key) = (select count(*) from Product)

--Code refined
select customer_id
from Customer
group by customer_id
having count(distinct product_key) = (select count(*) from Product)
--Bài 9
select e.employee_id
from employees e
where e.manager_id not in (
    select s.employee_id  
    from employees s
)
and e.salary < 30000
order by e.employee_id asc
--Bài 10
with bang as(SELECT company_id, title, description, count(job_id) as so_luong
from job_listings 
group by company_id, title, description)
select count(*) as duplicate_companies
from bang
where so_luong > 1
--Bài 11
with bang1 as(select b.name as results
from MovieRating as a
join Users as b on a.user_id = b.user_id
group by a.user_id
order by count(a.movie_id) desc, b.name asc
limit 1)
,bang2 as(select b.title as results
    from MovieRating as a
    join Movies as b on a.movie_id = b.movie_id
    where month(a.created_at)= 2 and year(a.created_at)= 2020
    group by a.movie_id
    order by avg(a.rating) desc, results
    limit 1)
select results from bang1
union all
select results from bang2
--Bài 12
--Cách 1 (tư duy ban đầu)
with bang1 as (select requester_id as id, count(accepter_id) as so_luong
    from RequestAccepted
    group by requester_id)
, bang2 as (select accepter_id as id, count(requester_id) as so_luong
    from RequestAccepted
    group by accepter_id)
, bang3 as
(select id, so_luong from bang1
union all
select id, so_luong from bang2)

select id, sum(so_luong) as num
from bang3 group by id
order by num desc
limit 1
--Cách 2 (refined)
with a as (select requester_id as id from RequestAccepted
union all
select accepter_id as id from RequestAccepted)

select id, count(id) as num from a group by id order by num desc limit 1



