-- 1. Rank Employees by Salary
-- RANK(): assigns same rank to ties, but skips the next number (e.g., 1, 1, 3).
SELECT emp_name, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- 2. Dense Rank Employees by Salary
-- DENSE_RANK(): like RANK, but no gaps in rank (e.g., 1, 1, 2).
SELECT emp_name, salary,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_salary_rank
FROM employees;

-- 3. Row Number of Employees Based on Hire Date
-- ROW_NUMBER(): gives a unique rank even if values tie.
SELECT emp_name, hire_date,
       ROW_NUMBER() OVER (ORDER BY hire_date) AS row_num
FROM employees;

-- 4. Cumulative Sum of Salaries
-- SUM() OVER(): calculates running total across rows.
-- Use ROWS BETWEEN to control how many rows are included.
SELECT emp_name, salary,
       SUM(salary) OVER (ORDER BY emp_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM employees;

-- 5. Average Salary per Department (each department shown only once)
SELECT department,
       AVG(salary) AS dept_avg_salary
FROM employees
GROUP BY department;


-- 6. Highest-paid Employee(s) per Department
SELECT emp_name, department, salary
FROM employees e
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department = e.department
);

-- 7. Lowest Salary per Department
-- MIN() OVER(): gives minimum value in the current window.
SELECT emp_name, department, salary
FROM employees e
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
    WHERE department = e.department
);
-- Total salary per department (one row per department)
SELECT department,
       SUM(salary) AS total_salary
FROM employees
GROUP BY department;

-- 9. Previous employee’s salary within each department (ordered by salary)
-- LAG(column) lets you look at the value from the previous row in a specific order.
SELECT emp_name, department, salary,
       LAG(salary) OVER (
           PARTITION BY department
           ORDER BY salary
       ) AS previous_salary
FROM employees;


-- 10. Employee’s Next Salary (Lead Function)
-- LEAD(): fetches value from the next row.
SELECT emp_name, department, salary,
       LEAD(salary) OVER (
           PARTITION BY department
           ORDER BY salary
       ) AS next_salary
FROM employees;

-- 11. Difference Between Current and Previous Salary
-- You can subtract LAG from current row to find change.
-- 11. Salary difference with previous employee in the same department
SELECT emp_name, department, salary,
       LAG(salary) OVER (
           PARTITION BY department
           ORDER BY salary
       ) AS previous_salary,
       salary - LAG(salary) OVER (
           PARTITION BY department
           ORDER BY salary
       ) AS salary_difference
FROM employees;


-- 12. First Salary in Each Department
-- FIRST_VALUE(): returns the first row's value in the window.
SELECT emp_name, department, salary,
       FIRST_VALUE(salary) OVER (PARTITION BY department ORDER BY emp_id) AS first_dept_salary
FROM employees;

-- 13. Last Salary in Each Department
-- LAST_VALUE() needs full window: use UNBOUNDED PRECEDING AND FOLLOWING.
SELECT emp_name, department, salary,
       LAST_VALUE(salary) OVER (
           PARTITION BY department 
           ORDER BY emp_id 
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS last_dept_salary
FROM employees;

-- 14. Employees Hired Before Each One
-- ROW_NUMBER() - 1 gives how many came before based on order.
SELECT emp_name, hire_date,
       ROW_NUMBER() OVER (ORDER BY hire_date) - 1 AS employees_hired_before
FROM employees;

-- 15. Median Salary in Each Department (approximate using NTILE)
-- NTILE(n): splits data into equal parts (quantiles).
/* ROW_NUMBER() gives position of each employee in department by salary.

COUNT(*) gives how many people are in that department.

FLOOR((total + 1)/2) gives the middle position = median.*/

WITH ranked AS ( -- temporary table 
    SELECT emp_name, department, salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary) AS rn,
           COUNT(*) OVER (PARTITION BY department) AS total -- adds everything department wise 
    FROM employees
)
SELECT emp_name, department, salary -- this part just calculates msian 
FROM ranked
WHERE rn = FLOOR((total + 1) / 2); -- median formula 

-- 16. Quartiles of Salaries (NTILE Function)
-- Use NTILE(4) for dividing into Q1, Q2, Q3, Q4.
SELECT emp_name, salary,
       NTILE(4) OVER (ORDER BY salary) AS salary_quartile
FROM employees;

-- 17. Employees with Top 3 Salaries in Each Department
-- Combine RANK() with WHERE to filter top values.
SELECT *
FROM (
    SELECT emp_name, department, salary,
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rnk
    FROM employees
) sub
WHERE rnk <= 3;

-- 18. Yearly Salary Growth (skipped – not in this table)
-- Needs year-wise salary data in another table to compute growth.

-- 19. Percentage of Salary Contribution per Department
WITH contribution AS (
    SELECT emp_name, department, salary,
           ROUND(100 * salary / SUM(salary) OVER (PARTITION BY department), 2) AS percent_contribution
    FROM employees
)
SELECT *
FROM contribution c
WHERE percent_contribution = (
    SELECT MAX(percent_contribution)
    FROM contribution
    WHERE department = c.department
);


-- 20. Employees with Higher Salary than Department Average
-- Nest AVG() OVER() and filter using WHERE.
SELECT emp_name, department, salary
FROM (
    SELECT emp_name, department, salary,
           AVG(salary) OVER (PARTITION BY department) AS dept_avg
    FROM employees
) sub
WHERE salary > dept_avg;
