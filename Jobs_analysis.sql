-- data : salaries.csv taken from kaggle
-- queried using MySQL


/*1. Pinpoint Countries who give work fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD*/
SELECT DISTINCT(company_location) 
FROM salaries 
WHERE job_title like '%Manager%' and salary_IN_usd > 90000 and remote_ratio= 100;


/*2. How many people were employed IN different types of companies AS per their size IN 2021.*/
SELECT company_size, COUNT(company_size) AS 'Count of employees' 
FROM salaries 
WHERE work_year = 2021 
GROUP BY company_size;


/*3. Imagine you are a talent Acquisition specialist Working for an International recruitment agency. Your Task is to identify the top 3 job titles that 
command the highest average salary Among part-time Positions IN the year 2023.*/
SELECT job_title, AVG(salary_in_usd) AS 'average' 
FROM salaries  
WHERE employment_type = 'PT'  
GROUP BY job_title 
ORDER BY AVG(salary_IN_usd) DESC 
LIMIT 3;   


/*4. AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. you're tasked WITH 
Identifying top 5 Country Having  greatest count of large(company size) number of companies.*/
SELECT company_location, COUNT(company_size) AS 'cnt' 
FROM (
    SELECT * FROM salaries WHERE experience_level ='EN' AND company_size='L'
) AS t  
GROUP BY company_location 
ORDER BY cnt DESC
LIMIT 5;


/*5. As a database analyst you have been assigned the task to Select Countries where average mid-level salary is higher than overall mid-level salary for the year 2023.*/

SET @average = (SELECT AVG(salary_IN_usd) AS 'average' FROM salaries WHERE experience_level='MI');

SELECT company_location, AVG(salary_IN_usd) 
FROM salaries 
WHERE experience_level = 'MI' AND salary_IN_usd > @average 
GROUP BY company_location;


/*6. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.*/
set @COUNTS= (SELECT COUNT(*) FROM salaries  WHERE salary_IN_usd >100000 and remote_ratio=100);
set @total = (SELECT COUNT(*) FROM salaries where salary_in_usd>100000);
set @percentage= round((((SELECT @COUNTS)/(SELECT @total))*100),2);
SELECT @percentage AS '%  of people working remotely and having salary >100,000 USD';



/*7. Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average salaries exceed the 
average salary for that job title in market for entry level, helping your agency guide candidates towards lucrative countries.*/
SELECT company_location, t.job_title, average_per_country, average FROM 
(
	SELECT company_location,job_title,AVG(salary_IN_usd) AS average_per_country FROM  salaries WHERE experience_level = 'EN' 
	GROUP BY  company_location, job_title
) AS t 
INNER JOIN 
( 
	 SELECT job_title,AVG(salary_IN_usd) AS average FROM  salaries  WHERE experience_level = 'EN'  GROUP BY job_title
) AS p 
ON  t.job_title = p.job_title WHERE average_per_country > average
    


/*8. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which
Country pays the maximum average salary. This helps you to place your candidates IN those countries.*/

SELECT company_location , job_title , average FROM
(
SELECT *, dense_rank() over (partition by job_title order by average desc)  AS num FROM 
(
SELECT company_location , job_title , AVG(salary_IN_usd) AS 'average' FROM salaries GROUP BY company_location, job_title
)k
)t  WHERE num=1



 /* 9.	Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to determINe the percentage of  fully remote work for each 
 experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, highlightINg any significant INcreASes or decreASes IN remote work adoptiON
 over the years.*/
 WITH t1 AS 
 (
		SELECT a.experience_level, total_remote ,total_2021, ROUND((((total_remote)/total_2021)*100),2) AS '2021 remote %' FROM
		( 
		   SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		  SELECT  experience_level, COUNT(experience_level) AS total_2021 FROM salaries WHERE work_year=2021 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ),
  t2 AS
     (
		SELECT a.experience_level, total_remote ,total_2024, ROUND((((total_remote)/total_2024)*100),2)AS '2024 remote %' FROM
		( 
		SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2024 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		SELECT  experience_level, COUNT(experience_level) AS total_2024 FROM salaries WHERE work_year=2024 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ) 
  
 SELECT * FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level
 
 
 
/* 10. AS a compensatiON specialist at a Fortune 500 company, you're tASked WITH analyzINg salary trends over time. Your objective is to calculate the average 
salary INcreASe percentage for each experience level and job title between the years 2023 and 2024, helpINg the company stay competitive IN the talent market.*/

WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)  

SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
	SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM  t GROUP BY experience_level , job_title 
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100)  IS NOT NULL 



/*11. You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.*/
WITH avg_salary_per_year AS 
(
    SELECT work_year, job_title, AVG(salary_in_usd) AS avg_salary 
    FROM salaries
    GROUP BY work_year, job_title
)

SELECT job_title, work_year, avg_salary FROM 
    (
       SELECT job_title, work_year, avg_salary, RANK() OVER (PARTITION BY job_title ORDER BY avg_salary DESC) AS rank_by_salary
	   FROM avg_salary_per_year
    ) AS ranked_salary
WHERE 
    rank_by_salary = 1; 
    
    
    

/*12. As a database analyst you have been assigned the task to Identify the company locations with the highest and lowest average salary for 
senior-level (SE) employees in 2023.*/

DELIMITER //

CREATE PROCEDURE GetSeniorSalaryStats()
BEGIN
    -- Query to find the highest average salary for senior-level employees in 2023
    SELECT company_location AS highest_location, AVG(salary_in_usd) AS highest_avg_salary
    FROM  salaries
    WHERE work_year = 2023 AND experience_level = 'SE'
    GROUP BY company_location
    ORDER BY highest_avg_salary DESC
    LIMIT 1;

    -- Query to find the lowest average salary for senior-level employees in 2023
    SELECT company_location AS lowest_location, AVG(salary_in_usd) AS lowest_avg_salary
    FROM  salaries
    WHERE work_year = 2023 AND experience_level = 'SE'
    GROUP BY company_location
    ORDER BY lowest_avg_salary ASC
    LIMIT 1;
END //

DELIMITER ;

CALL GetSeniorSalaryStats();



 






