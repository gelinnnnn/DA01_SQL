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
