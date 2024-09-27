--Adhoc tasks
--Bai 1: 
/*Insight: Từ chart ta thấy
- Lượng khách hàng và lượng đơn hàng hoàn thành tăng đều theo thời gian
*/
SELECT FORMAT_TIMESTAMP('%Y-%m', delivered_at) as complete_date
, count(distinct user_id) as total_user
, count(order_id) as total_order
FROM bigquery-public-data.thelook_ecommerce.orders
where status = 'Complete' and FORMAT_TIMESTAMP('%Y-%m', delivered_at) between '2019-01' and '2022-04'
group by 1
order by complete_date
--Bai 2
/*Insight: Từ chart ta thấy
- Số khách hàng đặt hàng hằng tháng tăng theo thời gian, nhưng giá trị trung bình của đơn hàng vẫn dao động từ 58-61, chứng tỏ công ty chỉ đang mở rộng số lượng khách hàng trong cùng 1 segment
*/
select FORMAT_TIMESTAMP('%Y-%m', created_at) as order_date
, count(distinct user_id) as distinct_users
, sum(sale_price)/count(order_id) as average_order_value
from (
select a.order_id, a.user_id, a.created_at, b.sale_price
from bigquery-public-data.thelook_ecommerce.orders as a
join bigquery-public-data.thelook_ecommerce.order_items as b
on a.order_id = b.order_id
where FORMAT_TIMESTAMP('%Y-%m', a.created_at) between '2019-01' and '2022-04')
group by 1
order by 1

--Bai 3
/*Insight
- Xét trong cùng 1 giới, nữ càng nhỏ càng mua nhiều sản phẩm, tương tự với nam => Sản phẩm thu hút được độ tuổi nhỏ hơn
- Xét trong cùng độ tuổi, nam có xu hướng mua nhiều sản phẩm hơn nữ => Sản phẩm thu hút được nhiều phái nam hơn
*/
--Tim male
with bang1 as (select user_id
, first_name
, last_name
, gender
, age
, case when age = min_age then 'youngest'
when age = max_age then 'oldest'
end as tag
from (
select 
a.user_id
, b.first_name
, b.last_name
, b.gender
, b.age
, min(b.age) over () as min_age
, max(b.age) over () as max_age
from bigquery-public-data.thelook_ecommerce.orders as a
join bigquery-public-data.thelook_ecommerce.users as b on a.user_id = b.id
where FORMAT_TIMESTAMP('%Y-%m', a.created_at) between '2019-01' and '2022-04' and b.gender = 'M'))
--Tim female
, bang2 as (select user_id
, first_name
, last_name
, gender
, age
, case when age = min_age then 'youngest'
when age = max_age then 'oldest'
end as tag
from (
select 
a.user_id
, b.first_name
, b.last_name
, b.gender
, b.age
, min(b.age) over () as min_age
, max(b.age) over () as max_age
from bigquery-public-data.thelook_ecommerce.orders as a
join bigquery-public-data.thelook_ecommerce.users as b on a.user_id = b.id
where FORMAT_TIMESTAMP('%Y-%m', a.created_at) between '2019-01' and '2022-04' and b.gender = 'F'))


,categorized_users as (select * from bang1
where tag is not null
union all 
select * from bang2
where tag is not null)

select gender, tag, age, count(*) as so_luong
from categorized_users 
group by gender, tag, age

--Bài 4

with bang as (select *, dense_rank() over (partition by sale_time order by profit desc) as rank_per_month
from (
select FORMAT_TIMESTAMP('%Y-%m', created_at) as sale_time
, a.product_id
, b.name as product_name
, sum(a.sale_price) as sales
, sum(b.cost) as cost
, sum(a.sale_price - b.cost) as profit
from bigquery-public-data.thelook_ecommerce.order_items as a
join bigquery-public-data.thelook_ecommerce.products as b on a.product_id = b.id
where a.status <> 'Cancelled'
group by a.product_id, b.name, FORMAT_TIMESTAMP('%Y-%m', created_at)))
select *
from bang 
where rank_per_month <=5

--Bai 5 
select format_timestamp('%Y-%m-%d',a.created_at) as sale_day
, b.category as product_categories
, sum(a.sale_price) as revenue
from bigquery-public-data.thelook_ecommerce.order_items as a
join bigquery-public-data.thelook_ecommerce.products as b on a.product_id = b.id
where a.status <> 'Cancelled' and format_timestamp('%Y-%m-%d',a.created_at) between '2022-01-15' and '2022-04-15'
group by format_timestamp('%Y-%m-%d',a.created_at), b.category
order by sale_day, product_categories

/*Cohort Analysis*/
  --Bai 1
with bang as (select format_timestamp('%Y-%m', created_at) as day
, sum(sale_price) as TPV
, count(product_id) as TPO
from bigquery-public-data.thelook_ecommerce.order_items
where status <> 'Cancelled'
group by format_timestamp('%Y-%m',created_at)
)

, bang1 as (select
  format_timestamp('%Y-%m', b.created_at) as day
 , sum(cost) as Total_cost from bigquery-public-data.thelook_ecommerce.products as a
join bigquery-public-data.thelook_ecommerce.order_items as b on a.id = b.product_id
where b.status <> 'Cancelled'
group by format_timestamp('%Y-%m', b.created_at)
)


, bang2 as (select format_timestamp('%Y-%m', a.created_at) as Month
,extract(year from a.created_at) as Year
, c.category as Product_category 
, bang.TPV
, bang.TPO
, bang1.Total_cost
, CAST(a.created_at AS DATE) as original_time
from bigquery-public-data.thelook_ecommerce.orders as a
join bigquery-public-data.thelook_ecommerce.order_items as b on a.order_id = b.order_id 
join bigquery-public-data.thelook_ecommerce.products as c on b.product_id = c.id
join bang on format_timestamp('%Y-%m', a.created_at) = bang.day
join bang1 on format_timestamp('%Y-%m', a.created_at) = bang1.day
where b.status <> 'Cancelled')

select a.Month
, a.Year
, a.Product_Category
, a.TPV as TPV
, a.TPO as TPO
, (a.TPV - b.TPV)/b.TPV * 100.00 || '%' as Revenue_growth
, (a.TPO - b.TPO)/b.TPO * 100.00 || '%' as Order_growth
, a.Total_cost
, a.TPV - a.Total_cost as Total_profit
, (a.TPV - a.Total_cost)/a.Total_cost as Profit_to_cost_ratio
from bang2 as a
join bang2 as b on a.original_time = DATE_ADD(b.original_time, INTERVAL 1 MONTH) 
