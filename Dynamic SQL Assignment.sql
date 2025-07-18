-- Q1: Select any single column dynamically from the Employees table
-- Purpose: Return values from a user-specified column in the Employees table

DROP PROCEDURE IF EXISTS SelectSingleColumn;
DELIMITER $$

CREATE PROCEDURE SelectSingleColumn(IN colName VARCHAR(100))
BEGIN
    -- Join the string to form a full SQL query
    SET @sql = CONCAT('SELECT ', colName, ' FROM Employees');
    
    -- Tell MySQL to get ready to run that SQL
    PREPARE stmt FROM @sql;
    
    -- 	Actually run the SQL query
    EXECUTE stmt;
    
    -- Clean up prepared statement
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

DELIMITER $$
--  Write a procedure that filters employees by DepartmentID and/or Minimum Salary 
-- using a dynamic WHERE clause. 
CREATE PROCEDURE FilterEmployees(
    IN dept INT,               -- Department ID (optional)
    IN minSalary DECIMAL(10,2) -- Minimum Salary (optional)
)
BEGIN
    -- Start with a base query that always returns true (1=1 is a trick) 
    SET @sql = 'SELECT * FROM Employees WHERE 1=1';

    -- Add DepartmentID condition if it was passed (not null)
    IF dept IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND DepartmentID = ', dept);
    END IF;

    -- Add Salary condition if it was passed (not null)
    IF minSalary IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND Salary >= ', minSalary);
    END IF;

    -- Run the final dynamic SQL query
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

CALL FilterEmployees(2, 60000);     -- Department 2, Salary ≥ 60000
/* CALL FilterEmployees(NULL, 70000);  -- Any Department, Salary ≥ 70000
CALL FilterEmployees(3, NULL);      -- Department 3 only
CALL FilterEmployees(NULL, NULL);   -- No filter, return all employees*/

-- Q3: Sort Employees by a user-specified column (e.g., Name, Salary, JoinDate)
-- Goal: Build a dynamic ORDER BY clause based on user input

DROP PROCEDURE IF EXISTS SortEmployees;
DELIMITER $$

CREATE PROCEDURE SortEmployees(
    IN sortColumn VARCHAR(100)  -- Column to sort by
)
BEGIN
    -- Optional: Allow only safe column names to avoid SQL injection
    IF sortColumn NOT IN ('EmployeeID', 'Name', 'DepartmentID', 'Salary', 'JoinDate', 'Designation', 'Location') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid column name'; -- error custom code is 45000
    END IF;

    -- Build dynamic SQL with ORDER BY the given column
    SET @sql = CONCAT('SELECT * FROM Employees ORDER BY ', sortColumn);

    -- Prepare and run the SQL
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

 -- CALL SortEmployees('Salary');

-- Q4: Perform an INNER or LEFT JOIN with the Departments table
-- Goal: Accept a join type ('INNER' or 'LEFT') and perform that join dynamically

DROP PROCEDURE IF EXISTS JoinEmployeesDepartments;
DELIMITER $$

CREATE PROCEDURE JoinEmployeesDepartments(IN joinType VARCHAR(10))
BEGIN
    -- Only allow 'INNER' or 'LEFT' as join types
    IF joinType NOT IN ('INNER', 'LEFT') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid join type. Use INNER or LEFT';
    END IF;

    -- Build the dynamic JOIN query using the given join type
    SET @sql = CONCAT(
        'SELECT e.EmployeeID, e.Name, e.DepartmentID, d.DepartmentName ',
        'FROM Employees e ', joinType, ' JOIN Departments d ',
        'ON e.DepartmentID = d.DepartmentID'
    );

    -- Prepare and execute the dynamic SQL
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- Q5: Create a stored procedure to filter employees who joined within a given date range

DROP PROCEDURE IF EXISTS FilterJoinDate;
DELIMITER $$

