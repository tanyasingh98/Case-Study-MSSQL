--1. Find the longest ongoing project for each department.

select d.id,d.name as dept_name,p.name as project_name, datediff(day,start_date,end_date) as duration from projects p 
join departments d on p.department_id=d.id 


--2. Find all employees who are not managers.
 
select e.name as employee_name from employees e 
left join departments d on e.id=d.manager_id 
where d.manager_id is NULL

--3. Find all employees who have been hired after the start of a project in their department.

select e.name as employee_name from employees e 
left join projects p on e.department_id=p.department_id 
where e.hire_date > p.start_date

--4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).

select *,dense_rank() over(partition by department_id order by hire_date) as emp_rank from employees

--5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.

with cte as(select name, hire_date, department_id, lead(hire_date) over (partition by department_id order by hire_date) 
as next_hire_date from employees)
select department_id,datediff(day,hire_date,next_hire_date) as duration_diff from cte where datediff(day,hire_date,next_hire_date) is not NULL