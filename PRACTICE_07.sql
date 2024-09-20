--Bài 1
select *
, lag(curr_year_spend) over (partition by product_id) as prev_year_spend
, round(100.00*curr_year_spend/lag(curr_year_spend) over (partition by product_id)-100.00,2) as yoy_rate
from (
SELECT extract(year from transaction_date) as yr, product_id 
, sum(spend) as curr_year_spend
from user_transactions
group by product_id, extract(year from transaction_date)
order by product_id,yr) as bang
--Bài 2
select card_name
, issued_amount from (
SELECT card_name
, issued_amount
, rank() over (partition by card_name order by issue_year, issue_month)
FROM monthly_cards_issued) as bang
where rank = 1 
order by issued_amount desc
--Tại sao code này sai?
SELECT card_name
, first_value (issued_amount) over (partition by card_name order by issue_year, issue_month) as issued_amount
FROM monthly_cards_issued
order by issued_amount
--Bài 3
select user_id
, spend
, transaction_date 
from (
SELECT *
, row_number() over(PARTITION BY user_id order by transaction_date)
from transactions) as bang
where row_number = 3
--Bài 4
select transaction_date
, user_id
, purchase_count from(
select 
row_number() over (partition by user_id order by transaction_date desc) as stt
, transaction_date
, user_id
, count(*) over (partition by user_id) as purchase_count
from user_transactions) as bang
where stt = 1
order by transaction_date
--Bài 5
--Cách 1
SELECT user_id
, tweet_date
, round(avg(tweet_count) over (partition by user_id order by tweet_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) as rolling_avg_3d
FROM tweets;
--Cách 2
select user_id
, tweet_date
, (case 
when previous_day is null and two_previous_day is null then 1.00*tweet_count
when two_previous_day is null then round(1.00*(tweet_count+previous_day)/2,2)
else round(1.00*(tweet_count+previous_day+two_previous_day)/3,2) 
end) as rolling_avg_3d
from (SELECT user_id
, tweet_date
, tweet_count
, lag(tweet_count) over (partition by user_id order by tweet_date) as previous_day
, lag(tweet_count,2) over (partition by user_id order by tweet_date) as two_previous_day
FROM tweets) as bang
--Bài 6
select count(*) as payment_count
from (
SELECT *
, lead(transaction_timestamp) over (partition by merchant_id,credit_card_id, amount order by transaction_timestamp ) as next_timestamp
from transactions) as bang
where next_timestamp is not null
and extract( epoch from next_timestamp - transaction_timestamp)/60 <=10
--Bài 7
select category
, product
, total_spend 
from (
select category
, product
, sum(spend) as total_spend
, rank () over (partition by category order by sum(spend) desc)
from product_spend
where extract(year from transaction_date) = 2022
group by category, product) as bang
where rank <=2
--Bài 8
select * from (
SELECT c.artist_name
, dense_rank() over (order by count(*) desc) as artist_rank
FROM global_song_rank as a  
join songs as b on a. song_id = b.song_id
join artists as c on b.artist_id = c.artist_id
where a.rank <=10
group by c.artist_name) as bang
where artist_rank <=5
