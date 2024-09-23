--1
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN ordernumber TYPE integer USING (trim(ordernumber)::integer)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN quantityordered TYPE integer USING (trim(quantityordered)::integer)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN priceeach TYPE numeric USING (trim(priceeach)::numeric)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN orderlinenumber TYPE integer USING (trim(orderlinenumber)::integer)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN sales TYPE numeric USING (trim(sales)::numeric)
ALTER TABLE public.sales_dataset_rfm_prj
SET datestyle = 'ISO, MDY';
ALTER COLUMN orderdate TYPE date USING (trim(orderdate)::date)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN status TYPE varchar(9) USING (trim(status)::varchar(9))
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN productline TYPE varchar(20) USING (trim(productline)::varchar(20))
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN msrp TYPE integer USING (trim(msrp)::integer)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN productcode TYPE text USING (trim(productcode)::text)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN customername TYPE varchar(50) USING (trim(customername)::varchar(50))
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN phone TYPE text USING (trim(phone)::text)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN addressline1 TYPE text USING (trim(addressline1)::text)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN addressline2 TYPE text USING (trim(addressline2)::text)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN city TYPE text USING (trim(city)::text)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN state TYPE text USING (trim(state)::text)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN postalcode TYPE text USING (trim(postalcode)::text)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN country TYPE varchar(20) USING (trim(country)::varchar(20))
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN territory TYPE varchar(10) USING (trim(territory)::varchar(10))
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN contactfullname TYPE text USING (trim(contactfullname)::text)
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN dealsize TYPE varchar(10) USING (trim(dealsize)::varchar(10))

--2: Không có giá trị null ở các trường này
select * 
from public.sales_dataset_rfm_prj
where ordernumber is null or QUANTITYORDERED is null or PRICEEACH is null or ORDERLINENUMBER is null or Sales is null or Orderdate is null

--3
alter table public.sales_dataset_rfm_prj
add column contactfirstname varchar(20)
alter table public.sales_dataset_rfm_prj
add column contactlastname varchar(20)
update public.sales_dataset_rfm_prj
set contactfirstname = upper(left(contactfullname,1))||substring(contactfullname, 2, position('-' in contactfullname)-2) -- Không thể + text mà phải || ???
update public.sales_dataset_rfm_prj
set contactlastname = upper(substring(contactfullname, position('-' in contactfullname)+1,1)) ||substring(contactfullname, position('-' in contactfullname)+2)

--4
alter table public.sales_dataset_rfm_prj
add column  QTR_ID integer
alter table public.sales_dataset_rfm_prj
add column  MONTH_ID integer
alter table public.sales_dataset_rfm_prj
add column  YEAR_ID integer
update public.sales_dataset_rfm_prj
set qtr_id = floor((extract(month from orderdate)-1)/3)+1
update public.sales_dataset_rfm_prj
set month_id = extract(month from orderdate)
update public.sales_dataset_rfm_prj
set year_id= extract(year from orderdate)

--5
  --Cách 1: Sử dụng box-plot
with cte as (select 
Q1
, Q3
, IQR
, Q1-1.5*IQR as min_value
, Q3 + 1.5*IQR as max_value
from (select percentile_cont(0.25) within group (order by quantityordered) as Q1
, percentile_cont(0.75) within group (order by quantityordered) as Q3
, percentile_cont(0.75) within group (order by quantityordered) - percentile_cont(0.25) within group (order by quantityordered) as IQR
from public.sales_dataset_rfm_prj) as bang)

select *
from public.sales_dataset_rfm_prj
where quantityordered < (select min_value from cte) or quantityordered > (select max_value from cte)

delete from public.sales_dataset_rfm_prj
where ordernumber in (select ordernumber
from public.sales_dataset_rfm_prj
where quantityordered < (select min_value from cte) or quantityordered > (select max_value from cte))
--Cách 2: Sử dụng z-score
with cte as (select quantityordered
, (select avg(quantityordered) from public.sales_dataset_rfm_prj)
, (select stddev(quantityordered) from public.sales_dataset_rfm_prj)
, ((select avg(quantityordered) from public.sales_dataset_rfm_prj) - (select stddev(quantityordered) from public.sales_dataset_rfm_prj))/quantityordered as z_score
from public.sales_dataset_rfm_prj)

select quantityordered
from cte 
where z_score > 2