CREATE PROCEDURE FilterJoinDate(
    IN startDate DATE,   -- Start date of the range
    IN endDate DATE      -- End date of the range
)
BEGIN
    -- Store procedure parameters into session variables
    SET @start := startDate;
    SET @end := endDate;

    -- Build dynamic SQL query using placeholders (?)
    SET @sql = '
        SELECT * FROM Employees
        WHERE JoinDate BETWEEN ? AND ?';

    -- Prepare, bind parameters, execute, and clean up
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING @start, @end;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- CALL FilterJoinDate('2020-01-01', '2023-12-31');

-- Q6: Select employees whose IDs are passed as a comma-separated string (IN clause)
-- Goal: Use dynamic SQL to plug the comma-separated values directly into an IN()

DROP PROCEDURE IF EXISTS FilterByIDs;
DELIMITER $$

CREATE PROCEDURE FilterByIDs(
    IN idList TEXT  -- Example: '101,102,105'
)
BEGIN
    -- Build a query like: SELECT * FROM Employees WHERE EmployeeID IN (101,102,105)
    SET @sql = CONCAT('SELECT * FROM Employees WHERE EmployeeID IN (', idList, ')');

    -- Prepare, execute, and clean up
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;
-- CALL FilterByIDs('101,104,107');

-- Q7: Perform a GROUP BY on any selected column and return aggregated results
-- Goal: Count number of employees grouped by the specified column (e.g., DepartmentID, Location)

DROP PROCEDURE IF EXISTS GroupByColumn;
DELIMITER $$

CREATE PROCEDURE GroupByColumn(
    IN groupCol VARCHAR(100)  -- Column to group by
)
BEGIN
    -- Optional validation to prevent SQL injection
    IF groupCol NOT IN ('DepartmentID', 'Designation', 'Location') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid group-by column';
    END IF;

    -- Build and run dynamic SQL for GROUP BY
    SET @sql = CONCAT(
        'SELECT ', groupCol, ', COUNT(*) AS EmployeeCount FROM Employees GROUP BY ', groupCol
    );

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- Q8: Create a pivot-like table showing total salary per department
-- Goal: SUM salaries grouped by DepartmentID across known departments

DROP PROCEDURE IF EXISTS PivotSalaryByDept;
DELIMITER $$

CREATE PROCEDURE PivotSalaryByDept()
BEGIN
    -- Manually simulate pivot by creating salary columns per DepartmentID
    SET @sql = '
        SELECT 
            SUM(CASE WHEN DepartmentID = 1 THEN Salary ELSE 0 END) AS Dept_11,
            SUM(CASE WHEN DepartmentID = 2 THEN Salary ELSE 0 END) AS Dept_2,
            SUM(CASE WHEN DepartmentID = 3 THEN Salary ELSE 0 END) AS Dept_3,
            SUM(CASE WHEN DepartmentID = 4 THEN Salary ELSE 0 END) AS Dept_4,
            SUM(CASE WHEN DepartmentID = 5 THEN Salary ELSE 0 END) AS Dept_5
        FROM Employees';

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- Q9: Dynamically increase the value of a numeric column (e.g., Salary)
-- Goal: UPDATE a specified numeric column by a fixed amount

DROP PROCEDURE IF EXISTS IncreaseNumericColumn;
DELIMITER $$

CREATE PROCEDURE IncreaseNumericColumn(
    IN columnName VARCHAR(100),
    IN increment DECIMAL(10,2)
)
BEGIN
    -- Allow only specific numeric columns
    IF columnName NOT IN ('Salary') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid column name for increment';
    END IF;

    -- Build dynamic UPDATE query
    SET @sql = CONCAT(
        'UPDATE Employees SET ', columnName, ' = ', columnName, ' + ', increment
    );

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;
/* SET SQL_SAFE_UPDATES = 0;
CALL IncreaseNumericColumn('Salary', 2000);
SET SQL_SAFEdepartments_UPDATES = 1; */

-- Q10: Return the top N employees based on salary
-- Goal: SELECT employees ordered by Salary, limiting to N rows

