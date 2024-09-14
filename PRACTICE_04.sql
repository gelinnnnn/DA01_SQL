--Bài 1
SELECT
count(case 
when device_type = 'laptop' then 'laptop'
end) as laptop_views
,count(case 
when device_type in ('tablet', 'phone') then 'mobile'
end) as mobile_views
FROM viewership
--Bài 2
select *
, case when x+y > z and y+z > x and z+x > y and x > 0 and y>0 and z> 0 then 'Yes'
else 'No'
end as triangle
from Triangle
--Bài 3
SELECT 
round(cast(100.0*sum(CASE
when call_category = 'n/a' or call_category is null then 1
else 0
end)/count(*) as decimal),1) as categorized
FROM callers
  --Bài 4
select name
from Customer
where referee_id != 2 or referee_id is null
--Bài 5
count(case 
when pclass = 2 then 'second_class'
end) as second_class
