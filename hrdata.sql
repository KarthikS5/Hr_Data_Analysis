create database hrdata;
use hrdata;

SELECT  * FROM hrdata;
DESCRIBE hrdata; # describe the data 

-- .DATA CLEAN AND PREPROCESSING
# Rename the column
ALTER TABLE  hrdata
CHANGE ï»¿emp_no emp_id INT;

# Change the data types
ALTER TABLE hrdata
MODIFY gender VARCHAR(10),
MODIFY marital_status VARCHAR(10),
MODIFY age_band VARCHAR(10),
MODIFY department VARCHAR(10),
MODIFY education VARCHAR(50),
MODIFY education_field VARCHAR(50),
MODIFY job_role VARCHAR(50),
MODIFY business_travel VARCHAR(50),
MODIFY attrition VARCHAR(10),
MODIFY attrition_label VARCHAR(30);


-- 1. Count total employee in  totalemployee

SELECT 
    SUM(employee_count) AS total_employee
FROM
    hrdata;

-- and

-- Count total employee in  present_employe

SELECT 
    SUM(active_employee) AS present_employee
FROM
    hrdata;

-- 2. write a query how many employee left company from each dept of job_role

SELECT 
    department,
    job_role,
    SUM(employee_count - active_employee) AS emp_left
FROM
    hrdata
GROUP BY 1 , 2
ORDER BY department;

-- 3. write a query total percentage of employee left company each dept
SELECT 
    department,
    ROUND((SUM(employee_count) - SUM(active_employee)) / SUM(employee_count) * 100,
            2) AS perc_lefjob
FROM
    hrdata
GROUP BY 1;

-- or
WITH  present_emp as 
(SELECT 
    department, SUM(active_employee) AS present
FROM
    hrdata
GROUP BY 1
),
   total_emp as (
       SELECT 
    department, SUM(employee_count) AS tmp
FROM
    hrdata
GROUP BY 1
 )
SELECT 
    present_emp.department,
    ROUND((tmp - present) / tmp, 2) * 100 AS perc
FROM
    present_emp
        JOIN
    total_emp ON present_emp.department = total_emp.department;

    
-- 4. Create pivot table for present employees and count how many employees are left from ech dept

SELECT 
    department AS DEPT,
    SUM(employee_count) TOTAL_EMP,
    SUM(CASE
            WHEN gender = 'male' THEN active_employee END) AS MALE_EMP,
    SUM(CASE
            WHEN gender = 'female' THEN active_employee END) AS FEMALE_EMP,
    SUM(active_employee) AS Present_emp,
    SUM(employee_count) - SUM(active_employee) AS 'left'
FROM
    hrdata
GROUP BY 1;



 -- 5. Write a query for each depth if age less than 25 then consider as a fresher, age_between  25 to 34 then mid_senio,
--     age_between 35 t 44 ASSC_SENIOR, age_between 45 to 54 senior, age greater than 55 directors of the dept 
SELECT 
    department AS DEPTH,
    SUM(employee_count) AS NO_OF_EMP,
    SUM(CASE
           WHEN age < 25 THEN employee_count END) AS FRESHER,
    SUM(CASE
           WHEN age >= 25 AND age <= 34 THEN employee_count END) AS MID_SENIOR,
    SUM(CASE
		   WHEN age >= 35 AND age <= 44 THEN employee_count END) AS ASSC_SENIOR,
    SUM(CASE
		   WHEN age >= 45 AND age <= 55 THEN employee_count END) AS SENIOR,
    SUM(CASE
           WHEN age >= 56 THEN employee_count END) AS DIRECTORS
FROM
    hrdata
GROUP BY 1;




-- 6. Shows the employees ages of lowest and highest age for each department as gender_wise

WITH cte AS 
(SELECT department,gender,age
	   , DENSE_RANK() OVER(PARTITION BY department, gender  ORDER BY age  ) AS lowest_age
       , DENSE_RANK() OVER(PARTITION BY department, gender  ORDER BY age  DESC )AS highest_age
FROM hrdata)
 SELECT department
     , MIN(CASE WHEN lowest_age=1  AND  gender='female' THEN age  END) AS low_age_female 
     , MAX(CASE WHEN highest_age=1 AND  gender='female' THEN age END) AS high_age_female 
     , MIN(CASE WHEN lowest_age=1  AND  gender='male'  THEN age  END) AS low_age_male
     , MAX(CASE WHEN highest_age=1 AND  gender='male'  THEN age END) AS high_age_male