DROP PROCEDURE IF EXISTS TopEmployeesBySalary;
DELIMITER $$

CREATE PROCEDURE TopEmployeesBySalary(
    IN topN INT
)
BEGIN
    -- Build query using LIMIT and ORDER BY
    SET @sql = CONCAT(
        'SELECT * FROM Employees ORDER BY Salary DESC LIMIT ', topN
    );

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;
/* CALL GroupByColumn('DepartmentID');
CALL PivotSalaryByDept();
CALL IncreaseNumericColumn('Salary', 1000);
CALL TopEmployeesBySalary(5);
*/ 




-- Q11: Dynamically create a new table with standard columns

DROP PROCEDURE IF EXISTS CreateDynamicTable;
DELIMITER $$

CREATE PROCEDURE CreateDynamicTable(IN tableName VARCHAR(100))
BEGIN
    SET @sql = CONCAT(
        'CREATE TABLE ', tableName, ' (
            ID INT PRIMARY KEY,
            Name VARCHAR(100),
            CreatedAt DATETIME DEFAULT NOW()
        )'
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

-- CALL CreateDynamicTable('NewEmployeeLog');

-- Q12: Dynamically insert data into a table whose name is passed as a parameter

DROP PROCEDURE IF EXISTS InsertIntoDynamicTable;
DELIMITER $$

CREATE PROCEDURE InsertIntoDynamicTable(
    IN targetTable VARCHAR(100),
    IN newID INT,
    IN newName VARCHAR(100)
)
BEGIN
    -- Build INSERT statement by embedding values safely using QUOTE() for strings
    SET @sql = CONCAT(
        'INSERT INTO ', targetTable, ' (ID, Name) VALUES (',
        newID, ', ', QUOTE(newName), ')'
    );

    -- Prepare and run the SQL
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

-- CALL InsertIntoDynamicTable('NewEmployeeLog', 301, 'Aarthi Ramamurthy');

-- Q13: Drop table if it exists (dynamically)

DROP PROCEDURE IF EXISTS DropTableIfExists;
DELIMITER $$

