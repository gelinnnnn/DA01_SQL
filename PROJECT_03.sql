--Bài 1
select  PRODUCTLINE, YEAR_ID, DEALSIZE
, sum(sales) as REVENUE
from public.sales_dataset_rfm_prj
group by  PRODUCTLINE, YEAR_ID, DEALSIZE
order by year_id, productline, dealsize
--Bài 2
  --Tháng 10 có đơn hàng 10165 cao nhất với giá trị 77809.37
select month_id,  sum(sales) as REVENUE, ordernumber as ORDER_NUMBER
from public.sales_dataset_rfm_prj
group by month_id, ordernumber
order by revenue desc
--Bai 3
  --Classic Cars có doanh số tốt nhất tháng 11 với doanh số là 825156.26
select productline
, sum(sales) as revenue
from public.sales_dataset_rfm_prj
where month_id = 11
group by productline
order by revenue desc
--Bài 4
  --Năm 2003 và 2004, sản phẩm thuộc productline Vintage Cars có doanh số cao nhất là 7310
-- Năm 2005, sản phẩm thuộc productline Motocycles có doanh số cao nhất là 11886.6
  select * from 
(select YEAR_ID
, PRODUCTLINE
, sales as revenue
, rank () over (partition by year_id order by sales desc) as rank
from public.sales_dataset_rfm_prj
where country = 'UK')
where rank = 1
--Bài 5
with bang as (select customer_id
, customer_name
, segment
, current_date - max(order_date) as R
, count(distinct order_id) as F
, sum(sales) as M
from (select a.customer_id
, a.customer_name
, a.segment
, b.order_id
, b.order_date
, b.sales
from public.customer as a
join public.sales as b on a.customer_id= b.customer_id)
group by customer_id, customer_name, segment)

, bang2 as (select a.customer_id
, a.customer_name
, a.segment
, concat (a.r_score, a.f_score, a.m_score) as rfm
, b.segment as rfm_segment
from (
select customer_id
, customer_name
, segment
, ntile(5) over (order by r desc) as r_score
, ntile(5) over (order by f) as f_score
, ntile(5) over (order by m) as m_score
from bang) as a
join public.segment_score as b on concat (a.r_score, a.f_score, a.m_score)= b.scores)

select rfm_segment 
, count(*) 
from bang2
group by rfm_segment
order by count desc

