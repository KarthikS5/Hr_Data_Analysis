create database hrdata;
use hrdata;

alter table  hrdata
change ï»¿emp_no emp_id int;

select * from hrdata;

-- 1. Count total employee in data totalemployee
select count(employee_count) as total_employee 
from hrdata;
-- and
-- Count total employee in data present_employe
select sum(active_employee) as total_employee 
from hrdata;

-- 2. Count total employee  from sales in present_employee
select sum(active_employee) as total_employee 
from hrdata
where department='sales';


-- 3. write a query how many employee left company from each dept of job_role
select department ,job_role,sum(employee_count-active_employee) as leftout
from hrdata
group by 1,2
order by department;

-- 4. write a query total percentage of employee left company each dept
select department, round((sum(employee_count)-sum(active_employee))/sum(employee_count)*100,2) as leftout
from hrdata
group by 1;

-- or
with present_emp as 
     (select department, sum(active_employee) as present
       from hrdata
       group by 1
),
   total_emp as (
       select department,sum(employee_count) as tmp
       from hrdata
        group by 1
 )
 select present_emp.department,round(avg(tmp-present)/tmp,2)*100 as perc
    from present_emp join total_emp
    on present_emp.department=total_emp.department
    group by 1;
    
-- 5. write a query how many of employee are over aged 40  each dept and job_role only present_employye 
select department,job_role,count(employee_count) as no_of_emp
from hrdata
where age>40  
group by 1,2;

-- 6. write a query total number of employees gebder_wise are in dept wise
select department AS DEPT,sum(employee_count) as NO_OF_EMP
 , sum(case when gender='male' then employee_count end ) as MALE_EMP
 , sum(case when gender='female' then employee_count end ) as FEMALE_EMP
from hrdata
group by 1
order by department;


-- 7. write a query for data if under 25 then under_age, 25 to 34 professioanl, 35 to 44 associate_sen,
-- 44 to 54 is senior,above 55 they most_exp
select department as DEPTH
	, sum(case when age <25 then employee_count end ) AS UNDER_AGE
    , sum( case   when age>=25 and age<=34 then employee_count  end) AS  PROFESSIONAL
    , sum(case when age>=35 and age<=44 then employee_count end ) AS ASSC_SENIOR
    , sum( case when age>=45 and  age<=54 then employee_count end ) AS SENIOR
	, sum(case  when age>55 then employee_count end) AS MOST_EXPERIANCED
from hrdata
group by 1;


-- 8.write a query on how many employees are age greater than 30 FROM present_employee
select department,sum(active_employee) as present_emp
  ,sum(case when age>30 and gender='male' then active_employee end)  as male_emp
  ,sum(case when age>30 and gender='female' then active_employee end) as female_emp
from hrdata
group by 1;

-- 9. write a query employee marital_status only on present_employee
SELECT department,sum(active_employee) as active_emp
    , sum(case when marital_status ='married'then active_employee  end)as married_emp
    , sum(case when marital_status ='single'then active_employee   end )as unmarried_emp
    , sum(case when marital_status ='divorced'then active_employee end )as divorced_emp
FROM hrdata
GROUP BY department;
   
-- 10.write a query employee marital_status on as per depth wise
   SELECT department,count(employee_count) as total_employee
        ,sum(case when marital_status ='married'then 1  end)as married_emp
        ,sum(case when marital_status ='single'then 1  end )as unmarried_emp
		,sum(case when marital_status ='divorced'then 1   end )as divorced_emp
FROM hrdata
GROUP BY department;

-- 11.write a query to find marital_status of who left_out company from each dept
with CTE as 
(SELECT department ,marital_status, (count(employee_count)-sum(active_employee)) as left_emp
     FROM hrdata
     GROUP BY department,marital_status)
 SELECT department,sum(left_emp) as total_employee
     ,sum(case when marital_status ='married'then left_emp  end) as married_emp
     ,sum(case when marital_status ='single'then left_emp   end ) as unmarried_emp
     ,sum(case when marital_status ='divorced'then left_emp end ) as divorced_emp
FROM CTE
GROUP BY department;

-- 12. Attrion rate of employee
select (sum(employee_count)-sum(active_employee))/sum(employee_count)*100 as attrition
from hrdata