CREATE PROCEDURE DropTableIfExists(IN tableName VARCHAR(100))
BEGIN
    SET @sql = CONCAT(
        'DROP TABLE IF EXISTS ', tableName
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

-- CALL DropTableIfExists('NewEmployeeLog');

-- Q14: Dynamically copy data from one table to another

DROP PROCEDURE IF EXISTS CopyTableData;
DELIMITER $$

CREATE PROCEDURE CopyTableData(
    IN sourceTable VARCHAR(100),
    IN targetTable VARCHAR(100)
)
BEGIN
    -- Build dynamic SQL to copy data
    SET @sql = CONCAT(
        'INSERT INTO ', targetTable, ' SELECT * FROM ', sourceTable
    );

    -- Prepare and run
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

-- CALL CopyTableData('employees', 'employees_backup');

-- Q15: Search keyword across Name, Designation, and Location columns

-- Q15: Search across Name, Designation, and Location using dynamic SQL

DROP PROCEDURE IF EXISTS SearchEmployees;
DELIMITER $$

CREATE PROCEDURE SearchEmployees(IN keyword VARCHAR(100))
BEGIN
    -- Escape and quote the keyword for safe LIKE usage
    SET @search = CONCAT("'%", keyword, "%'");

    -- Build dynamic query across three columns
    SET @sql = CONCAT(
        'SELECT * FROM Employees WHERE ',
        'Name LIKE ', @search,
        ' OR Designation LIKE ', @search,
        ' OR Location LIKE ', @search
    );

    -- Run the dynamic SQL
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

-- CALL SearchEmployees('Manager');

-- Q16: Select all rows from a table in any schema (both schema and table are passed)

DROP PROCEDURE IF EXISTS SelectFromDynamicSchemaTable;
DELIMITER $$

CREATE PROCEDURE SelectFromDynamicSchemaTable(
    IN schemaName VARCHAR(100),
    IN tableName VARCHAR(100)
)
BEGIN
    -- Construct the dynamic SQL using CONCAT
    SET @sql = CONCAT('SELECT * FROM ', schemaName, '.', tableName);

    -- Prepare, execute, and clean up
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

-- CALL SelectFromDynamicSchemaTable('assignment7', 'employees');

-- Q17: Execute any SELECT query string passed to the procedure

DROP PROCEDURE IF EXISTS ExecuteSelectQuery;
DELIMITER $$

CREATE PROCEDURE ExecuteSelectQuery(IN query_text TEXT)
BEGIN
    -- Safety check to ensure the query starts with "select"
-- Logic Breakdown:
-- TRIM(query_text): Removes extra spaces at the start or end of the query
-- LEFT(..., 6): Takes the first 6 characters after trimming
-- LOWER(...): Converts those characters to lowercase (to make it case-insensitive)
-- != 'select': Checks if the cleaned string does NOT start with 'select'
-- THEN: If it doesn't, raise an error using SIGNAL to block unsafe queries
    IF LOWER(LEFT(TRIM(query_text), 6)) != 'select' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only SELECT queries are allowed.';
    ELSE
        -- Prepare and execute the dynamic SQL query
        SET @sql = query_text;
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END $$
DELIMITER ;


-- Q18: Dynamically filter employees using optional name, salary, and join year

DROP PROCEDURE IF EXISTS FilterEmployeesComplex;
DELIMITER $$

CREATE PROCEDURE FilterEmployeesComplex(
    IN empName VARCHAR(100),
    IN minSalary DECIMAL(10,2),
    IN joinYear INT
)
BEGIN
    -- Start base query with a dummy true condition
    SET @sql = 'SELECT * FROM Employees WHERE 1=1';

    -- Add condition for employee name (partial match)
    IF empName IS NOT NULL AND empName != '' THEN
        SET @sql = CONCAT(@sql, ' AND Name LIKE "%', empName, '%"');
    END IF;

    -- Add condition for minimum salary
    IF minSalary IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND Salary >= ', minSalary);
    END IF;

    -- Add condition for year of joining (based on JoinDate)
    IF joinYear IS NOT NULL THEN
        SET @sql = CONCAT(@sql, ' AND YEAR(JoinDate) = ', joinYear);
    END IF;

    -- Prepare and run the built SQL query
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

-- CALL FilterEmployeesComplex('Jane', 40000, 2022);

-- Q19: Dynamically delete employees whose salary is below the given threshold

DROP PROCEDURE IF EXISTS DeleteBelowSalary;
DELIMITER $$

CREATE PROCEDURE DeleteBelowSalary(IN salaryThreshold DECIMAL(10,2))
BEGIN
    -- Build dynamic SQL to delete rows
    SET @sql = CONCAT(
        'DELETE FROM Employees WHERE Salary < ', salaryThreshold
    );

    -- Prepare and execute the dynamic statement
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

-- SET SQL_SAFE_UPDATES = 0;
CALL DeleteBelowSalary(30000);
SET SQL_SAFE_UPDATES = 1;

-- Q20: Log and execute any SQL query passed to it

CREATE TABLE IF NOT EXISTS QueryLog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    executed_query TEXT,
    executed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


DROP PROCEDURE IF EXISTS ExecuteAndLog;
DELIMITER $$

CREATE PROCEDURE ExecuteAndLog(IN query_text TEXT)
BEGIN
    -- Log the query into QueryLog table
    INSERT INTO QueryLog (executed_query) VALUES (query_text);

    -- Prepare and execute the query
    SET @sql = query_text;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;

-- Run a safe SELECT
CALL ExecuteAndLog('SELECT * FROM employees WHERE DepartmentID = 2');

-- You could also log DML (if you trust the input)
-- CALL ExecuteAndLog('UPDATE employees SET Salary = Salary + 1000 WHERE DepartmentID = 3');






