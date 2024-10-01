--Adhoc tasks
--Bai 1: 
/*Domain knowledge ngành TMĐT:
- Thời gian đặt hàng: created_at
- Thời gian thanh toán:
- Thời gian giao hàng cho vận chuyển/Thời gian: shipped_at
- Thời gian hoàn thành: delivered_at
- Khái niệm đơn hàng, mã đơn hàng: 
+ Nếu 2 sản phẩm (có thể giống hoặc khác của cùng 1 cửa hàng và được đặt cùng lúc thì được tính chung là 1 mã đơn hàng
+ Nếu 2 sản phẩm của 2 cửa hàng khác nhau, được đặt cùng lúc thì tính là 2 mã đơn hàng khác nhau
+ Mỗi mã đơn hàng được tính là một đơn hay mỗi sản phẩm được tính là một đơn?
*/
/*Insight: Từ chart ta thấy
- Lượng khách hàng và lượng đơn hàng hoàn thành tăng đều theo thời gian
- Trong giai đoạn 2019-tháng 1 năm 2020, người tiêu dùng có xu hướng mua sắm nhiều hơn bình thường do các chương trình khuyến mãi cuối năm
- Tháng 7 năm 2021 ghi nhận lượng mua hàng tăng bất thường, trái ngược với lượng mua giảm sút so với cùng kì năm 2020
*/
Select 
FORMAT_DATE('%Y-%m', t2.delivered_at) as month_year, 
count(DISTINCT t1.user_id) as total_user,
count(t1.ORDER_id) as total_order
from bigquery-public-data.thelook_ecommerce.orders as t1
Join bigquery-public-data.thelook_ecommerce.order_items as t2 
on t1.order_id=t2.order_id
Where t1.status='Complete' and 
t2.delivered_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00'
Group by month_year
ORDER BY month_year
  
--Bai 2
  /*Kết quả sai lệch là do: created_at của 2 bảng khác nhau, ví dụ ID 90832 ở bảng orders được tạo vào ngày 31.1, trong khi được tạo vào 1/2 ở bảng order_items*/
/*Insight: Từ chart ta thấy
- Số khách hàng đặt hàng hằng tháng tăng theo thời gian, nhưng giá trị trung bình của đơn hàng vẫn dao động từ 58-61, chứng tỏ công ty chỉ đang mở rộng số lượng khách hàng trong cùng 1 segment
- Giai đoạn năm 2019 do số lượng người dùng ít khiến giá trị đơn hàng trung bình qua các tháng có tỷ lệ biến động cao.
- Giai đoạn từ cuối năm 2019 lượng người dùng ổn định trên 400 và nhìn chung tiếp tục tăng qua các tháng, giá trị đơn hàng trung bình qua các tháng ổn định ở mức ~80-90
*/
Select 
FORMAT_DATE('%Y-%m', created_at) as month_year,
count(DISTINCT user_id) as distinct_users,
round(sum(sale_price)/count(distinct order_id),2) as average_order_value
from bigquery-public-data.thelook_ecommerce.order_items
Where created_at BETWEEN '2019-01-01 00:00:00' AND '2022-05-01 00:00:00'
Group by month_year
ORDER BY month_year

--Bai 3 
  /*Nếu chọn created_at của bảng users sẽ khác so với created_at của bảng orders*/
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

select gender, tag, age, count(distinct user_id) as so_luong
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
  /*Hai bên đang hiểu sai ý nhau:
- Ý bài làm của mình là tăng trưởng theo tháng, tức là tính tổng lợi nhuận của tất cả các category
- Còn bài của chị Julie là tính tăng trưởng của từng category theo từng tháng*/
/*Note: Mình quên mất tính năng của Lag (partition by Month)*/

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

--Bai 2
/*Bổ sung insight:
Nhìn chung hằng tháng TheLook ghi nhận số lượng người dùng mới tăng dần đều, thể hiện chiến dịch quảng cáo tiếp cận người dùng
mới có hiệu quả.
Tuy nhiên trong giai đoạn 4 tháng đầu tính từ lần mua hàng/sử dụng trang thương mại điện tử TheLook, tỷ lệ người dùng cũ
quay lại sử dụng trong tháng kế tiếp khá thấp: dao động dưới 10% trong giai đoạn từ 2019-01 đến 2023-07 và tăng lên mức 
trên 10% trong những tháng còn lại của năm 2023, trong đó cao nhất là tháng đầu tiên sau 2023-10 với 18.28%.
 --> Tỷ lệ khách hàng trung thành thấp, TheLook nên xem xét cách quảng bá để thiếp lập và tiếp cận nhóm khách hàng trung thành
nhằm tăng doanh thu từ nhóm này và tiết kiệm các chi phí marketing*/

  --Cách 1: Không tối ưu vì có thể có nhiều user_id trong cùng 1 tháng, lúc đó cùng xếp rank 1, join sẽ rất tốn dữ liệu
  --Bước 1: Tìm tháng mua hàng đầu tiên của khách
with bang as (select
date_trunc(cast(created_at as date),month) as time /*Sử dụng date_trunc, month để chuyển toàn bộ về ngày 1*/
, user_id
, dense_rank() over (partition by user_id order by date_trunc(cast(created_at as date),month)) as stt
from bigquery-public-data.thelook_ecommerce.order_items
order by time)
, bang1 as (select user_id, time as adjusted_time
from bang where stt = 1)

--Bước 2: Tìm index = chênh lệch giữa ngày mua hiện tại và ngày mua đầu tiên
, bang2 as 
(select index
, count( distinct user_id) as so_luong
, cohort_date
from (
select 12*(extract(year from time)- extract(year from bang1.adjusted_time)) + extract(month from time)- extract(month from bang1.adjusted_time) + 1 as index
, bang.user_id
, bang1.adjusted_time as cohort_date ---Chính cái dòng này, mình đã nhầm sang bang.time mà mất gần 2 tiếng rưỡi để tìm ra lỗi sai
from bang 
join bang1 on bang.user_id = bang1.user_id)
group by index, cohort_date
order by cohort_date)

--Bước 3: Tìm customer_retention
select cohort_date, 
sum(case when index = 1 then so_luong else 0 end) as n1
, sum(case when index = 2 then so_luong else 0 end) as n2
, sum(case when index = 3 then so_luong else 0 end) as n3
, sum(case when index = 4 then so_luong else 0 end) as n4
from bang2
group by cohort_date
order by cohort_date

--Cách 2
With a as
(Select user_id, amount, FORMAT_DATE('%Y-%m', first_purchase_date) as cohort_month,
created_at,
(Extract(year from created_at) - extract(year from first_purchase_date))*12 
  + Extract(MONTH from created_at) - extract(MONTH from first_purchase_date) +1
  as index
from 
(
Select user_id, 
round(sale_price,2) as amount,
Min(created_at) OVER (PARTITION BY user_id) as first_purchase_date,
created_at
from bigquery-public-data.thelook_ecommerce.order_items 
) as b),
cohort_data as
(
Select cohort_month, 
index,
COUNT(DISTINCT user_id) as user_count,
round(SUM(amount),2) as revenue
from a
Group by cohort_month, index
ORDER BY INDEX
)
--CUSTOMER COHORT-- 

Select 
cohort_month,
Sum(case when index=1 then user_count else 0 end) as m1,
Sum(case when index=2 then user_count else 0 end) as m2,
Sum(case when index=3 then user_count else 0 end) as m3,
Sum(case when index=4 then user_count else 0 end) as m4
from cohort_data
Group by cohort_month
Order by cohort_month


