--Bài 1
with bang as(SELECT company_id, title, description, count(job_id) as so_luong
from job_listings 
group by company_id, title, description)
select count(*) as duplicate_companies
from bang
where so_luong > 1
--Bài 2
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
--Code bị sai
select date_format(trans_date,'%Y-%m') as month
, country
, count(trans_date) as trans_count
, (select count(trans_date) from Transactions where state = 'approved' and date_format(trans_date,'%Y-%m') = a.date_format(trans_date,'%Y-%m')group by extract(month from trans_date), extract(year from trans_date)) as approved_count
, sum(amount) as trans_total_amount
, (select sum(amount) from Transactions where state = 'approved' and date_format(trans_date,'%Y-%m') = a.date_format(trans_date,'%Y-%m') group by extract(month from trans_date), extract(year from trans_date)) as approved_total_amount
from Transactions as a
group by extract(month from trans_date),extract(year from trans_date) , country
--Code sửa lại
with bang2 as (
    select id
    , case when country is null then 'no_value' else country end as country
    , state
    , amount
    , trans_date
from Transactions
)
, bang as(
select date_format(trans_date,'%Y-%m') as month
, country
, count(trans_date) as trans_count
, sum(amount) as trans_total_amount
from bang2
group by extract(month from trans_date),extract(year from trans_date), country),
bang1 as (select date_format(trans_date,'%Y-%m') as month
, country
, count(trans_date) as approved_count
, sum(amount) as approved_total_amount
from bang2 
where state = 'approved'
group by extract(month from trans_date), extract(year from trans_date), country)

select a.month, case when a.country = 'no_value' then null else a.country end as country, a.trans_count, 
case when b.approved_count is null then 0 else b.approved_count end as approved_count
, a.trans_total_amount, 
case when b.approved_total_amount is null then 0 else b.approved_total_amount end as approved_total_amount
from bang as a
left join bang1 as b
on a.month = b.month and a.country = b.country

--Code refined
select date_format(trans_date, '%Y-%m') as month
, country
, count(*) as trans_count
, count(case when state = 'approved' then 1 else null end) as approved_count
, sum(amount) as trans_total_amount
, sum(case when state = 'approved' then amount else 0 end) as approved_total_amount
from Transactions
group by (date_format(trans_date, '%Y-%m')), country
