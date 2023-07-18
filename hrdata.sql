create database hrdata;
use hrdata;

-- DATA CLEAN AND PREPROCESSING
ALTER TABLE  hrdata
CHANGE ï»¿emp_no emp_id INT;

select * from hrdata;

DESCRIBE hrdata;

-- 1. Count total employee in data totalemployee
SELECT  count(employee_count) as total_employee 
FROM hrdata;
-- and
-- Count total employee in data present_employe
SELECT sum(active_employee) as total_employee 
FROM hrdata;

-- 2. Count total employee  from sales in present_employee
SELECT sum(active_employee) as total_employee 
FROM hrdata
WHERE department='sales';


-- 3. write a query how many employee left company from each dept of job_role
SELECT department ,job_role,sum(employee_count-active_employee) as leftout
FROM hrdata
GROUP BY  1,2
ORDER BY department;

-- 4. write a query total percentage of employee left company each dept
SELECT department, round((sum(employee_count)-sum(active_employee))/sum(employee_count)*100,2) as leftout
FROM hrdata
GROUP BY 1;

-- or
WITH  present_emp as 
     (SELECT  department, sum(active_employee) as present
       FROM hrdata
       GROUP BY 1
),
   total_emp as (
       SELECT department,sum(employee_count) as tmp
	   FROM hrdata
	   GROUP BY 1
 )
 SELECT present_emp.department,round(avg(tmp-present)/tmp,2)*100 as perc
 FROM present_emp JOIN total_emp
 ON present_emp.department=total_emp.department
 GROUP BY 1;
    
-- 5. write a query how many of employee are over aged 40  each dept and job_role only present_employye 
SELECT department,job_role,count(employee_count) as no_of_emp
FROM hrdata
WHERE age>40  
GROUP BY 1,2;

-- 6. Create pivot table for present employees and counthow many employees are left from ech dept

SELECT  department as DEPT ,sum(employee_count) TOTAL_EMP
 , sum(case when gender='male' then active_employee end ) as MALE_EMP
 , sum(case when gender='female' then active_employee end ) as FEMALE_EMP
 , sum(active_employee) as Present_emp,sum(employee_count)-sum(active_employee) as 'left'
FROM hrdata
GROUP BY 1;

 -- 7. Write a query for each depth if age less than 25 then consider as fresher, age_between  25 to 34 then mid_senio,
--     age_between 35 t 44 ASSC_SENIOR, age_between 45 to 54 senior, age greater than 55 directors of the dept 
SELECT department as DEPTH,sum(employee_count) AS NO_OF_EMP
	, sum(case  when age< 25 then employee_count end ) AS 	FRESHER
    , sum(case  when age>=25 and  age<=34 then employee_count  end) AS  MID_SENIOR
    , sum(case  when age>=35 and  age<=44 then employee_count end ) AS  ASSC_SENIOR
    , sum(case  when age>=45 and  age<=55 then employee_count end ) AS  SENIOR
	, sum(case  when age>=56 then employee_count end) AS DIRECTORS
FROM  hrdata
GROUP BY 1;


-- 8.write a query gender wise how many employees are age greater than 30 on active_employee
SELECT department,sum(active_employee) as present_emp
  ,sum(case when age>30 and gender='male' then active_employee end)  as male_emp
  ,sum(case when age>30 and gender='female' then active_employee end) as female_emp
FROM hrdata
GROUP BY 1;

-- 9. write a query employee marital_status only on  the basis of job_role present_employee
SELECT job_role, sum(active_employee) as active_emp
    , sum(case when marital_status ='married'then active_employee  end)as married_emp
    , sum(case when marital_status ='single'then active_employee   end )as unmarried_emp
    , sum(case when marital_status ='divorced'then active_employee end )as divorced_emp
FROM hrdata
GROUP BY job_role;
   
-- 10.write a query employee marital_status on as per depth wise
SELECT department,sum(employee_count) as total_employee
	,sum(case when marital_status ='married'then 1  end)as married_emp
	,sum(case when marital_status ='single'then 1  end )as unmarried_emp
	,sum(case when marital_status ='divorced'then 1   end )as divorced_emp
FROM hrdata
GROUP BY department;

-- 11.write a query to find marital_status of who left_out company from each dept
WITH CTE as 
(SELECT department ,marital_status, (sum(employee_count)-sum(active_employee)) as left_emp
     FROM hrdata
     GROUP BY department,marital_status)
 SELECT department,sum(left_emp) as total_employee
     ,sum(case when marital_status ='married'then left_emp  end) as married_emp
     ,sum(case when marital_status ='single'then left_emp   end ) as unmarried_emp
     ,sum(case when marital_status ='divorced'then left_emp end ) as divorced_emp
FROM CTE
GROUP BY department;

-- 12. Attrion rate of employee
SELECT  (sum(employee_count)-sum(active_employee))/sum(employee_count)*100 as attrition
from hrdata;

-- 13.gender wise avg age of employees
SELECT gender,ROUND(AVG(age)) AS avg_age 
FROM  hrdata 
GROUP BY 1;

SELECT gender, SUM(active_employee) AS employee
FROM hrdata
GROUP BY 1;

 



