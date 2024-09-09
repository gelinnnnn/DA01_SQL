---Bai 1
SELECT NAME
FROM CITY
WHERE population > 120000 and countrycode = 'USA'
---Bai 2
SELECT *
FROM CITY
WHERE COUNTRYCODE = 'JPN'
---Bai 3
SELECT CITY, STATE FROM STATION
---Bai 4
SELECT DISTINCT CITY FROM STATION
WHERE CITY LIKE 'a%' or CITY LIKE 'e%' or CITY LIKE 'i%' or CITY LIKE 'o%' or CITY LIKE 'u%' 
---Bai 5
SELECT DISTINCT CITY FROM STATION
WHERE CITY LIKE '%a' or CITY LIKE '%e' or CITY LIKE '%i' or CITY LIKE '%o' or CITY LIKE '%u' 
---Bai 6
SELECT DISTINCT CITY FROM STATION
WHERE CITY NOT LIKE 'a%' and CITY NOT LIKE 'e%' and CITY NOT LIKE 'i%' and CITY NOT LIKE 'o%' and CITY NOT LIKE 'u%' 
---Bai 7
select name
from Employee
order by name 
---Bai 8
select name
from Employee
where salary >2000
and months < 10
order by employee_id 
---Bai 9
select product_id
from Products
where low_fats = 'Y' and recyclable = 'Y'
---Bai 10
select name
from Customer
where referee_id != '2' or referee_id is null
---Bai 11
select name
, population
, area
from World
where area >=3000000 or population >=25000000
---Bai 12
select distinct author_id as id
from Views
where author_id = viewer_id
order by id asc
---Bai 13
SELECT part, assembly_step
from parts_assembly
where finish_date is null
---Bai 14
select * 
from lyft_drivers
where yearly_salary <=30000 or yearly_salary >70000
---Bai 15
select advertising_channel from uber_advertising
where money_spent > 100000 and year = '2019'
