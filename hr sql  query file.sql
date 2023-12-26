SELECT * FROM projects.hr;
alter table hr 
modify column emp_id varchar(20) null;

select * from hr;

Describe hr;

select birthdate from hr;

update hr 
set birthdate = CASE
when birthdate like '%/%' Then date_format(str_to_date(birthdate, '%m/%d/%Y'), '%y-%m-%d')
when birthdate like '%-%' Then date_format(str_to_date(birthdate, '%m-%d-%Y'), '%y-%m-%d')
else null
end;

select birthdate from hr;

Alter table hr 
modify column birthdate Date;

Alter table hr 
modify column hire_date Date;

update hr 
set hire_date = CASE
when hire_date like '%/%' Then date_format(str_to_date(hire_date, '%m/%d/%Y'), '%y-%m-%d')
when hire_date like '%-%' Then date_format(str_to_date(hire_date, '%m-%d-%Y'), '%y-%m-%d')
else null
end;

set sql_safe_updates = 0;

select hire_date from hr;
select termdate from hr;

update hr 
set termdate = date(str_to_date(termdate,"%Y-%m-%d %H:%i:%s UTC"))
where termdate IS NOT NULL AND termdate !='';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

UPDATE hr
SET termdate = "%Y-%m-%d %H:%i:%s UTC"
WHERE termdate = '';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

Alter table hr ADD Column age int;

select birthdate,age from hr;

update hr 
set age = timestampdiff(Year,birthdate,curdate());

select 
	min(age) as youngest,
    max(age) as older
from hr;

select count(*) from hr where age < 18;

delete from hr
where age <18;

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
select gender, count(*) as count from hr 
where age > 18 and termdate is null
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as count from hr 
where age > 18 and termdate is null
group by race;


-- 3. What is the age distribution of employees in the company?
select 
CASE 
    when age >= 18 And age <= 24 then '18-24'
    when age >= 25 And age <= 34 then '25-34'
    when age >= 35 And age <= 44 then '35-44'
    when age >= 45 And age <= 54 then '45-54'
    when age >= 55 And age <= 24 then '55-64'
    else '65+'
end as age_group, gender,
count(*) as count 
from hr 
where age > 18 and termdate is null
group by age_group, gender
order by age_group;

-- 4. How many employees work at headquarters versus remote locations?
select location, count(*) as count from hr 
where age > 18 and termdate is null
group by location;

-- 5. What is the average length of employment for employees who have been terminated?
select 
round(avg(datediff(termdate,hire_date))/365,0) as avg_length_employment
from hr 
where termdate <= curdate() and termdate is not null;

-- 6. How doets the gender distribution vary across departments and job titles?
select department,gender, count(*) as count 
from hr 
where age > 18 and termdate is null 
group by department,gender
order by department;

-- 7. What is the distribution of job titles across the company?
select jobtitle, count(*) as count 
from hr 
where age > 18 and termdate is null 
group by jobtitle
order by jobtitle desc;

-- 8. Which department has the highest turnover rate?
 select department, 
 total_count,
 terminated_count,
 terminated_count / total_count as termination_rate
 from (
 select department,
 count(*) as total_count,
 sum(case when termdate <= curdate() and termdate is not null then 1 else 0 end ) as  terminated_count
 from hr 
 group by department) as subquery
 order by termination_rate desc;
 
-- 9. What is the distribution of employees across locations by city and state?
select location_city,location_state, count(*) as count 
from hr
group by location_city,location_state
order by count desc;

-- 10. How has the company's employee count changed over time based on hire and term dates?
select 
year,
hires,
terminations,
hires - terminations as net_change,
round((hires-terminations)/hires*100,2) as net_change_percent
from(
 select 
 year(hire_date) as year,
 count(*)as hires,
 sum(case when termdate is not null and termdate <=curdate() then 1 else 0 end ) as terminations
 from hr 
 group by year (hire_date)) as subquery
 order by year asc;
 


-- 11. What is the tenure distribution for each department?
select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr
where termdate is not null and termdate <= curdate()
group by department;

