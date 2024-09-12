--Bài 1
select name
from students
where marks > 75
order by right(name,3), id
  --Bai 2
select user_id
, concat(left(upper(name),1), substring(lower(name),2 )) as name
from Users
order by user_id
--Bài 3
select manufacturer
, concat('$', round((sum(total_sales)/1000000),0), ' ', 'million')
from pharmacy_sales
group by manufacturer
order by sum(total_sales) desc, manufacturer
--Bài 4
select extract(month from submit_date) as mth
, product_id
, round(avg(stars),2) as avg_stars
from reviews
group by product_id, extract(month from submit_date)
order by extract(month from submit_date), product_id
--Bài 5 
select sender_id
, count(*)
from messages
where extract(month from sent_date) = 8 and extract(year from sent_date) = 2022
group by sender_id
order by count(*) desc
limit 2
--Bài 6
select tweet_id
from Tweets
where length(content) > 15
--Bài 7
SELECT 
    activity_date AS day, 
    COUNT(DISTINCT user_id) AS active_users
FROM 
    Activity
WHERE 
    DATEDIFF('2019-07-27', activity_date) < 30 AND DATEDIFF('2019-07-27', activity_date)>=0
GROUP BY activity_date
--Bài 8
select count(*)
from employees
where extract(year from joining_date) = 2022 and extract( month from joining_date) between 1 and 7
--Bài 9
select position('a' in first_name)
from worker
where first_name ='Amitah'
--Bài 10
select substring(title, length(winery)+2, 4)
from winemag_p2
where country = 'Macedonia'
