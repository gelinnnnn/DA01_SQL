--Bài 1
select round((100.00*sum(status)/ count(*)),2) as immediate_percentage 
from (
select 
case when order_date = customer_pref_delivery_date then 1 
else 0 end as status
, rank () over (partition by  customer_id order by order_date )
from Delivery) as bang
where rank = 1
--Bài 2 (Mất nhiều thời gian vì bỏ sót yêu cầu: phải là ngày đầu tiên người đó đăng nhập)
select round(1.00*count(distinct fraction)/count(distinct player_id),2) as fraction
from (
select 
a.player_id,
b.player_id + case when row_number() over(partition by a.player_id order by a.event_date) = 2 then 0 else null end as fraction 
from Activity as a
left join Activity as b on a.event_date = b.event_date + 1 and a.player_id = b.player_id) as bang
--Bài 3
select id,
case when sorted is not null then sorted else student end as student from (
select id
, student
, case when id % 2 = 0 then lag(student) over () 
else lead(student) over () end as sorted
from Seat)
--Bài 4
with bang as (
    select visited_on
    , sum(amount) as amount
    from Customer
    group by visited_on)
select visited_on, amount, average_amount
from (
select visited_on, 
sum(amount) over (order by visited_on rows between 6 preceding and current row) as amount
, round(avg(amount) over (order by visited_on rows between 6 preceding and current row),2) as average_amount
, row_number () over(order by visited_on) as stt 
from bang)
where stt >=7 
order by visited_on
--Bài 5 (để loại bỏ các giá trị trùng lặp trong một cột phải nghĩ ngay đến hàm count)
select round(cast(sum(tiv_2016) as decimal),2) as tiv_2016
from (
select 
pid, tiv_2015, tiv_2016,
lat || ',' || lon as location
, count( lat || ',' || lon) over (partition by lat || ',' || lon) as duplicate_location
, count(tiv_2015) over (partition by tiv_2015) as duplicate_tiv_2015
from Insurance)
where duplicate_location =1 and duplicate_tiv_2015 > 1
--Bài 6
select Department, Employee, Salary from (
select b.name as Department , a.name as Employee, a.salary as Salary
, dense_rank () over (partition by a.departmentId order by salary desc) as stt
from Employee a
join Department b on a.departmentId = b.id)
where stt<=3
--Bài 7
select person_name from (select *
, row_number () over (order by total_weight desc) as stt
from (
select
person_name
, sum (weight) over (order by turn) as total_weight
from Queue)
where total_weight <=1000)
where stt = 1
--Bài 8 (cách làm mất 1 tiếng rưỡi để nghĩ ra :))
with bang as (select product_id, new_price as price, change_date from Products
where change_date <= '2019-08-16')
,bang2 as (select product_id, 10 as price, change_date
from Products
where not product_id in (select product_id from Products where change_date <= '2019-08-16'))

select product_id, price  
from (select *, row_number () over (partition by product_id order by change_date desc) from (select *
from bang 
union all
select *
from bang2))
where row_number = 1
--Code tham khảo
select distinct a.product_id, coalesce(b.new_price, 10) as price from Products as a
left join
(select product_id, rank() over(partition by product_id order by change_date DESC) as xrank, new_price from Products
where change_date<='2019-08-16') as b
on a.product_id=b.product_id and b.xrank=1
order by 2 DESC
--Điểm khác biệt: vì phải dựa vào change_date để row_number nên phải tách change_date ra 2 khoảng