FROM  cte
GROUP BY department;


-- 7.write a query gender wise how many employees are age greater than 30 present_employee

SELECT department,SUM(active_employee) AS present_emp
  , SUM(CASE WHEN age>30 AND gender='male'  THEN active_employee END) AS male_emp
  , SUM(CASE WHEN age>30 AND gender='female'THEN active_employee END) AS female_emp
FROM hrdata
GROUP BY 1;

-- 8. write a query employee marital_status only on the basis of job_role present_employee

SELECT job_role, SUM(active_employee) AS active_emp
    , SUM(CASE WHEN marital_status ='married' THEN active_employee  END) AS married_emp
    , SUM(CASE WHEN marital_status ='single'  THEN active_employee  END) AS unmarried_emp
    , SUM(CASE WHEN marital_status ='divorced'THEN active_employee  END) AS divorced_emp
FROM hrdata
GROUP BY job_role;
   
-- 9.write a query employee marital_status on as per depth_wise

SELECT department,SUM(employee_count) AS total_employee
	, SUM(CASE WHEN marital_status ='married'THEN 1  END)AS married_emp
	, SUM(CASE WHEN marital_status ='single' THEN 1  END)AS unmarried_emp
	, SUM(CASE WHEN marital_status ='divorced'THEN 1 END)AS divorced_emp
FROM hrdata
GROUP BY department;

-- 10.write a query to find the marital_status of who leaves the company from each dept

WITH CTE AS 
(SELECT department ,marital_status, (SUM(employee_count)-SUM(active_employee)) as emp_leaves
     FROM hrdata
     GROUP BY department,marital_status)
 SELECT department,sum(emp_leaves) as total_employee
     , SUM(CASE WHEN marital_status ='married' THEN emp_leaves  end) AS married_emp
     , SUM(CASE WHEN marital_status ='single'  THEN emp_leaves  end) AS unmarried_emp
     , SUM(CASE WHEN marital_status ='divorced'THEN emp_leaves  end) AS divorced_emp
FROM CTE
GROUP BY department;

-- 11. write  a query perform a pivot table displays the employees whose job satisfaction based on education qualification
     #    and total number of employee each star

(SELECT department, education
	, SUM(CASE WHEN job_satisfaction = 4 THEN active_employee ELSE 0 END)AS '4-Star'
	, SUM(CASE WHEN job_satisfaction = 3 THEN active_employee ELSE 0 END)AS '3-Star'
	, SUM(CASE WHEN job_satisfaction = 2 THEN active_employee ELSE 0 END)AS '2-Star'
    , SUM(CASE WHEN job_satisfaction = 1 THEN active_employee ELSE 0 END)AS '1-Star'
    , SUM(active_employee) AS present
FROM hrdata
GROUP BY department,education
ORDER BY department  )
UNION 
(SELECT 'Dept 'department, 'Total' education
    , SUM(CASE WHEN job_satisfaction = 4 THEN active_employee ELSE 0 END)AS '4-Star'
	, SUM(CASE WHEN job_satisfaction = 3 THEN active_employee ELSE 0 END)AS '3-Star'
	, SUM(CASE WHEN job_satisfaction = 2 THEN active_employee ELSE 0 END)AS '2-Star'
    , SUM(CASE WHEN job_satisfaction = 1 THEN active_employee ELSE 0 END)AS '1-Star'
    , SUM(active_employee) AS present
FROM hrdata);

-- 12. Attrion rate of employee

SELECT 
    (SUM(employee_count) - SUM(active_employee)) / SUM(employee_count) * 100 AS attrition
FROM
    hrdata;

-- 13.gender wise avg age of employees

 SELECT 
    gender, ROUND(AVG(age)) AS avg_age
FROM
    hrdata
GROUP BY 1;

 # 14.Write a query to fecth the total number of employees present iin gender wise
 
SELECT gender, SUM(active_employee) AS employee
FROM hrdata
GROUP BY 1
;

