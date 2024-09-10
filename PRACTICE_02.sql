--Bai 1
select distinct city
from station
where id % 2 = 0
--Bai 2
select count(city)- count(distinct city)
from station
--Bai 4
select round(cast(sum(item_count*order_occurrences)/sum(order_occurrences) as decimal),1)
from items_per_order
--Bai 5
SELECT candidate_id
from candidates
where skill in ('Python', 'Tableau', 'PostgreSQL')
group by candidate_id
having count(skill) = 3
--Bai 6
SELECT user_id, date(max(post_date)) - date(min(post_date)) as days_between
from posts
where extract (year from post_date)=2021
group by user_id
having count(post_id) >=2
--Bai 7
SELECT card_name
, max(issued_amount) - min(issued_amount) as difference
FROM monthly_cards_issued
group by card_name
order by difference desc
--Bai 8
SELECT manufacturer, count(drug) as drug_count, abs(sum(cogs) - sum(total_sales)) as total_loss
FROM pharmacy_sales
where total_sales < cogs
group by manufacturer
order by total_loss desc
--Bai 9
select *
from Cinema
where id mod 2 <> 0 and description <> 'boring'
order by rating desc
--Bai 10
select teacher_id,
count(distinct subject_id) as cnt
from Teacher
group by teacher_id
--Bai 11
select user_id
, count(*) as followers_count
from Followers
group by user_id
order by user_id
--Bai 12
select class
from Courses
group by class
having count(student) >=5
