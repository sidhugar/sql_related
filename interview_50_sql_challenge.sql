-- 01/50 Days SQL challenge
USE interview_db;
-- Create the employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

-- Insert records for three departments
INSERT INTO employees (name, department, salary) VALUES 
('John Doe', 'Engineering', 63000),
('Jane Smith', 'Engineering', 55000),
('Michael Johnson', 'Engineering', 64000),
('Emily Davis', 'Marketing', 58000),
('Chris Brown', 'Marketing', 56000),
('Emma Wilson', 'Marketing', 59000),
('Alex Lee', 'Sales', 58000),
('Sarah Adams', 'Sales', 58000),
('Ryan Clark', 'Sales', 61000);


/*

Write the SQL query to find the second highest salary

*/

-- Approach 1

SELECT * FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 1;
/*
	If duplicate records are present it wont show proper result
    so, it is better to use WINDOW FUNCTIONS
*/

-- ADDED new records - with same salary
INSERT INTO employees
VALUES (11, 'zara', 'it', 63000);


-- Approach 2
-- Window function dense_rank

SELECT *
FROM
	(SELECT *,
	 DENSE_RANK() OVER(ORDER BY salary DESC) drn	
	 FROM employees
	) as subquery
WHERE drn = 2;

-- Using CTE
WITH den_rank AS
	(SELECT *,
	DENSE_RANK() OVER(ORDER BY salary DESC) drn	
	FROM employees)
SELECT * 
FROM den_rank
WHERE drn = 2;


/*
	Question: 
		Get the details of the employee with the 
        second-highest salary from each department
*/
WITH den_rank AS
	(SELECT *,
	DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) drn	
	FROM employees)
SELECT * 
FROM den_rank
WHERE drn = 2;

/*
	***************************************************************
							Day 02/50
    ***************************************************************
*/

DROP TABLE IF EXISTS Orders;

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2)
);

DROP TABLE IF EXISTS Returns;
CREATE TABLE Returns (
    ReturnID INT PRIMARY KEY,
    OrderID INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO Orders (OrderID, OrderDate, TotalAmount) VALUES
(1, '2023-01-15', 150.50),
(2, '2023-02-20', 200.75),
(3, '2023-02-28', 300.25),
(4, '2023-03-10', 180.00),
(5, '2023-04-05', 250.80);

INSERT INTO Returns (ReturnID, OrderID) VALUES
(101, 2),
(102, 4),
(103, 5),
(104, 1),
(105, 3);

/*
	Given the Orders table with columns OrderID, 
	OrderDate, and TotalAmount, and the 
	Returns table with columns ReturnID and OrderID, 

	write an SQL query to calculate the total 
	numbers of returned orders for each month
*/
-- total numbers of returns
-- group by month orders
-- LEFT JOIN 
/* ------------------------------------
		My Solution
  ------------------------------------
*/

SELECT *
FROM returns as r
LEFT JOIN
orders as o
ON r.orderid = o.orderid;

SELECT 
	EXTRACT(MONTH FROM o.orderdate) as month,
	COUNT(r.returnid) as total_return
FROM returns as r
LEFT JOIN
orders AS o
ON r.orderid = o.orderid
GROUP BY month
ORDER BY month ;

SELECT 
	(EXTRACT(MONTH FROM o.orderdate) || '-' || EXTRACT(YEAR FROM o.orderdate)) AS month,
	COUNT(r.returnid) AS total_return
FROM returns AS r
LEFT JOIN
orders AS o
ON r.orderid = o.orderid
GROUP BY month
ORDER BY month ;

/*
	****************************************************************
    ****************************************************************
*/
DROP TABLE IF EXISTS products;

-- Step 1: Create the products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    quantity_sold INT
);

-- Step 2: Insert sample records into the products table
INSERT INTO products (product_id, product_name, category, quantity_sold) VALUES
(1, 'Samsung Galaxy S20', 'Electronics', 100),
(2, 'Apple iPhone 12 Pro', 'Electronics', 150),
(3, 'Sony PlayStation 5', 'Electronics', 80),
(4, 'Nike Air Max 270', 'Clothing', 200),
(5, 'Adidas Ultraboost 20', 'Clothing', 200),
(6, 'Levis Mens 501 Jeans', 'Clothing', 90),
(7, 'Instant Pot Duo 7-in-1', 'Home & Kitchen', 180),
(8, 'Keurig K-Classic Coffee Maker', 'Home & Kitchen', 130),
(9, 'iRobot Roomba 675 Robot Vacuum', 'Home & Kitchen', 130),
(10, 'Breville Compact Smart Oven', 'Home & Kitchen', 90),
(11, 'Dyson V11 Animal Cordless Vacuum', 'Home & Kitchen', 90);

/*

Questions : 
Write SQL query to find the top-selling products in each category

assuming products table has column 
product_id, product_name, category, quantity_sold
*/
-- 1 product from each category
-- based on highest qty sold
-- rank

SELECT *
FROM (	
	SELECT *,
		RANK() OVER(PARTITION BY category ORDER BY quantity_sold DESC) ranks
	FROm products
	ORDER BY category, quantity_sold DESC
) as subquery	
WHERE ranks = 1;

/* 
	**********************************************
					Day 4
	**********************************************
*/
create table orders4(
  	category varchar(20),
	product varchar(20),
	user_id int , 
  	spend int,
  	transaction_date DATE
);

Insert into orders4 values
('appliance','refrigerator',165,246.00,'2021/12/26'),
('appliance','refrigerator',123,299.99,'2022/03/02'),
('appliance','washingmachine',123,219.80,'2022/03/02'),
('electronics','vacuum',178,152.00,'2022/04/05'),
('electronics','wirelessheadset',156,	249.90,'2022/07/08'),
('electronics','TV',145,189.00,'2022/07/15'),
('Television','TV',165,129.00,'2022/07/15'),
('Television','TV',163,129.00,'2022/07/15'),
('Television','TV',141,129.00,'2022/07/15'),
('toys','Ben10',145,189.00,'2022/07/15'),
('toys','Ben10',145,189.00,'2022/07/15'),
('toys','yoyo',165,129.00,'2022/07/15'),
('toys','yoyo',163,129.00,'2022/07/15'),
('toys','yoyo',141,129.00,'2022/07/15'),
('toys','yoyo',145,189.00,'2022/07/15'),
('electronics','vacuum',145,189.00,'2022/07/15');
/*
	Find the top 2 products in the top 2 
    categories based on spend amount?
*/
-- top 2 category based on spend 
-- top 2 product in above best 2 category

WITH 
	top_2_category AS (
		SELECT  category, SUM(spend) AS Spent_on_category, 
				DENSE_RANK() OVER(ORDER BY SUM(spend) DESC) drn
		FROM orders4
		GROUP BY category
	),

	top_2_products AS (
		SELECT  o.category,
				o.product, 
				SUM(o.spend) AS spent_on_product,
				DENSE_RANK() OVER(PARTITION BY o.category ORDER BY SUM(o.spend) DESC) drnk
		FROM orders4 AS o
		JOIN top_2_category AS tc
		ON tc.category = o.category
		GROUP BY o.category, o.product
	)
SELECT *
FROM top_2_products
WHERE drnk < 3;

-- Your Task Find top category and product that has least spend amount 	

WITH 
	last_2_category AS (
		SELECT  category, SUM(spend) AS Spent_on_category, 
				DENSE_RANK() OVER(ORDER BY SUM(spend) ASC) drn
		FROM orders4
		GROUP BY category
	),
	last_2_products AS (
		SELECT  o.category,
				o.product, 
				SUM(o.spend) AS spent_on_product,
				DENSE_RANK() OVER(PARTITION BY o.category ORDER BY SUM(o.spend) ASC) drnk
		FROM orders4 AS o
		JOIN last_2_category AS tc
		ON tc.category = o.category
		GROUP BY o.category, o.product
	)
SELECT *
FROM last_2_products
WHERE drnk < 3;

/*
	******************************************************
							Day 5
    ******************************************************
*/
DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2),
    HireDate DATE
);

INSERT INTO Employees (EmployeeID, Name, Department, Salary, HireDate) VALUES
(101, 'John Smith', 'Sales', 60000.00, '2022-01-15'),
(102, 'Jane Doe', 'Marketing', 55000.00, '2022-02-20'),
(103, 'Michael Johnson', 'Finance', 70000.00, '2021-12-10'),
(104, 'Emily Brown', 'Sales', 62000.00, '2022-03-05'),
(106, 'Sam Brown', 'IT', 62000.00, '2022-03-05'),	
(105, 'Chris Wilson', 'Marketing', 58000.00, '2022-01-30');
/*
	Write a SQL query to retrieve the 
	3rd highest salary from the Employee table.
*/
WITH highest_salary AS (
	SELECT  *, 
			DENSE_RANK() OVER(ORDER BY Salary DESC) drn
	FROM employees
)
SELECT * 
FROM highest_salary
WHERE drn = 3;

-- Find the employee details who has highest salary from each department
WITH highest_salary AS (
	SELECT  *, 
			DENSE_RANK() OVER(PARTITION BY Department ORDER BY Salary DESC) drn
	FROM employees
)
SELECT * 
FROM highest_salary
WHERE drn = 1;

/*
	********************************************************************
						06/50 Days SQL Challenge
    ********************************************************************
*/
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id INT,
    name VARCHAR(100),
    email VARCHAR(100)
);

DROP TABLE IF EXISTS orders5;
CREATE TABLE orders5 (
    order_id INT ,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2)
);

INSERT INTO customers (customer_id, name, email) VALUES
(1, 'John Doe', 'john@example.com'),
(2, 'Jane Smith', 'jane@example.com'),
(3, 'Alice Johnson', 'alice@example.com'),
(4, 'Sam B', 'sb@example.com'),
(5, 'John Smith', 'j@example.com');

INSERT INTO orders5 (order_id, customer_id, order_date, amount) VALUES
(1, 1, '2024-03-05', 50.00),
(2, 2, '2024-03-10', 75.00),
(5, 4, '2024-04-02', 45.00),
(5, 2, '2024-04-02', 45.00)	,
(3, 4, '2024-04-15', 100.00),
(4, 1, '2024-04-01', 60.00),
(5, 5, '2024-04-02', 45.00);
/*
	Given tables customers (columns: customer_id, 
	name, email) and orders (columns: order_id, 
	customer_id, order_date, amount), 

	Write an SQL query to find customers who 
	haven't made any purchases in the last month, 
	assuming today's date is April 2, 2024. 
*/

SELECT customer_id, EXTRACT(MONTH FROM order_date) Month
FROM orders5;

SELECT 
	*
FROM customers
WHERE customer_id NOT IN (SELECT customer_id FROM orders5
							WHERE EXTRACT(MONTH from order_date) 
							= EXTRACT(MONTH FROM "2024-04-02")-1 	
							AND 
							EXTRACT(YEAR FROM order_date) = 
							EXTRACT(YEAR FROM "2024-04-02")
							);
                            
/*
	*****************************************************
				Day 07/50 days sql challenge
    *****************************************************
*/

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id INT,
    name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);
-- Insert all records again to simulate duplicates
INSERT INTO employees(emp_id, name, department, salary) VALUES
(1, 'John Doe', 'Finance', 60000.00),
(2, 'Jane Smith', 'Finance', 65000.00), 
(2, 'Jane Smith', 'Finance', 65000.00),   -- Duplicate
(9, 'Lisa Anderson', 'Sales', 63000.00),
(9, 'Lisa Anderson', 'Sales', 63000.00),  -- Duplicate
(9, 'Lisa Anderson', 'Sales', 63000.00),  -- Duplicate
(10, 'Kevin Martinez', 'Sales', 61000.00);


/*
Question:

How would you identify duplicate entries in
a SQL in given table employees columns are 
emp_id, name, department, salary

*/

SELECT 
	emp_id,
	name,	
	COUNT(1) as total_frequency
FROM employees
GROUP BY emp_id, name
HAVING COUNT(1) > 1;
	
SELECT *
FROM (	
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY name ORDER BY name) as rn
	FROM employees
) as subquery
WHERE rn > 1;

-- Identify employee details who is appearing more than twice in the table employees
SELECT *
FROM (	
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY name ORDER BY name) as rn
	FROM employees
) as subquery
WHERE rn > 2;

/*
	************************************************
					Day 08/50
    ************************************************
*/

DROP TABLE IF EXISTS Products8;
CREATE TABLE Products8 (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2)
);
-- Insert sample records into Product table
INSERT INTO Products8 (product_id, product_name, category, price) VALUES
(1, 'Product A', 'Category 1', 10.00),
(2, 'Product B', 'Category 2', 15.00),
(3, 'Product C', 'Category 1', 20.00),
(4, 'Product D', 'Category 3', 25.00);

-- Create Sales table
DROP TABLE IF EXISTS Sales;
CREATE TABLE Sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT,
    sale_date DATE,
    quantity INT,
    FOREIGN KEY (product_id) REFERENCES Products8(product_id)
);
-- Insert sample records into Sales table
INSERT INTO Sales (product_id, sale_date, quantity) VALUES
(1, '2023-09-15', 5),
(2, '2023-10-20', 3),
(1, '2024-01-05', 2),
(3, '2024-02-10', 4),
(4, '2023-12-03', 1);

/*
	Question:
	Write a SQL query to find all products that
	haven't been sold in the last six months. 

	Return the product_id, product_name, category, 
	and price of these products.
*/

SELECT * FROM products8;
SELECT * FROM sales;

-- everything from product table
-- there shouldn't be any sale in last 6 month 
-- no sale
-- join 

SELECT
	p.*,
	s.sale_date
FROM products8 AS p	
LEFT JOIN 
sales AS s	
ON p.product_id = s.product_id
WHERE s.sale_date IS NOT NULL ;
-- s.sale_date < CURRENT_DATE - INTERVAL '6 month'

-- Your Task select all product which has not received any sale in current year;


/*
	*************************************************************
							Day 09/50
    *************************************************************
*/
-- Create Customers table
DROP TABLE IF EXISTS customers9;
CREATE TABLE Customers9 (
    CustomerID INT,
    CustomerName VARCHAR(50)
);

-- Create Purchases table
DROP TABLE IF EXISTS purchases;
CREATE TABLE Purchases (
    PurchaseID INT,
    CustomerID INT,
    ProductName VARCHAR(50),
    PurchaseDate DATE
);

-- Insert sample data into Customers table
INSERT INTO Customers9 (CustomerID, CustomerName) VALUES
(1, 'John'),
(2, 'Emma'),
(3, 'Michael'),
(4, 'Ben'),
(5, 'John')	;

-- Insert sample data into Purchases table
INSERT INTO Purchases (PurchaseID, CustomerID, ProductName, PurchaseDate) VALUES
(100, 1, 'iPhone', '2024-01-01'),
(101, 1, 'MacBook', '2024-01-20'),	
(102, 1, 'Airpods', '2024-03-10'),
(103, 2, 'iPad', '2024-03-05'),
(104, 2, 'iPhone', '2024-03-15'),
(105, 3, 'MacBook', '2024-03-20'),
(106, 3, 'Airpods', '2024-03-25'),
(107, 4, 'iPhone', '2024-03-22'),	
(108, 4, 'Airpods', '2024-03-29'),
(110, 5, 'Airpods', '2024-02-29'),
(109, 5, 'iPhone', '2024-03-22');

/*
Apple data analyst interview question :
Given two tables - Customers and Purchases, 
where Customers contains information about 
customers and Purchases contains information 
about their purchases, 

write a SQL query to find customers who 
bought Airpods after purchasing an iPhone.
*/

-- Find out all customers who bought iPhone
-- All customers who bought Airpods
-- Customer has to buy Airpods after purchasing the iPhone 

WITH 
	cust_iphone AS (
		SELECT *
		FROM Purchases
		WHERE ProductName LIKE "%iPhone%"
	),
	cust_airpods AS (
		SELECT *
		FROM Purchases
		WHERE ProductName LIKE "%Airpods%"
	),
    cust_iphone_early AS (
		SELECT i.customerID
        FROM cust_iphone AS i
        LEFT JOIN 
        cust_airpods AS a
        ON i.customerID = a.customerID
        WHERE i.purchaseDate < a.purchaseDate
	)
    SELECT c.CustomerID, c.CustomerName
    FROM cust_iphone_early AS cie
    LEFT JOIN 
    customers9 AS c
    ON cie.customerID = c.customerID;

SELECT 
	DISTINCT c.*
FROM customers9 as c
JOIN purchases as p1
ON c.customerid = p1.customerid
JOIN purchases p2
ON c.customerid = p2.customerid		
WHERE p1.productname = 'iPhone'
AND
p2.productname = 'Airpods'	
AND
p1.purchasedate < p2.purchasedate;
	
/*
-- Your task 
Find out what is the % of chance is there that the 
customer who bought MacBook will buy an Airpods



/*
	**********************************************************
					Day 10/50 SQL Challenge
    **********************************************************
*/
-- Create Employee table
DROP TABLE IF EXISTS employees10;

CREATE TABLE employees10 (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary NUMERIC(10, 2)
);

-- Insert sample records into Employee table
INSERT INTO employees10 (EmployeeID, FirstName, LastName, Department, Salary) VALUES
(1, 'John', 'Doe', 'Finance', 75000.00),
(2, 'Jane', 'Smith', 'HR', 60000.00),
(3, 'Michael', 'Johnson', 'IT', 45000.00),
(4, 'Emily', 'Brown', 'Marketing', 55000.00),
(5, 'David', 'Williams', 'Finance', 80000.00),
(6, 'Sarah', 'Jones', 'HR', 48000.00),
(7, 'Chris', 'Taylor', 'IT', 72000.00),
(8, 'Jessica', 'Wilson', 'Marketing', 49000.00);

/*
Write a SQL query to classify employees into three categories based on their salary:

"High" - Salary greater than $70,000
"Medium" - Salary between $50,000 and $70,000 (inclusive)
"Low" - Salary less than $50,000
Your query should return the EmployeeID, FirstName, LastName, Department, Salary, and 
a new column SalaryCategory indicating the category to which each employee belongs.
*/

SELECT *,
	CASE 
		WHEN salary > 70000 THEN 'High'
		WHEN salary BETWEEN 50000 AND 70000 THEN 'Medium'
		ELSE 'Low'
	END as salary_category
FROM Employees10;

-- Your Task is to find out count of 
-- employee for each salary category?

WITH sal_cat AS (
	SELECT *,
		CASE 
			WHEN salary > 70000 THEN 'High'
			WHEN salary BETWEEN 50000 AND 70000 THEN 'Medium'
			ELSE 'Low'
		END as salary_category
	FROM employees10
)
SELECT salary_category, COUNT(salary_category) AS cnt
FROM sal_cat
GROUP BY salary_category
ORDER BY CNT;


/*
	*************************************************
					Day 11/50
    *************************************************
*/

DROP TABLE IF EXISTS orders11;
DROP TABLE IF EXISTS returns11;
-- Create the orders table
CREATE TABLE orders11 (
    order_id VARCHAR(10),
    customer_id VARCHAR(10),
    order_date DATE,
    product_id VARCHAR(10),
    quantity INT
);

-- Create the returns table
CREATE TABLE returns11 (
    return_id VARCHAR(10),
    order_id VARCHAR(10)
);

-- Insert sample records into the orders table
INSERT INTO orders11 (order_id, customer_id, order_date, product_id, quantity)
VALUES
    ('1001', 'C001', '2023-01-15', 'P001', 4),
    ('1002', 'C001', '2023-02-20', 'P002', 3),
    ('1003', 'C002', '2023-03-10', 'P003', 8),
    ('1004', 'C003', '2023-04-05', 'P004', 2),
    ('1005', 'C004', '2023-05-20', 'P005', 3),
    ('1006', 'C002', '2023-06-15', 'P001', 6),
    ('1007', 'C003', '2023-07-20', 'P002', 1),
    ('1008', 'C004', '2023-08-10', 'P003', 2),
    ('1009', 'C005', '2023-09-05', 'P002', 3),
    ('1010', 'C001', '2023-10-20', 'P002', 1);

-- Insert sample records into the returns table
INSERT INTO returns11 (return_id, order_id) VALUES
    ('R001', '1001'),
    ('R002', '1002'),
    ('R003', '1005'),
    ('R004', '1008'),
    ('R005', '1007');

/*
Identify returning customers based on their order history. 
Categorize customers as "Returning" if they have placed more than one return, 
and as "New" otherwise. 

Considering you have two table orders has information about sale
and returns has information about returns 
*/
-- no of return for each cx
-- orders and return
-- CASE cnt > 1 then Returning else new
WITH 
	tab_join AS ( 
		SELECT r.return_id, o.*
		FROM returns11 AS r
		LEFT JOIN
		orders11 AS o
		USING (order_id)
	),
    cnt_cust AS (
		SELECT customer_id, COUNT(customer_id) AS cnt
		FROM tab_join
        GROUP BY customer_id
        ORDER BY cnt
	)
    SELECT  *, 
			CASE
				WHEN cnt < 2 THEN "New"
                ELSE "Returning"
			END AS status
    FROM cnt_cust;


SELECT
    o.customer_id,
    COUNT(o.order_id) as total_orders,
    COUNT(return_id) as total_returns,
    CASE 
        WHEN COUNT(return_id) > 1 THEN 'Returning'
        ELSE 'New'
    END as customer_category
FROM orders11 as o
LEFT JOIN returns11 as r
ON o.order_id = r.order_id    
GROUP BY customer_id;

/*
Task:
Task:
Categorize products based on their quantity sold into three categories:

"Low Demand": Quantity sold less than or equal to 5.
"Medium Demand": Quantity sold
 between 6 and 10 (inclusive).
"High Demand": Quantity sold greater than 10.
Expected Output:

Product ID
Product Name
Quantity Sold
Demand Category
*/

SELECT 	product_id, quantity,
		CASE
			WHEN quantity <= 5 THEN "Low Demand"
            WHEN quantity > 10 THEN "High Demand"
            ELSE "Medium Demand"
        END AS demand_category
FROM orders11;



/*
	**********************************************************
				Day 12/50 Days sql Challenge
    **********************************************************
*/

DROP TABLE IF EXISTS Employees12;
CREATE TABLE Employees12 (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

INSERT INTO Employees12 (id, name) VALUES
    (1, 'Alice'),
    (7, 'Bob'),
    (11, 'Meir'),
    (90, 'Winston'),
    (3, 'Jonathan');


DROP TABLE IF EXISTS EmployeeUNI;
CREATE TABLE EmployeeUNI (
    id INT PRIMARY KEY,
    unique_id INT
);

INSERT INTO EmployeeUNI (id, unique_id) VALUES
    (3, 1),
    (11, 2),
    (90, 3);

/*
Write a solution to show the unique ID of each user, 
If a user does not have a unique ID replace just show null.
Return employee name and their unique_id.

Table: Employees
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| name          | varchar |
+---------------+---------+
id is the primary key (column with unique values) for this table.
Each row of this table contains the id and the name of an employee in a company.
 
Table: EmployeeUNI
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| unique_id     | int     |
+---------------+---------+
(id, unique_id) is the primary key (combination of columns with unique values) for this table.
Each row of this table contains the id and the corresponding unique id of an employee in the company.

*/
SELECT e.id, e.name, eu.unique_id
FROM employees12 AS e
LEFT JOIN
employeeuni AS eu
USING (id);


SELECT 
    e.name,
    eu.unique_id
FROM employees as e
LEFT JOIN
employeeuni as eu
ON eu.id = e.id;

-- Your task to replace null values to 0 for the employee who doesn't have unique id


/*
	**********************************************************
				SQL Challenge Day 13/50
    **********************************************************
*/

DROP TABLE IF EXISTS employees13;
CREATE TABLE employees13 (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES employees13(emp_id)
);

INSERT INTO employees13 (emp_id, name, manager_id) VALUES
(1, 'John Doe', NULL),        -- John Doe is not a manager
(2, 'Jane Smith', 1),          -- Jane Smith's manager is John Doe
(3, 'Alice Johnson', 1),       -- Alice Johnson's manager is John Doe
(4, 'Bob Brown', 3),           -- Bob Brown's manager is Alice Johnson
(5, 'Emily White', NULL),      -- Emily White is not a manager
(6, 'Michael Lee', 3),         -- Michael Lee's manager is Alice Johnson
(7, 'David Clark', NULL),      -- David Clark is not a manager
(8, 'Sarah Davis', 2),         -- Sarah Davis's manager is Jane Smith
(9, 'Kevin Wilson', 2),        -- Kevin Wilson's manager is Jane Smith
(10, 'Laura Martinez', 4);     -- Laura Martinez's manager is Bob Brown

/*
You have a table named employees containing information about employees, 
including their emp_id, name, and manager_id. 
The manager_id refers to the emp_id of the employee's manager.
write a SQL query to retrieve all employees' 
details along with their manager's names based on the manager ID
*/

SELECT 	e1.emp_id, e1.name, e1.manager_id, 
		e2.name AS manager_name
FROM employees13 AS e1 
CROSS JOIN 
employees13 AS e2
ON e1.manager_id = e2.emp_id;

SELECT    
    e1.emp_id, e1.name, e1.manager_id,
    e2.name as manager_name
FROM employees13 as e1
CROSS JOIN 
employees13 as e2    
WHERE e1.manager_id = e2.emp_id;

-- Your Task
-- Write a SQL query to find the names of all employees who are also managers. 
-- In other words, retrieve the names of employees who appear as managers in the manager_id column.


/*
	*********************************************************
				SQL Challenge Day 14/50
    *********************************************************
*/

DROP TABLE IF EXISTS customers14;
CREATE TABLE customers14 (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100)
);

DROP TABLE IF EXISTS orders14;
CREATE TABLE orders14 (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers14(customer_id)
);

INSERT INTO customers14 (customer_id, customer_name, customer_email) VALUES
(1, 'John Doe', 'john@example.com'),
(2, 'Jane Smith', 'jane@example.com'),
(3, 'Alice Johnson', 'alice@example.com'),
(4, 'Bob Brown', 'bob@example.com');

INSERT INTO orders14 (order_id, customer_id, order_date, order_amount) VALUES
(1, 1, '2024-01-03', 50.00),
(2, 2, '2024-01-05', 75.00),
(3, 1, '2024-01-10', 25.00),
(4, 3, '2024-01-15', 60.00),
(5, 2, '2024-01-20', 50.00),
(6, 1, '2024-02-01', 100.00),
(7, 2, '2024-02-05', 25.00),
(8, 3, '2024-02-10', 90.00),
(9, 1, '2024-02-15', 50.00),
(10, 2, '2024-02-20', 75.00);

/*
You are given two tables: orders and customers. 
The orders table contains information about orders placed by customers, including the order_id, customer_id, order_date, and order_amount. 

The customers table contains information about customers, 
including the customer_id, customer_name, and customer_email.

-- Find the top 2 customers who have spent the most money across all their orders. 
Return their names, emails, and total amounts spent.

*/
-- customer_name
-- customer_email
-- total_amt from orders
-- join based cx id form both table
-- order by total amt desc
-- limit 2
WITH 
	temp_tab AS (
		SELECT  c.customer_id, c.customer_name, c.customer_email, o.order_amount
		FROM customers14 AS c
		LEFT JOIN 
		orders14 AS o
		USING (customer_id)
	)
    
    SELECT customer_name, customer_email, SUM(order_amount) AS total_spent
    FROM temp_tab
    GROUP BY customer_name, customer_email;




SELECT
    c.customer_name,
    c.customer_email,
    SUM(o.order_amount) as total_spent
FROM customers14 as c
JOIN
orders14 as o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name,  c.customer_email
ORDER BY total_spent DESC
LIMIT 2;

-- Your Task
-- Find out customers details who has placed highest orders and total count of orders and total order amount

SELECT
    c.customer_name,
    c.customer_email,
    SUM(o.order_amount) as total_spent
FROM customers14 as c
JOIN
orders14 as o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name,  c.customer_email
ORDER BY total_spent DESC;

/*
	*******************************************
			Day 15/50 SQL Challenge
    *******************************************
*/
 
-- Creating the orders table
DROP TABLE IF EXISTS orders15;
CREATE TABLE orders15 (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2)
);

-- Inserting records for the current month
INSERT INTO orders15 (order_date, product_id, quantity, price) VALUES
    ('2024-04-01', 1, 10, 50.00),
    ('2024-04-02', 2, 8, 40.00),
    ('2024-04-03', 3, 15, 30.00),
    ('2024-04-04', 4, 12, 25.00),
    ('2024-04-05', 5, 5, 60.00),
    ('2024-04-06', 6, 20, 20.00),
    ('2024-04-07', 7, 18, 35.00),
    ('2024-04-08', 8, 14, 45.00),
    ('2024-04-09', 1, 10, 50.00),
    ('2024-04-10', 2, 8, 40.00);

-- Inserting records for the last month
INSERT INTO orders15 (order_date, product_id, quantity, price) VALUES
    ('2024-03-01', 1, 12, 50.00),
    ('2024-03-02', 2, 10, 40.00),
    ('2024-03-03', 3, 18, 30.00),
    ('2024-03-04', 4, 14, 25.00),
    ('2024-03-05', 5, 7, 60.00),
    ('2024-03-06', 6, 22, 20.00),
    ('2024-03-07', 7, 20, 35.00),
    ('2024-03-08', 8, 16, 45.00),
    ('2024-03-09', 1, 12, 50.00),
    ('2024-03-10', 2, 10, 40.00);

-- Inserting records for the previous month
INSERT INTO orders15 (order_date, product_id, quantity, price) VALUES
    ('2024-02-01', 1, 15, 50.00),
    ('2024-02-02', 2, 12, 40.00),
    ('2024-02-03', 3, 20, 30.00),
    ('2024-02-04', 4, 16, 25.00),
    ('2024-02-05', 5, 9, 60.00),
    ('2024-02-06', 6, 25, 20.00),
    ('2024-02-07', 7, 22, 35.00),
    ('2024-02-08', 8, 18, 45.00),
    ('2024-02-09', 1, 15, 50.00),
    ('2024-02-10', 2, 12, 40.00);
    
/*
Write an SQL query to retrieve the product details for items whose revenue 
decreased compared to the previous month. 

Display the product ID, quantity sold, 
and revenue for both the current and previous months.
*/

-- product_id total sale for current
-- current month
-- group by product_id

WITH 
	current_month_revenue AS (    
		SELECT
			product_id,
			SUM(quantity) as qty_sold,
			SUM(price * quantity) as current_month_rev
		FROM orders15
		WHERE EXTRACT(MONTH FROM order_date) = EXTRACT(MONTH FROM "2024-4-20") 
		GROUP BY product_id
	),
	prev_month_revenue AS (
		SELECT
			product_id,
			SUM(quantity) as qty_sold,
			SUM(price * quantity) as prev_month_rev
		FROM orders15
		WHERE EXTRACT(MONTH FROM order_date) = EXTRACT(MONTH FROM "2024-4-20")-1 
		GROUP BY product_id
	)
	SELECT
		cr.product_id,
		cr.qty_sold as cr_month_qty,
		pr.qty_sold as pr_month_qty,
		cr.current_month_rev,
		pr.prev_month_rev
	FROM current_month_revenue as cr
	JOIN 
	prev_month_revenue as pr
	ON cr.product_id = pr.product_id
	WHERE cr.current_month_rev < pr.prev_month_rev;

/*
		Task: Write a SQL query to find the products whose total revenue 
        has decreased by more than 10% from the previous month to the current month.
*/

WITH 
	current_month_revenue AS (    
		SELECT
			product_id,
			SUM(quantity) as qty_sold,
			SUM(price * quantity) as current_month_rev
		FROM orders15
		WHERE EXTRACT(MONTH FROM order_date) = EXTRACT(MONTH FROM "2024-4-20") 
		GROUP BY product_id
	),
	prev_month_revenue AS (
		SELECT
			product_id,
			SUM(quantity) as qty_sold,
			SUM(price * quantity) as prev_month_rev
		FROM orders15
		WHERE EXTRACT(MONTH FROM order_date) = EXTRACT(MONTH FROM "2024-4-20")-1 
		GROUP BY product_id
	)
	SELECT
		cr.product_id,
		cr.qty_sold as cr_month_qty,
		pr.qty_sold as pr_month_qty,
		cr.current_month_rev,
		pr.prev_month_rev
	FROM current_month_revenue as cr
	JOIN 
	prev_month_revenue as pr
	ON cr.product_id = pr.product_id
	WHERE cr.current_month_rev < (90 * pr.prev_month_rev/100);
    
    
/*
	********************************************************
				Day 16/50 SQL Challenge
    ********************************************************
*/
DROP TABLE IF EXISTS employees16;
CREATE TABLE Employees16 (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    department VARCHAR(255),
    managerId INT
);

INSERT INTO Employees16 (id, name, department, managerId) VALUES
(101, 'John', 'A', NULL),
(102, 'Dan', 'A', 101),
(103, 'James', 'A', 101),
(104, 'Amy', 'A', 101),
(105, 'Anne', 'A', 101),
(106, 'Ron', 'B', 101),
(107, 'Michael', 'C', NULL),
(108, 'Sarah', 'C', 107),
(109, 'Emily', 'C', 107),
(110, 'Brian', 'C', 107);

/*
Given a table named employees with the following columns:
id, name, department, managerId

Write a SQL query to find the names of 
managers who have at least five direct reports. 
Return the result table in any order.
Ensure that no employee is their own manager.

The result format should include only the names
of the managers meeting the criteria.
*/

-- find manager name based on manager id
-- count of emp who is reporting to this id
-- having count >= 5

SELECT 
     e2.name AS manager_name
FROM employees16 AS e1
JOIN 
employees16 AS e2
ON e1.managerid = e2.id
GROUP BY e1.managerid, e2.name
HAVING COUNT(e1.id) >= 5;

-- Your Task is to find out the total employees who doesn't have any managers!

SELECT 
     COUNT(name) AS Cnt_no_manager
FROM employees16
WHERE managerid is NULL
GROUP BY managerid;

/*
	*************************************************************
							Day 17/50
    *************************************************************
*/

DROP TABLE IF EXISTS customers17;
-- Creating the Customers table
CREATE TABLE Customers17 (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);

DROP TABLE IF EXISTS purchases17;
-- Creating the Purchases table
CREATE TABLE Purchases17 (
    purchase_id INT PRIMARY KEY,
    customer_id INT,
    product_category VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customers17(customer_id)
);

-- Inserting sample data into Customers table
INSERT INTO Customers17 (customer_id, customer_name) VALUES
    (1, 'Alice'),
    (2, 'Bob'),
    (3, 'Charlie'),
    (4, 'David'),
    (5, 'Emma');

-- Inserting sample data into Purchases table
INSERT INTO Purchases17 (purchase_id, customer_id, product_category) VALUES
    (101, 1, 'Electronics'),
    (102, 1, 'Books'),
    (103, 1, 'Clothing'),
    (104, 1, 'Electronics'),
    (105, 2, 'Clothing'),
    (106, 1, 'Beauty'),
    (107, 3, 'Electronics'),
    (108, 3, 'Books'),
    (109, 4, 'Books'),
    (110, 4, 'Clothing'),
    (111, 4, 'Beauty'),
    (112, 5, 'Electronics'),
    (113, 5, 'Books');

/*
Question:
Write an SQL query to find customers who have made 
purchases in all product categories.

Tables:
Customers: customer_id (INT), customer_name (VARCHAR)

Purchases: purchase_id (INT), customer_id (INT), 
product_category (VARCHAR)

Your query should return the customer_id and 
customer_name of these customers.
*/

-- cx_id, cx_name
-- find total distinct category 
-- how many distinct category each cx purchase from 
-- join both 
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT p.product_category) AS cnt_prod_cat
FROM customers17 as c
JOIN 
purchases17 as p
ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING  COUNT(DISTINCT p.product_category) = 
(SELECT COUNT(DISTINCT product_category) FROM purchases17);

/*
Task:
	Write an SQL query to identify customers who have not made any purchases 
	in Electronics categories.
*/
SELECT customer_id, customer_name
FROM customers17
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM purchases17
    WHERE product_category = 'Electronics'
);


/*
	******************************************
				Day 18/50
    ******************************************
*/
-- Creating the hotel_bookings table
CREATE TABLE hotel_bookings (
    booking_id SERIAL PRIMARY KEY,
    booking_date DATE,
    hotel_name VARCHAR(100),
    total_guests INT,
    total_nights INT,
    total_price DECIMAL(10, 2)
);

-- Inserting sample data for hotel bookings for 2023 and 2022
INSERT INTO hotel_bookings (booking_date, hotel_name, total_guests, total_nights, total_price) VALUES
    ('2023-01-05', 'Hotel A', 2, 3, 300.00),
    ('2023-02-10', 'Hotel B', 3, 5, 600.00),
    ('2023-03-15', 'Hotel A', 4, 2, 400.00),
    ('2023-04-20', 'Hotel B', 2, 4, 500.00),
    ('2023-05-25', 'Hotel A', 3, 3, 450.00),
    ('2023-06-30', 'Hotel B', 5, 2, 350.00),
    ('2023-07-05', 'Hotel A', 2, 5, 550.00),
    ('2023-08-10', 'Hotel B', 3, 3, 450.00),
    ('2023-09-15', 'Hotel A', 4, 4, 500.00),
    ('2023-10-20', 'Hotel B', 2, 3, 300.00),
    ('2023-11-25', 'Hotel A', 3, 2, 350.00),
    ('2023-12-30', 'Hotel B', 5, 4, 600.00),
    ('2022-01-05', 'Hotel A', 2, 3, 300.00),
    ('2022-02-10', 'Hotel B', 3, 5, 600.00),
    ('2022-03-15', 'Hotel A', 4, 2, 400.00),
    ('2022-04-20', 'Hotel B', 2, 4, 500.00),
    ('2022-05-25', 'Hotel A', 3, 3, 450.00),
    ('2022-06-30', 'Hotel B', 5, 2, 350.00),
    ('2022-07-05', 'Hotel A', 2, 5, 550.00),
    ('2022-08-10', 'Hotel B', 3, 3, 450.00),
    ('2022-09-15', 'Hotel A', 4, 4, 500.00),
    ('2022-10-20', 'Hotel B', 2, 3, 300.00),
    ('2022-11-25', 'Hotel A', 3, 2, 350.00),
    ('2022-12-30', 'Hotel B', 5, 4, 600.00);

/*
	Write a SQL query to find out each hotal best 
	performing months based on revenue 
*/
-- hotel_name, revenue for each month -- group by
-- window function ranking 
WITH 
	month_rev AS (
		SELECT 	EXTRACT(YEAR FROM booking_date) as year,
				EXTRACT(MONTH FROM booking_date) as month,
				hotel_name,
				SUM(total_price) as revenue
		FROM hotel_bookings
		GROUP BY 1, 2,3 -- GROUP BY year, month, hotel_name
		ORDER BY year ASC, revenue DESC
	),
	month_rank_rev AS (
		SELECT 	year, month, hotel_name, revenue,
				RANK() OVER(PARTITION BY year, hotel_name ORDER BY revenue DESC) AS rnk
		FROM month_rev
	)
    SELECT * 
    FROM month_rank_rev
    WHERE rnk = 1;

SELECT *
FROM (    
    SELECT 
        year,
        month,
        hotel_name,
        revenue,
        RANK() OVER(PARTITION BY year, hotel_name ORDER BY revenue DESC) as rn
    FROM 
        (
        SELECT
            EXTRACT(YEAR FROM booking_date) as year,
            EXTRACT(MONTH FROM booking_date) as month,
            hotel_name,
            SUM(total_price) as revenue
        FROM hotel_bookings
        GROUP BY 1, 2,3 -- GROUP BY year, month, hotel_name
        ORDER BY year ASC, revenue DESC
    ) as monthly_revenue
) as subquery
WHERE rn = 1;

/*
	******************************************
				Day 19/50 SQL Challenge
    ******************************************
*/

DROP TABLE IF EXISTS employees19;
-- Creating the employees table
CREATE TABLE employees19 (
    employee_id SERIAL PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

-- Inserting sample data for employees
INSERT INTO employees19 (employee_name, department, salary) 
VALUES
    ('John Doe', 'HR', 50000.00),
    ('Jane Smith', 'HR', 55000.00),
    ('Michael Johnson', 'HR', 60000.00),
    ('Emily Davis', 'IT', 60000.00),
    ('David Brown', 'IT', 65000.00),
    ('Sarah Wilson', 'Finance', 70000.00),
    ('Robert Taylor', 'Finance', 75000.00),
    ('Jennifer Martinez', 'Finance', 80000.00);

/*
-- Q.
You have a table with below COLUMNS
emp_id employee_name, department, salary


Find the details of employees whose salary is greater
than the average salary across the entire company.
*/

-- Find avg salary - 64375
-- select * from employees use where salary > Find avg salary

SELECT * 
FROM employees19
WHERE salary > (SELECT AVG(salary) from employees19);

/*
-- Your Task:
Question:
Find the average salary of employees in each department, 
along with the total number of employees in that department.
*/
SELECT 	department, COUNT(employee_id) AS emp_cnt_in_dept, 
		AVG(salary) AS avg_salary_dept
FROM employees19
GROUP BY department;


/*
	***********************************************************
				Day 20/50 Days SQL Challenge
    ***********************************************************
*/

DROP TABLE IF EXISTS products20;
CREATE TABLE products20 (
    product_id INT,
    product_name VARCHAR(100),
    supplier_name VARCHAR(50)
);

INSERT INTO products20 (product_id, product_name, supplier_name) VALUES
    (1, 'Product 1', 'Supplier A'),
    (1, 'Product 1', 'Supplier B'),
    (3, 'Product 3', 'Supplier A'),
    (3, 'Product 3', 'Supplier A'),
    (5, 'Product 5', 'Supplier A'),
    (5, 'Product 5', 'Supplier B'),
    (7, 'Product 7', 'Supplier C'),
    (8, 'Product 8', 'Supplier A'),
    (7, 'Product 7', 'Supplier B'),
    (7, 'Product 7', 'Supplier A'),
    (9, 'Product 9', 'Supplier B'),
    (9, 'Product 9', 'Supplier C'),
    (10, 'Product 10', 'Supplier C'),
    (11, 'Product 11', 'Supplier C'),
    (10, 'Product 10', 'Supplier A');

/*
	Write a query to find products that are sold by 
	both Supplier A and Supplier B, 
	excluding products sold by only one supplier.
*/

-- product_id, product_name
-- sold by supplier a and B where 

SELECT 
    product_id, 
    product_name
    -- COUNT(supplier_name) as cnt_sellers
FROM products20
WHERE supplier_name IN ('Supplier A', 'Supplier B')
GROUP BY product_id, product_name
HAVING COUNT(DISTINCT supplier_name) = 2;

-- Your Task
-- Find the product that are selling by Supplier C and Supplier B but not Supplier A

/*
	************************************************
			Day 21/50 Days SQL Challenge
    ************************************************
*/

DROP TABLE IF EXISTS products21;
-- Creating the products table
CREATE TABLE products21 (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    quantity_sold INT
);
-- Inserting sample data for products
INSERT INTO products21 (product_id, product_name, price, quantity_sold) VALUES
    (1, 'iPhone', 899.00, 600),
    (2, 'iMac', 1299.00, 150),
    (3, 'MacBook Pro', 1499.00, 500),
    (4, 'AirPods', 499.00, 800),
    (5, 'Accessories', 199.00, 300);
/*
-- Question 
You have a table called products with below columns
product_id, product_name, price, qty 

Calculate the percentage contribution of each product 
to total revenue? Round the result into 2 decimal
*/

-- total revenue 
-- sales by each product 
-- sales by product/total revenue  * 100

SELECT 	product_id, product_name, 
		price * quantity_sold AS product_revenue,
        ROUND(price * quantity_sold * 100/ (SELECT SUM(price * quantity_sold) 
											FROM products21), 2) AS contribution_in_percentage
FROM products21;

 SELECT
    product_id,
    product_name,
    price * quantity_sold as revenue_by_product,
    ROUND(price * quantity_sold/(SELECT SUM(price * quantity_sold) from products21) * 100, 2) as contribution
FROM products21;

/*
-- Your Task
Find what is the contribution of MacBook Pro and iPhone
Round the result in two DECIMAL
*/
WITH 
	prod_contri AS (
		SELECT  product_id, product_name,
				price * quantity_sold as revenue_by_product,
				ROUND(price * quantity_sold/(SELECT SUM(price * quantity_sold) from products21) * 100, 2) as contribution
		FROM products21
	)
    SELECT 	ROUND(SUM(revenue_by_product) * 100 / (SELECT SUM(price * quantity_sold) from products21), 2) AS mac_iphone_contri,
			SUM(contribution)
    FROM prod_contri
    WHERE product_name IN ('iPhone', 'MacBook Pro');
    
SELECT SUM(ROUND(price * quantity_sold/(SELECT SUM(price * quantity_sold) 
										FROM products21) * 100, 2))as contribution
FROM products21
WHERE product_name IN ('iPhone', 'MacBook Pro');   

/*
	********************************************
			Day 22/50 SQL Challenge
    ********************************************
*/

DROP TABLE IF EXISTS delivery;
-- Create the Delivery table
CREATE TABLE Delivery (
    delivery_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    customer_pref_delivery_date DATE
);

-- Insert data into the Delivery table
INSERT INTO Delivery (customer_id, order_date, customer_pref_delivery_date) VALUES
(1, '2019-08-01', '2019-08-02'),
(2, '2019-08-02', '2019-08-02'),
(1, '2019-08-11', '2019-08-12'),
(3, '2019-08-24', '2019-08-24'),
(3, '2019-08-21', '2019-08-22'),
(2, '2019-08-11', '2019-08-13'),
(4, '2019-08-09', '2019-08-09'),
(5, '2019-08-09', '2019-08-10'),
(4, '2019-08-10', '2019-08-12'),
(6, '2019-08-09', '2019-08-11'),
(7, '2019-08-12', '2019-08-13'),
(8, '2019-08-13', '2019-08-13'),
(9, '2019-08-11', '2019-08-12');    

/*
-- Question
You have dataset of a food delivery company
with columns order_id, customer_id, order_date, 
pref_delivery_date


If the customer's preferred delivery date is 
the same as the order date, then the order is 
called immediate; otherwise, it is called scheduled.


Write a solution to find the percentage of immediate
orders in the first orders of all customers, 
rounded to 2 decimal places.

*/
-- find first orders of each cx
-- total cnt of first orders 
-- case immediate or scheduled
-- total immediate orders / total cnt of first orders * 100
-- round 2

WITH 
	order_status AS (
		SELECT  *,
				CASE 
					WHEN order_date = customer_pref_delivery_date THEN "immediate"
                    ELSE "scheduled"
                END AS ord_status
        FROM Delivery
    )
SELECT ROUND(COUNT(ord_status) * 100/(SELECT COUNT(DISTINCT customer_id) FROM Delivery), 2) AS share
FROM order_status
WHERE ord_status LIKE "%immediate%"
GROUP BY ord_status;

/* 
-- Your task
Your Challenge:
Write an SQL query to determine the percentage
of orders where customers select next day delivery. 
We're excited to see your solution! 

-- Next Day Delivery is Order Date + 1
*/

/*
	*******************************************************
				Day 23/50 SQL Challenge
    *******************************************************
*/

DROP TABLE IF EXISTS amazon_transactions;
CREATE TABLE amazon_transactions (
    id SERIAL PRIMARY KEY,
    user_id INT,
    item VARCHAR(255),
    purchase_date DATE,
    revenue NUMERIC
);

INSERT INTO amazon_transactions (user_id, item, purchase_date, revenue) VALUES
(109, 'milk', '2020-03-03', 123),
(139, 'biscuit', '2020-03-18', 421),
(120, 'milk', '2020-03-18', 176),
(108, 'banana', '2020-03-18', 862),
(130, 'milk', '2020-03-28', 333),
(103, 'bread', '2020-03-29', 862),
(122, 'banana', '2020-03-07', 952),
(125, 'bread', '2020-03-13', 317),
(139, 'bread', '2020-03-30', 929),
(141, 'banana', '2020-03-17', 812),
(116, 'bread', '2020-03-31', 226),
(128, 'bread', '2020-03-04', 112),
(146, 'biscuit', '2020-03-04', 362),
(119, 'banana', '2020-03-28', 127),
(142, 'bread', '2020-03-09', 503),
(122, 'bread', '2020-03-06', 593),
(128, 'biscuit', '2020-03-24', 160),
(112, 'banana', '2020-03-24', 262),
(149, 'banana', '2020-03-29', 382),
(100, 'banana', '2020-03-18', 599),
(130, 'milk', '2020-03-16', 604),
(103, 'milk', '2020-03-31', 290),
(112, 'banana', '2020-03-23', 523),
(102, 'bread', '2020-03-25', 325),
(120, 'biscuit', '2020-03-21', 858),
(109, 'bread', '2020-03-22', 432),
(101, 'milk', '2020-03-01', 449),
(138, 'milk', '2020-03-19', 961),
(100, 'milk', '2020-03-29', 410),
(129, 'milk', '2020-03-02', 771),
(123, 'milk', '2020-03-31', 434),
(104, 'biscuit', '2020-03-31', 957),
(110, 'bread', '2020-03-13', 210),
(143, 'bread', '2020-03-27', 870),
(130, 'milk', '2020-03-12', 176),
(128, 'milk', '2020-03-28', 498),
(133, 'banana', '2020-03-21', 837),
(150, 'banana', '2020-03-20', 927),
(120, 'milk', '2020-03-27', 793),
(109, 'bread', '2020-03-02', 362),
(110, 'bread', '2020-03-13', 262),
(140, 'milk', '2020-03-09', 468),
(112, 'banana', '2020-03-04', 381),
(117, 'biscuit', '2020-03-19', 831),
(137, 'banana', '2020-03-23', 490),
(130, 'bread', '2020-03-09', 149),
(133, 'bread', '2020-03-08', 658),
(143, 'milk', '2020-03-11', 317),
(111, 'biscuit', '2020-03-23', 204),
(150, 'banana', '2020-03-04', 299),
(131, 'bread', '2020-03-10', 155),
(140, 'biscuit', '2020-03-17', 810),
(147, 'banana', '2020-03-22', 702),
(119, 'biscuit', '2020-03-15', 355),
(116, 'milk', '2020-03-12', 468),
(141, 'milk', '2020-03-14', 254),
(143, 'bread', '2020-03-16', 647),
(105, 'bread', '2020-03-21', 562),
(149, 'biscuit', '2020-03-11', 827),
(117, 'banana', '2020-03-22', 249),
(150, 'banana', '2020-03-21', 450),
(134, 'bread', '2020-03-08', 981),
(133, 'banana', '2020-03-26', 353),
(127, 'milk', '2020-03-27', 300),
(101, 'milk', '2020-03-26', 740),
(137, 'biscuit', '2020-03-12', 473),
(113, 'biscuit', '2020-03-21', 278),
(141, 'bread', '2020-03-21', 118),
(112, 'biscuit', '2020-03-14', 334),
(118, 'milk', '2020-03-30', 603),
(111, 'milk', '2020-03-19', 205),
(146, 'biscuit', '2020-03-13', 599),
(148, 'banana', '2020-03-14', 530),
(100, 'banana', '2020-03-13', 175),
(105, 'banana', '2020-03-05', 815),
(129, 'milk', '2020-03-02', 489),
(121, 'milk', '2020-03-16', 476),
(117, 'bread', '2020-03-11', 270),
(133, 'milk', '2020-03-12', 446),
(124, 'bread', '2020-03-31', 937),
(145, 'bread', '2020-03-07', 821),
(105, 'banana', '2020-03-09', 972),
(131, 'milk', '2020-03-09', 808),
(114, 'biscuit', '2020-03-31', 202),
(120, 'milk', '2020-03-06', 898),
(130, 'milk', '2020-03-06', 581),
(141, 'biscuit', '2020-03-11', 749),
(147, 'bread', '2020-03-14', 262),
(118, 'milk', '2020-03-15', 735),
(136, 'biscuit', '2020-03-22', 410),
(132, 'bread', '2020-03-06', 161),
(137, 'biscuit', '2020-03-31', 427),
(107, 'bread', '2020-03-01', 701),
(111, 'biscuit', '2020-03-18', 218),
(100, 'bread', '2020-03-07', 410),
(106, 'milk', '2020-03-21', 379),
(114, 'banana', '2020-03-25', 705),
(110, 'bread', '2020-03-27', 225),
(130, 'milk', '2020-03-16', 494),
(117, 'bread', '2020-03-10', 209);

/*
-- Amazon Data Analyst Interview Question :
Write a query that'll identify returning active users. 

A returning active user is a user that has made a 
second purchase within 7 days of their first purchase

Output a list of user_ids of these returning active users.
*/
-- find out first purchase
-- second purchase >= 7
-- join both table 
-- DISTINCT user
SELECT  DISTINCT a1.user_id as active_users
		-- a1.purchase_date as first_purchase,
		-- a2.purchase_date as second_purchase,
		-- a2.purchase_date - a1.purchase_date AS days
FROM amazon_transactions a1 -- first purchase table
JOIN amazon_transactions a2 -- second purchase table 
ON a1.user_id = a2.user_id    
AND a1.purchase_date < a2.purchase_date
AND a2.purchase_date - a1.purchase_date <= 7
ORDER BY active_users;

/*
-- Your TASK
Find the user_id who has not purchased anything for 7 days 
after first purchase but they have done second purchase after 7 days 
*/
    
/*
-- Your Task:
Question:
Find the average salary of employees in each department, 
along with the total number of employees in that department.
*/

/*
	***************************************************************
				Day 24/50 Days
    **************************************************************
*/

DROP TABLE IF EXISTS orders24;
CREATE TABLE orders24 (
    id INT,
    cust_id INT,
    order_date DATE,
    order_details VARCHAR(50),
    total_order_cost INT
);

INSERT INTO orders24 (id, cust_id, order_date, order_details, total_order_cost) VALUES
(1, 7, '2019-03-04', 'Coat', 100),
(2, 7, '2019-03-01', 'Shoes', 80),
(3, 3, '2019-03-07', 'Skirt', 30),
(4, 7, '2019-02-01', 'Coat', 25),
(5, 7, '2019-03-10', 'Shoes', 80),
(6, 1, '2019-02-01', 'Boats', 100),
(7, 2, '2019-01-11', 'Shirts', 60),
(8, 1, '2019-03-11', 'Slipper', 20),
(9, 15, '2019-03-01', 'Jeans', 80),
(10, 15, '2019-03-09', 'Shirts', 50),
(11, 5, '2019-02-01', 'Shoes', 80),
(12, 12, '2019-01-11', 'Shirts', 60),
(13, 1, '2019-03-11', 'Slipper', 20),
(14, 4, '2019-02-01', 'Shoes', 80),
(15, 4, '2019-01-11', 'Shirts', 60),
(16, 3, '2019-04-19', 'Shirts', 50),
(17, 7, '2019-04-19', 'Suit', 150),
(18, 15, '2019-04-19', 'Skirt', 30),
(19, 15, '2019-04-20', 'Dresses', 200),
(20, 12, '2019-01-11', 'Coat', 125),
(21, 7, '2019-04-01', 'Suit', 50),
(22, 3, '2019-04-02', 'Skirt', 30),
(23, 4, '2019-04-03', 'Dresses', 50),
(24, 2, '2019-04-04', 'Coat', 25),
(25, 7, '2019-04-19', 'Coat', 125);

/*
Calculate the total revenue from each customer in March 2019. 
Include only customers who were active in March 2019.
Output the revenue along with the customer id and sort the results based 
on the revenue in descending order.
*/
-- cx_id and their revenue SUM(total order cost)
-- filter march 2019
SELECT  cust_id, 
        SUM(total_order_cost) AS total_cost
FROM orders24
WHERE order_date LIKE "%2019-03%" -- WHERE order_date BETWEEN '2019-03-01' AND '2019-03-31'
GROUP BY cust_id
ORDER BY total_cost DESC;

SELECT 
    cust_id,
    SUM(total_order_cost) total_revenue
FROM orders24
WHERE order_date BETWEEN '2019-03-01' 
    AND '2019-03-31'
GROUP BY cust_id
ORDER BY total_revenue DESC;

/*
-- Your Task
Find the customers who purchased from both 
March and April of 2019 and their total revenue 
*/
SELECT 	cust_id,
		SUM(total_order_cost) total_revenue
FROM orders24
WHERE order_date BETWEEN '2019-03-01' AND '2019-04-30'
GROUP BY cust_id
ORDER BY total_revenue DESC;

/*
	*****************************************************
				Day 25/50 days sql challenge
    *****************************************************
*/
DROP TABLE  IF EXISTS customers25;
CREATE TABLE customers25 (
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    city VARCHAR(50),
    address VARCHAR(100),
    phone_number VARCHAR(20)
);
-- Inserting sample data into the customers table
INSERT INTO customers25 (id, first_name, last_name, city, address, phone_number) VALUES
    (8, 'John', 'Joseph', 'San Francisco', NULL, '928868164'),
    (7, 'Jill', 'Michael', 'Austin', NULL, '8130567692'),
    (4, 'William', 'Daniel', 'Denver', NULL, '813155200'),
    (5, 'Henry', 'Jackson', 'Miami', NULL, '8084557513'),
    (13, 'Emma', 'Isaac', 'Miami', NULL, '808690201'),
    (14, 'Liam', 'Samuel', 'Miami', NULL, '808555201'),
    (15, 'Mia', 'Owen', 'Miami', NULL, '806405201'),
    (1, 'Mark', 'Thomas', 'Arizona', '4476 Parkway Drive', '602325916'),
    (12, 'Eva', 'Lucas', 'Arizona', '4379 Skips Lane', '3019509805'),
    (6, 'Jack', 'Aiden', 'Arizona', '4833 Coplin Avenue', '480230527'),
    (2, 'Mona', 'Adrian', 'Los Angeles', '1958 Peck Court', '714939432'),
    (10, 'Lili', 'Oliver', 'Los Angeles', '3832 Euclid Avenue', '5306951180'),
    (3, 'Farida', 'Joseph', 'San Francisco', '3153 Rhapsody Street', '8133681200'),
    (9, 'Justin', 'Alexander', 'Denver', '4470 McKinley Avenue', '9704337589'),
    (11, 'Frank', 'Jacob', 'Miami', '1299 Randall Drive', '8085905201');
CREATE TABLE orders25 (
    id INT PRIMARY KEY,
    cust_id INT,
    order_date DATE,
    order_details VARCHAR(100),
    total_order_cost INT
);

-- Inserting sample data into the orders table
INSERT INTO orders25 (id, cust_id, order_date, order_details, total_order_cost) VALUES
    (1, 3, '2019-03-04', 'Coat', 100),
    (2, 3, '2019-03-01', 'Shoes', 80),
    (3, 3, '2019-03-07', 'Skirt', 30),
    (4, 7, '2019-02-01', 'Coat', 25),
    (5, 7, '2019-03-10', 'Shoes', 80),
    (6, 15, '2019-02-01', 'Boats', 100),
    (7, 15, '2019-01-11', 'Shirts', 60),
    (8, 15, '2019-03-11', 'Slipper', 20),
    (9, 15, '2019-03-01', 'Jeans', 80),
    (10, 15, '2019-03-09', 'Shirts', 50),
    (11, 5, '2019-02-01', 'Shoes', 80),
    (12, 12, '2019-01-11', 'Shirts', 60),
    (13, 12, '2019-03-11', 'Slipper', 20),
    (14, 4, '2019-02-01', 'Shoes', 80),
    (15, 4, '2019-01-11', 'Shirts', 60),
    (16, 3, '2019-04-19', 'Shirts', 50),
    (17, 7, '2019-04-19', 'Suit', 150),
    (18, 15, '2019-04-19', 'Skirt', 30),
    (19, 15, '2019-04-20', 'Dresses', 200),
    (20, 12, '2019-01-11', 'Coat', 125),
    (21, 7, '2019-04-01', 'Suit', 50),
    (22, 7, '2019-04-02', 'Skirt', 30),
    (23, 7, '2019-04-03', 'Dresses', 50),
    (24, 7, '2019-04-04', 'Coat', 25),
    (25, 7, '2019-04-19', 'Coat', 125);
/*
Find the percentage of shipable orders.
Consider an order is shipable if the customer's address is known.
*/

-- 10 5/10*100 
-- find total orders
-- total shipable orders where address is not NULL
-- shipable orders/total orders * 100
SELECT 	o.id, o.cust_id, o.order_date, o.order_details, o.total_order_cost,
		c.first_name, c.last_name, c.city, c.address, c.phone_number
FROM customers25 AS c
LEFT JOIN orders25 AS o
USING (id)
WHERE c.address IS NOT NULL;

WITH 
	shippable_orders AS (
		SELECT COUNT(*) AS cnt_ship_orders
        FROM customers25 AS c
		LEFT JOIN orders25 AS o
		USING (id)
		WHERE c.address IS NOT NULL
	)
    SELECT ROUND(100 * cnt_ship_orders/(SELECT COUNT(*) FROM orders25), 2) AS shippable_share
    FROM shippable_orders;

/*
Your Task : Find out the percentage of orders where customer doesn't have valid phone numbers 
Note : The Length of valid phone no is 10 character 
*/

WITH 
	cust_valid_phone_num AS (
		SELECT 	o.id, o.cust_id, o.order_date, o.order_details, o.total_order_cost,
				c.first_name, c.last_name, c.city, c.address, c.phone_number
		FROM customers25 AS c
		LEFT JOIN orders25 AS o
		USING (id)
		WHERE O.cust_id NOT IN (SELECT cust_id 
								FROM customers25
                                HAVING LENGTH(c.phone_number) != 10)
	)
SELECT ROUND(100 * COUNT(*)/(SELECT COUNT(*) FROM orders25), 2) AS prng_valid_phone
FROM cust_valid_phone_num;


/*
	************************************************************
				SQL Challenge 26/50
    ************************************************************
*/

CREATE TABLE employees26 (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(100),
    salary DECIMAL(10, 2),
    manager_id INT
);

INSERT INTO employees26 (employee_id, employee_name, department, salary, manager_id)
VALUES
    (1, 'John Doe', 'HR', 50000.00, NULL),
    (2, 'Jane Smith', 'HR', 55000.00, 1),
    (3, 'Michael Johnson', 'HR', 60000.00, 1),
    (4, 'Emily Davis', 'IT', 60000.00, NULL),
    (5, 'David Brown', 'IT', 65000.00, 4),
    (6, 'Sarah Wilson', 'Finance', 70000.00, NULL),
    (7, 'Robert Taylor', 'Finance', 75000.00, 6),
    (8, 'Jennifer Martinez', 'Finance', 80000.00, 6);
/*
Question :
	Identify employees who have a higher salary than their manager. 
*/

SELECT 	e.employee_id, e.employee_name, e.salary,
		m.employee_name AS manger_name, m.salary AS manager_Salary
FROM employees26 AS e
LEFT JOIN employees26 AS m
ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
        

-- Your task
-- Find all the employee who has salary greater than average salary?
SELECT * 
FROM employees26
WHERE salary > (SELECT AVG(salary) FROM employees26);

/*
	*******************************************************
				Day 27/50 SQL challenge
    *******************************************************
*/
DROP TABLE IF EXISTS walmart_eu;
CREATE TABLE walmart_eu (
    invoiceno VARCHAR(255),
    stockcode VARCHAR(255),
    description VARCHAR(255),
    quantity INT,
    invoicedate DATE,
    unitprice FLOAT,
    customerid FLOAT,
    country VARCHAR(255)
);

-- Insert the provided data into the online_retail table
INSERT INTO walmart_eu (invoiceno, stockcode, description, quantity, invoicedate, unitprice, customerid, country) VALUES
('544586', '21890', 'S/6 WOODEN SKITTLES IN COTTON BAG', 3, '2011-02-21', 2.95, 17338, 'United Kingdom'),
('541104', '84509G', 'SET OF 4 FAIRY CAKE PLACEMATS', 3, '2011-01-13', 3.29, NULL, 'United Kingdom'),
('560772', '22499', 'WOODEN UNION JACK BUNTING', 3, '2011-07-20', 4.96, NULL, 'United Kingdom'),
('555150', '22488', 'NATURAL SLATE RECTANGLE CHALKBOARD', 5, '2011-05-31', 3.29, NULL, 'United Kingdom'),
('570521', '21625', 'VINTAGE UNION JACK APRON', 3, '2011-10-11', 6.95, 12371, 'Switzerland'),
('547053', '22087', 'PAPER BUNTING WHITE LACE', 40, '2011-03-20', 2.55, 13001, 'United Kingdom'),
('573360', '22591', 'CARDHOLDER GINGHAM CHRISTMAS TREE', 6, '2011-10-30', 3.25, 15748, 'United Kingdom'),
('571039', '84536A', 'ENGLISH ROSE NOTEBOOK A7 SIZE', 1, '2011-10-13', 0.42, 16121, 'United Kingdom'),
('578936', '20723', 'STRAWBERRY CHARLOTTE BAG', 10, '2011-11-27', 0.85, 16923, 'United Kingdom'),
('559338', '21391', 'FRENCH LAVENDER SCENT HEART', 1, '2011-07-07', 1.63, NULL, 'United Kingdom'),
('568134', '23171', 'REGENCY TEA PLATE GREEN', 1, '2011-09-23', 3.29, NULL, 'United Kingdom'),
('552061', '21876', 'POTTERING MUG', 12, '2011-05-06', 1.25, 13001, 'United Kingdom'),
('543179', '22531', 'MAGIC DRAWING SLATE CIRCUS PARADE', 1, '2011-02-04', 0.42, 12754, 'Japan'),
('540954', '22381', 'TOY TIDY PINK POLKADOT', 4, '2011-01-12', 2.1, 14606, 'United Kingdom'),
('572703', '21818', 'GLITTER HEART DECORATION', 13, '2011-10-25', 0.39, 16110, 'United Kingdom'),
('578757', '23009', 'I LOVE LONDON BABY GIFT SET', 1, '2011-11-25', 16.95, 12748, 'United Kingdom'),
('542616', '22505', 'MEMO BOARD COTTAGE DESIGN', 4, '2011-01-30', 4.95, 16816, 'United Kingdom'),
('554694', '22921', 'HERB MARKER CHIVES', 1, '2011-05-25', 1.63, NULL, 'United Kingdom'),
('569545', '21906', 'PHARMACIE FIRST AID TIN', 1, '2011-10-04', 13.29, NULL, 'United Kingdom'),
('549562', '21169', 'YOU''RE CONFUSING ME METAL SIGN', 1, '2011-04-10', 1.69, 13232, 'United Kingdom'),
('580610', '21945', 'STRAWBERRIES DESIGN FLANNEL', 1, '2011-12-05', 1.63, NULL, 'United Kingdom'),
('558066', 'gift_0001_50', 'Dotcomgiftshop Gift Voucher £50.00', 1, '2011-06-24', 41.67, NULL, 'United Kingdom'),
('538349', '21985', 'PACK OF 12 HEARTS DESIGN TISSUES', 1, '2010-12-10', 0.85, NULL, 'United Kingdom'),
('537685', '22737', 'RIBBON REEL CHRISTMAS PRESENT', 15, '2010-12-08', 1.65, 18077, 'United Kingdom'),
('545906', '22614', 'PACK OF 12 SPACEBOY TISSUES', 24, '2011-03-08', 0.29, 15764, 'United Kingdom'),
('550997', '22629', 'SPACEBOY LUNCH BOX', 12, '2011-04-26', 1.95, 17735, 'United Kingdom'),
('558763', '22960', 'JAM MAKING SET WITH JARS', 3, '2011-07-03', 4.25, 12841, 'United Kingdom'),
('562688', '22918', 'HERB MARKER PARSLEY', 12, '2011-08-08', 0.65, 13869, 'United Kingdom'),
('541424', '84520B', 'PACK 20 ENGLISH ROSE PAPER NAPKINS', 9, '2011-01-17', 1.63, NULL, 'United Kingdom'),
('581405', '20996', 'JAZZ HEARTS ADDRESS BOOK', 1, '2011-12-08', 0.19, 13521, 'United Kingdom'),
('571053', '23256', 'CHILDRENS CUTLERY SPACEBOY', 4, '2011-10-13', 4.15, 12631, 'Finland'),
('563333', '23012', 'GLASS APOTHECARY BOTTLE PERFUME', 1, '2011-08-15', 3.95, 15996, 'United Kingdom'),
('568054', '47559B', 'TEA TIME OVEN GLOVE', 4, '2011-09-23', 1.25, 16978, 'United Kingdom'),
('574262', '22561', 'WOODEN SCHOOL COLOURING SET', 12, '2011-11-03', 1.65, 13721, 'United Kingdom'),
('569360', '23198', 'PANTRY MAGNETIC SHOPPING LIST', 6, '2011-10-03', 1.45, 14653, 'United Kingdom'),
('570210', '22980', 'PANTRY SCRUBBING BRUSH', 2, '2011-10-09', 1.65, 13259, 'United Kingdom'),
('576599', '22847', 'BREAD BIN DINER STYLE IVORY', 1, '2011-11-15', 16.95, 14544, 'United Kingdom'),
('579777', '22356', 'CHARLOTTE BAG PINK POLKADOT', 4, '2011-11-30', 1.63, NULL, 'United Kingdom'),
('566060', '21106', 'CREAM SLICE FLANNEL CHOCOLATE SPOT', 1, '2011-09-08', 5.79, NULL, 'United Kingdom'),
('550514', '22489', 'PACK OF 12 TRADITIONAL CRAYONS', 24, '2011-04-18', 0.42, 14631, 'United Kingdom'),
('569898', '23437', '50''S CHRISTMAS GIFT BAG LARGE', 2, '2011-10-06', 2.46, NULL, 'United Kingdom'),
('563566', '23548', 'WRAP MAGIC FOREST', 25, '2011-08-17', 0.42, 13655, 'United Kingdom'),
('559693', '21169', 'YOU''RE CONFUSING ME METAL SIGN', 1, '2011-07-11', 4.13, NULL, 'United Kingdom'),
('573386', '22112', 'CHOCOLATE HOT WATER BOTTLE', 24, '2011-10-30', 4.25, 17183, 'United Kingdom'),
('576920', '23312', 'VINTAGE CHRISTMAS GIFT SACK', 4, '2011-11-17', 4.15, 13871, 'United Kingdom'),
('564473', '22384', 'LUNCH BAG PINK POLKADOT', 10, '2011-08-25', 1.65, 16722, 'United Kingdom'),
('562264', '23321', 'SMALL WHITE HEART OF WICKER', 3, '2011-08-03', 3.29, NULL, 'United Kingdom'),
('542541', '79030D', 'TUMBLER, BAROQUE', 1, '2011-01-28', 12.46, NULL, 'United Kingdom'),
('579937', '22090', 'PAPER BUNTING RETROSPOT', 12, '2011-12-01', 2.95, 13509, 'United Kingdom'),
('574076', '22483', 'RED GINGHAM TEDDY BEAR', 1, '2011-11-02', 5.79, NULL, 'United Kingdom'),
('579187', '20665', 'RED RETROSPOT PURSE', 1, '2011-11-28', 5.79, NULL, 'United Kingdom'),
('542922', '22423', 'REGENCY CAKESTAND 3 TIER', 3, '2011-02-02', 12.75, 12682, 'France'),
('570677', '23008', 'DOLLY GIRL BABY GIFT SET', 2, '2011-10-11', 16.95, 12836, 'United Kingdom'),
('577182', '21930', 'JUMBO STORAGE BAG SKULLS', 10, '2011-11-18', 2.08, 16945, 'United Kingdom'),
('576686', '20992', 'JAZZ HEARTS PURSE NOTEBOOK', 1, '2011-11-16', 0.39, 16916, 'United Kingdom'),
('553844', '22569', 'FELTCRAFT CUSHION BUTTERFLY', 4, '2011-05-19', 3.75, 13450, 'United Kingdom'),
('580689', '23150', 'IVORY SWEETHEART SOAP DISH', 6, '2011-12-05', 2.49, 12994, 'United Kingdom'),
('545000', '85206A', 'CREAM FELT EASTER EGG BASKET', 6, '2011-02-25', 1.65, 15281, 'United Kingdom'),
('541975', '22382', 'LUNCH BAG SPACEBOY DESIGN', 40, '2011-01-24', 1.65, NULL, 'Hong Kong'),
('544942', '22551', 'PLASTERS IN TIN SPACEBOY', 12, '2011-02-25', 1.65, 15544, 'United Kingdom'),
('543177', '22667', 'RECIPE BOX RETROSPOT', 6, '2011-02-04', 2.95, 14466, 'United Kingdom'),
('574587', '23356', 'LOVE HOT WATER BOTTLE', 4, '2011-11-06', 5.95, 14936, 'Channel Islands'),
('543451', '22774', 'RED DRAWER KNOB ACRYLIC EDWARDIAN', 1, '2011-02-08', 2.46, NULL, 'United Kingdom'),
('578270', '22579', 'WOODEN TREE CHRISTMAS SCANDINAVIAN', 1, '2011-11-23', 1.63, 14096, 'United Kingdom'),
('551413', '84970L', 'SINGLE HEART ZINC T-LIGHT HOLDER', 12, '2011-04-28', 0.95, 16227, 'United Kingdom'),
('567666', '22900', 'SET 2 TEA TOWELS I LOVE LONDON', 6, '2011-09-21', 3.25, 12520, 'Germany'),
('571544', '22810', 'SET OF 6 T-LIGHTS SNOWMEN', 2, '2011-10-17', 2.95, 17757, 'United Kingdom'),
('558368', '23249', 'VINTAGE RED ENAMEL TRIM PLATE', 12, '2011-06-28', 1.65, 14329, 'United Kingdom'),
('546430', '22284', 'HEN HOUSE DECORATION', 2, '2011-03-13', 1.65, 15918, 'United Kingdom'),
('565233', '23000', 'TRAVEL CARD WALLET TRANSPORT', 1, '2011-09-02', 0.83, NULL, 'United Kingdom'),
('559984', '16012', 'FOOD/DRINK SPONGE STICKERS', 50, '2011-07-14', 0.21, 16657, 'United Kingdom'),
('576920', '23312', 'VINTAGE CHRISTMAS GIFT SACK', -4, '2011-11-17', 4.15, 13871, 'United Kingdom'),
('564473', '22384', 'LUNCH BAG PINK POLKADOT', 10, '2011-08-25', 1.65, 16722, 'United Kingdom'),
('562264', '23321', 'SMALL WHITE HEART OF WICKER', 3, '2011-08-03', 3.29, NULL, 'United Kingdom'),
('542541', '79030D', 'TUMBLER, BAROQUE', 1, '2011-01-28', 12.46, NULL, 'United Kingdom'),
('579937', '22090', 'PAPER BUNTING RETROSPOT', 12, '2011-12-01', 2.95, 13509, 'United Kingdom'),
('574076', '22483', 'RED GINGHAM TEDDY BEAR', 1, '2011-11-02', 5.79, NULL, 'United Kingdom'),
('579187', '20665', 'RED RETROSPOT PURSE', 1, '2011-11-28', 5.79, NULL, 'United Kingdom'),
('542922', '22423', 'REGENCY CAKESTAND 3 TIER', 3, '2011-02-02', 12.75, 12682, 'France'),
('570677', '23008', 'DOLLY GIRL BABY GIFT SET', 2, '2011-10-11', 16.95, 12836, 'United Kingdom'),
('577182', '21930', 'JUMBO STORAGE BAG SKULLS', 10, '2011-11-18', 2.08, 16945, 'United Kingdom'),
('576686', '20992', 'JAZZ HEARTS PURSE NOTEBOOK', 1, '2011-11-16', 0.39, 16916, 'United Kingdom'),
('553844', '22569', 'FELTCRAFT CUSHION BUTTERFLY', 4, '2011-05-19', 3.75, 13450, 'United Kingdom'),
('580689', '23150', 'IVORY SWEETHEART SOAP DISH', 6, '2011-12-05', 2.49, 12994, 'United Kingdom'),
('545000', '85206A', 'CREAM FELT EASTER EGG BASKET', 6, '2011-02-25', 1.65, 15281, 'United Kingdom'),
('541975', '22382', 'LUNCH BAG SPACEBOY DESIGN', 40, '2011-01-24', 1.65, NULL, 'Hong Kong'),
('544942', '22551', 'PLASTERS IN TIN SPACEBOY', 12, '2011-02-25', 1.65, 15544, 'United Kingdom'),
('543177', '22667', 'RECIPE BOX RETROSPOT', 6, '2011-02-04', 2.95, 14466, 'United Kingdom'),
('574587', '23356', 'LOVE HOT WATER BOTTLE', 4, '2011-11-06', 5.95, 14936, 'Channel Islands'),
('543451', '22774', 'RED DRAWER KNOB ACRYLIC EDWARDIAN', 1, '2011-02-08', 2.46, NULL, 'United Kingdom'),
('578270', '22579', 'WOODEN TREE CHRISTMAS SCANDINAVIAN', 1, '2011-11-23', 1.63, 14096, 'United Kingdom'),
('551413', '84970L', 'SINGLE HEART ZINC T-LIGHT HOLDER', 12, '2011-04-28', 0.95, 16227, 'United Kingdom'),
('567666', '22900', 'SET 2 TEA TOWELS I LOVE LONDON', 6, '2011-09-21', 3.25, 12520, 'Germany'),
('571544', '22810', 'SET OF 6 T-LIGHTS SNOWMEN', 2, '2011-10-17', 2.95, 17757, 'United Kingdom'),
('558368', '23249', 'VINTAGE RED ENAMEL TRIM PLATE', 12, '2011-06-28', 1.65, 14329, 'United Kingdom'),
('546430', '22284', 'HEN HOUSE DECORATION', 2, '2011-03-13', 1.65, 15918, 'United Kingdom'),
('565233', '23000', 'TRAVEL CARD WALLET TRANSPORT', 1, '2011-09-02', 0.83, NULL, 'United Kingdom'),
('559984', '16012', 'FOOD/DRINK SPONGE STICKERS', 50, '2011-07-14', 0.21, 16657, 'United Kingdom');

/*
Find the best selling item for each month (no need to separate months by year) 
where the biggest total invoice was paid. 

The best selling item is calculated using the formula (unitprice * quantity). 
Output the month, the description of the item along with the amount paid.
*/
-- month invoice data
-- group by product desc
-- revenue price * qty
-- rank 
-- subquery 
WITH 
	best_sell_prod AS (
		SELECT 	description, SUM(quantity * unitprice) AS total_sale,
				EXTRACT(MONTH FROM invoicedate) AS month,
				RANK() OVER(PARTITION BY EXTRACT(MONTH FROM invoicedate) 
							ORDER BY SUM(quantity * unitprice) DESC) AS rnk
		FROM walmart_eu
		GROUP BY description, month
	)
SELECT month, description, total_sale
FROM best_sell_prod
WHERE rnk = 1;

SELECT month, description, total_sale
FROM(
     SELECT 
        EXTRACT(MONTH FROM invoicedate) as month,
        description,
        SUM(unitprice * quantity) as total_sale,
        RANK() OVER( PARTITION BY EXTRACT(MONTH FROM invoicedate) 
                    ORDER BY SUM(unitprice * quantity) DESC) as rn
    FROM walmart_eu
    GROUP BY month, description
) as subquery
WHERE rn= 1;

-- Your Task
-- Find Customer of the month from each MONTH one customer who has spent the highest amount (price * quantity) as total amount may include multiple purchase



/*
	************************************************
			day 28/50 days SQL Challenge
    ************************************************
*/

/*
Question:
	Write a query to find the highest-selling product for each customer
	Return cx id, product description, and total count of purchase.
*/ 
-- cx all product they purchased and their total orders
-- order by by number of purchase desc
-- 1 product that has highest purchase 
-- rank 

-- SELECT customerid, description, total_orders
SELECT *
FROM (
	SELECT customerid, description, COUNT(*) AS total_order,
    RANK() OVER(PARTITION BY customerid ORDER BY COUNT(*) DESC) AS rnk
	FROM walmart_eu
	GROUP BY customerid, description
    ORDER BY customerid, total_order DESC
    ) AS subquery
WHERE rnk = 1;

SELECT *
FROM
(
    SELECT 
         customerid,
        description,
        COUNT(*) as total_purchase,
        RANK() OVER(PARTITION BY customerid 
        ORDER BY  COUNT(*) DESC) as rn
    FROM walmart_eu
    GROUP BY customerid, description
    ORDER BY customerid, total_purchase DESC  
)as subquery
WHERE rn = 1;

/*
-- Your Task
Find each country and best selling product 
Return country_name, description, total count of sale
*/

/*
	*****************************************************
				29/50 days SQL challenge
    *****************************************************
*/
CREATE TABLE bookings(
	id INT,
    hotel_name VARCHAR(15),
    booking_date date,
    cust_id INT,
    adult INT,
    payment_type VARCHAR(10)
);
INSERT INTO bookings (id, hotel_name, booking_date, cust_id, adult, payment_type) VALUES
(1, 'Hotel A', '2022-05-06', 1001, 2, 'Credit'),
(2, 'Hotel B', '2022-05-06', 1002, 1, 'Cash'),
(3, 'Hotel C', '2022-05-07', 1003, 3, 'Credit'),
(4, 'Hotel D', '2022-05-07', 1004, 2, 'Cash'),
(5, 'Hotel E', '2022-05-05', 1005, 1, 'Credit'),
(6, 'Hotel A', '2022-05-07', 1006, 2, 'Cash'),
(7, 'Hotel B', '2022-05-06', 1007, 3, 'Credit'),
(8, 'Hotel C', '2022-05-08', 1008, 1, 'Cash'),
(9, 'Hotel D', '2022-05-09', 1009, 2, 'Credit'),
(10, 'Hotel E', '2022-05-10', 1010, 3, 'Cash'),
(11, 'Hotel A', '2022-05-14', 1011, 1, 'Credit'),
(12, 'Hotel B', '2022-05-21', 1012, 2, 'Cash'),
(13, 'Hotel C', '2022-05-13', 1013, 3, 'Credit'),
(14, 'Hotel D', '2022-05-14', 1014, 1, 'Cash'),
(15, 'Hotel E', '2022-05-15', 1015, 2, 'Credit'),
(16, 'Hotel A', '2022-05-21', 1016, 3, 'Cash'),
(17, 'Hotel B', '2022-05-17', 1017, 1, 'Credit'),
(18, 'Hotel C', '2022-05-18', 1018, 2, 'Cash'),
(19, 'Hotel D', '2022-05-19', 1019, 3, 'Credit'),
(20, 'Hotel E', '2022-05-20', 1020, 1, 'Cash'),
(21, 'Hotel A', '2022-05-28', 1021, 2, 'Credit'),
(22, 'Hotel B', '2022-05-22', 1022, 3, 'Cash'),
(23, 'Hotel C', '2022-05-23', 1023, 1, 'Credit'),
(24, 'Hotel D', '2022-05-24', 1024, 2, 'Cash'),
(25, 'Hotel E', '2022-05-25', 1025, 3, 'Credit'),
(26, 'Hotel A', '2022-06-04', 1026, 1, 'Cash'),
(27, 'Hotel B', '2022-06-04', 1027, 2, 'Credit'),
(28, 'Hotel C', '2022-05-28', 1028, 3, 'Cash'),
(29, 'Hotel D', '2022-05-29', 1029, 1, 'Credit'),
(30, 'Hotel E', '2022-06-25', 1030, 2, 'Cash'),
(31, 'Hotel A', '2022-06-18', 1031, 3, 'Credit'),
(32, 'Hotel B', '2022-06-02', 1032, 1, 'Cash'),
(33, 'Hotel C', '2022-06-03', 1033, 2, 'Credit'),
(34, 'Hotel D', '2022-06-04', 1034, 3, 'Cash'),
(35, 'Hotel E', '2022-06-05', 1035, 1, 'Credit'),
(36, 'Hotel A', '2022-07-09', 1036, 2, 'Cash'),
(37, 'Hotel B', '2022-06-06', 1037, 3, 'Credit'),
(38, 'Hotel C', '2022-06-08', 1038, 1, 'Cash'),
(39, 'Hotel D', '2022-06-09', 1039, 2, 'Credit'),
(40, 'Hotel E', '2022-06-10', 1040, 3, 'Cash'),
(41, 'Hotel A', '2022-07-23', 1041, 1, 'Credit'),
(42, 'Hotel B', '2022-06-12', 1042, 2, 'Cash'),
(43, 'Hotel C', '2022-06-13', 1043, 3, 'Credit'),
(44, 'Hotel D', '2022-06-14', 1044, 1, 'Cash'),
(45, 'Hotel E', '2022-06-15', 1045, 2, 'Credit'),
(46, 'Hotel A', '2022-06-24', 1046, 3, 'Cash'),
(47, 'Hotel B', '2022-06-24', 1047, 1, 'Credit'),
(48, 'Hotel C', '2022-06-18', 1048, 2, 'Cash'),
(49, 'Hotel D', '2022-06-19', 1049, 3, 'Credit'),
(50, 'Hotel E', '2022-06-20', 1050, 1, 'Cash');

/*
Question :
	Find the hotel name and their total numbers of weekends bookings sort the data higher number first!
*/
-- hotel_name,
-- total no of bookings which basically for weekends
-- Group by by hotel_name
-- order by total booking

SELECT hotel_name, booking_date,

SELECT 
    hotel_name,
    SUM(CASE 
            WHEN EXTRACT(DOW FROM booking_date) IN (6, 7)
            THEN 1
            ELSE 0
        END) as total_w_bookings
    
FROM bookings 
GROUP BY hotel_name
ORDER BY total_w_bookings DESC

SELECT EXTRACT(DOW FROM current_date);

-- Your Task
-- Find out hotel_name and their total number of booking by credit card and cash


/*
	************************************************************
				Day 30/50 days SQL challenge
    ************************************************************
*/
DROP TABLE IF EXISTS orders30;
CREATE TABLE orders30 (
    order_id INT PRIMARY KEY,
    order_date DATE,
    quantity INT
);

INSERT INTO orders30 (order_id, order_date, quantity) 
VALUES
(1, '2023-01-02', 5),
(2, '2023-02-05', 3),
(3, '2023-02-07', 2),
(4, '2023-03-10', 6),
(5, '2023-02-15', 4),
(6, '2023-04-21', 8),
(7, '2023-05-28', 7),
(8, '2023-05-05', 3),
(9, '2023-08-10', 5),
(10, '2023-05-02', 6),
(11, '2023-02-07', 4),
(12, '2023-04-15', 9),
(13, '2023-03-22', 7),
(14, '2023-04-30', 8),
(15, '2023-04-05', 6),
(16, '2023-02-02', 6),
(17, '2023-01-07', 4),
(18, '2023-05-15', 9),
(19, '2023-05-22', 7),
(20, '2023-06-30', 8),
(21, '2023-07-05', 6);


/*
Question :
	You have amazon orders data For each week, find the total number of orders. 
	Include only the orders that are from the first quarter of 2023.
	The output should contain 'week' and 'quantity'.
*/
-- week no from order date
-- SUM(qty)
-- where order 1st quarter 2023
-- group by week

SELECT 
    EXTRACT(WEEK FROM order_date) as week,
    SUM(quantity) as total_qty_sold
FROM orders30
WHERE EXTRACT(QUARTER FROM order_date) = 1
GROUP BY week;

-- Your Task
-- Find each quarter and their total qty sale
SELECT 
    EXTRACT(QUARTER FROM order_date) AS qtr,
    SUM(quantity) as total_qty_sold
FROM orders30
GROUP BY qtr;

/*
	*****************************************************
					day 31/50 SQL challenge
	*****************************************************
*/
CREATE TABLE sales_data (
    seller_id VARCHAR(10),
    total_sales NUMERIC,
    product_category VARCHAR(20),
    market_place VARCHAR(10),
    month DATE
);
INSERT INTO sales_data (seller_id, total_sales, product_category, market_place, month)
VALUES
('s236', 36486.73, 'electronics', 'in', DATE '2024-01-01'),
('s918', 24286.4, 'books', 'uk', DATE '2024-01-01'),
('s163', 18846.34, 'electronics', 'us', DATE '2024-01-01'),
('s836', 35687.65, 'electronics', 'uk', DATE '2024-01-01'),
('s790', 31050.13, 'clothing', 'in', DATE '2024-01-01'),
('s195', 14299, 'books', 'de', DATE '2024-01-01'),
('s483', 49361.62, 'clothing', 'uk', DATE '2024-01-01'),
('s891', 48847.68, 'electronics', 'de', DATE '2024-01-01'),
('s272', 11324.61, 'toys', 'us', DATE '2024-01-01'),
('s712', 43739.86, 'toys', 'in', DATE '2024-01-01'),
('s968', 36042.66, 'electronics', 'jp', DATE '2024-01-01'),
('s728', 29158.51, 'books', 'us', DATE '2024-01-01'),
('s415', 24593.5, 'electronics', 'uk', DATE '2024-01-01'),
('s454', 35520.67, 'toys', 'in', DATE '2024-01-01'),
('s560', 27320.16, 'electronics', 'jp', DATE '2024-01-01'),
('s486', 37009.18, 'electronics', 'us', DATE '2024-01-01'),
('s749', 36277.83, 'toys', 'de', DATE '2024-01-01'),
('s798', 31162.45, 'electronics', 'in', DATE '2024-01-01'),
('s515', 26372.16, 'toys', 'in', DATE '2024-01-01'),
('s662', 22157.87, 'books', 'in', DATE '2024-01-01'),
('s919', 24963.97, 'toys', 'de', DATE '2024-01-01'),
('s863', 46652.67, 'electronics', 'us', DATE '2024-01-01'),
('s375', 18107.08, 'clothing', 'de', DATE '2024-01-01'),
('s583', 20268.34, 'toys', 'jp', DATE '2024-01-01'),
('s778', 19962.89, 'electronics', 'in', DATE '2024-01-01'),
('s694', 36519.05, 'electronics', 'in', DATE '2024-01-01'),
('s214', 18948.55, 'electronics', 'de', DATE '2024-01-01'),
('s830', 39169.01, 'toys', 'us', DATE '2024-01-01'),
('s383', 12310.73, 'books', 'in', DATE '2024-01-01'),
('s195', 45633.35, 'books', 'de', DATE '2024-01-01'),
('s196', 13643.27, 'books', 'jp', DATE '2024-01-01'),
('s796', 19637.44, 'electronics', 'jp', DATE '2024-01-01'),
('s334', 11999.1, 'clothing', 'de', DATE '2024-01-01'),
('s217', 23481.03, 'books', 'in', DATE '2024-01-01'),
('s123', 36277.83, 'toys', 'uk', DATE '2024-01-01'),
('s383', 17337.392, 'electronics', 'de', DATE '2024-02-01'),
('s515', 13998.997, 'electronics', 'jp', DATE '2024-02-01'),
('s583', 36035.539, 'books', 'jp', DATE '2024-02-01'),
('s195', 18493.564, 'toys', 'de', DATE '2024-02-01'),
('s728', 34466.126, 'electronics', 'de', DATE '2024-02-01'),
('s830', 48950.221, 'electronics', 'us', DATE '2024-02-01'),
('s483', 16820.965, 'electronics', 'uk', DATE '2024-02-01'),
('s778', 48625.281, 'toys', 'in', DATE '2024-02-01'),
('s918', 37369.321, 'clothing', 'de', DATE '2024-02-01'),
('s123', 46372.816, 'electronics', 'uk', DATE '2024-02-01'),
('s195', 18317.667, 'electronics', 'in', DATE '2024-02-01'),
('s798', 41005.313, 'books', 'in', DATE '2024-02-01'),
('s454', 39090.88, 'electronics', 'de', DATE '2024-02-01'),
('s454', 17839.314, 'toys', 'us', DATE '2024-02-01'),
('s798', 31587.685, 'toys', 'in', DATE '2024-02-01'),
('s778', 21237.38, 'books', 'jp', DATE '2024-02-01'),
('s236', 10625.456, 'toys', 'jp', DATE '2024-02-01'),
('s236', 17948.627, 'toys', 'jp', DATE '2024-02-01'),
('s749', 38453.678, 'toys', 'de', DATE '2024-02-01'),
('s790', 47052.035, 'toys', 'uk', DATE '2024-02-01'),
('s272', 34931.925, 'books', 'de', DATE '2024-02-01'),
('s375', 36753.65, 'toys', 'us', DATE '2024-02-01'),
('s214', 32449.737, 'toys', 'in', DATE '2024-02-01'),
('s163', 40431.402, 'electronics', 'in', DATE '2024-02-01'),
('s214', 30909.313, 'electronics', 'in', DATE '2024-02-01'),
('s415', 18068.768, 'electronics', 'jp', DATE '2024-02-01'),
('s836', 46302.659, 'clothing', 'jp', DATE '2024-02-01'),
('s383', 19151.927, 'electronics', 'uk', DATE '2024-02-01'),
('s863', 45218.714, 'books', 'us', DATE '2024-02-01'),
('s830', 18737.617, 'books', 'de', DATE '2024-02-01'),
('s968', 22973.801, 'toys', 'in', DATE '2024-02-01'),
('s334', 20885.29, 'electronics', 'uk', DATE '2024-02-01'),
('s163', 10278.085, 'electronics', 'de', DATE '2024-02-01'),
('s272', 29393.199, 'clothing', 'jp', DATE '2024-02-01'),
('s560', 16731.642, 'electronics', 'jp', DATE '2024-02-01'),
('s583', 38120.758, 'books', 'uk', DATE '2024-03-01'),
('s163', 22035.132, 'toys', 'uk', DATE '2024-03-01'),
('s918', 26441.481, 'clothing', 'jp', DATE '2024-03-01'),
('s334', 35374.054, 'books', 'in', DATE '2024-03-01'),
('s796', 32115.724, 'electronics', 'jp', DATE '2024-03-01'),
('s749', 39128.654, 'toys', 'in', DATE '2024-03-01'),
('s217', 35341.188, 'electronics', 'us', DATE '2024-03-01'),
('s334', 16028.702, 'books', 'us', DATE '2024-03-01'),
('s383', 44334.352, 'toys', 'in', DATE '2024-03-01'),
('s163', 42380.042, 'books', 'jp', DATE '2024-03-01'),
('s483', 16974.657, 'clothing', 'in', DATE '2024-03-01'),
('s236', 37027.605, 'electronics', 'de', DATE '2024-03-01'),
('s196', 45093.574, 'toys', 'uk', DATE '2024-03-01'),
('s486', 42688.888, 'books', 'in', DATE '2024-03-01'),
('s728', 32331.738, 'electronics', 'us', DATE '2024-03-01'),
('s123', 38014.313, 'electronics', 'us', DATE '2024-03-01'),
('s662', 45483.457, 'clothing', 'jp', DATE '2024-03-01'),
('s968', 47425.4, 'books', 'uk', DATE '2024-03-01'),
('s778', 36540.071, 'books', 'in', DATE '2024-03-01'),
('s798', 29424.55, 'toys', 'us', DATE '2024-03-01'),
('s334', 10723.015, 'toys', 'de', DATE '2024-03-01'),
('s662', 24658.751, 'electronics', 'uk', DATE '2024-03-01'),
('s163', 36304.516, 'clothing', 'us', DATE '2024-03-01'),
('s863', 20608.095, 'books', 'de', DATE '2024-03-01'),
('s214', 27375.775, 'toys', 'de', DATE '2024-03-01'),
('s334', 33076.155, 'clothing', 'in', DATE '2024-03-01'),
('s515', 32880.168, 'toys', 'us', DATE '2024-03-01'),
('s195', 48157.143, 'books', 'uk', DATE '2024-03-01'),
('s583', 23230.012, 'books', 'uk', DATE '2024-03-01'),
('s334', 13013.85, 'toys', 'jp', DATE '2024-03-01'),
('s375', 20738.994, 'electronics', 'in', DATE '2024-03-01'),
('s778', 25787.659, 'electronics', 'jp', DATE '2024-03-01'),
('s796', 36845.741, 'clothing', 'uk', DATE '2024-03-01'),
('s214', 21811.624, 'electronics', 'de', DATE '2024-03-01'),
('s334', 15464.853, 'books', 'in', DATE '2024-03-01');

/*
Amazon Data Analyst Interview :
-- Top Monthly Sellers

	You are provided with a transactional dataset from Amazon that contains detailed information about 
	sales across different products and marketplaces.  
    
    Your task is to list the top 3 sellers in each product category for January.
    The output should contain 'seller_id' , 'total_sales' ,'product_category' , 'market_place', and 'month'.
*/

SELECT
    product_category, seller_id, sales
FROM ( 
	SELECT  product_category, seller_id, SUM(total_sales) as sales,
			DENSE_RANK() OVER(PARTITION BY product_category ORDER BY SUM(total_sales) DESC) dr
    FROM sales_data
    WHERE EXTRACT(MONTH FROM month) = 1
    GROUP BY product_category, seller_id
    ) as subquery
WHERE dr <= 3;

-- ORDER BY product_category,  sales DESC

-- Your Task
-- Find out Each market place and their top 3 seller based on total sale


/*
	*****************************************************
			Day 32/50 days SQL challenge
    *****************************************************
*/
CREATE TABLE user_flags (
    user_firstname VARCHAR(50),
    user_lastname VARCHAR(50),
    video_id VARCHAR(20),
    flag_id VARCHAR(20)
);
INSERT INTO user_flags (user_firstname, user_lastname, video_id, flag_id) VALUES
('Richard', 'Hasson', 'y6120QOlsfU', '0cazx3'),
('Mark', 'May', 'Ct6BUPvE2sM', '1cn76u'),
('Gina', 'Korman', 'dQw4w9WgXcQ', '1i43zk'),
('Mark', 'May', 'Ct6BUPvE2sM', '1n0vef'),
('Mark', 'May', 'jNQXAC9IVRw', '1sv6ib'),
('Gina', 'Korman', 'dQw4w9WgXcQ', '20xekb'),
('Mark', 'May', '5qap5aO4i9A', '4cvwuv'),
('Daniel', 'Bell', '5qap5aO4i9A', '4sd6dv'),
('Richard', 'Hasson', 'y6120QOlsfU', '6jjkvn'),
('Pauline', 'Wilks', 'jNQXAC9IVRw', '7ks264'),
('Courtney', '', 'dQw4w9WgXcQ', NULL),
('Helen', 'Hearn', 'dQw4w9WgXcQ', '8946nx'),
('Mark', 'Johnson', 'y6120QOlsfU', '8wwg0l'),
('Richard', 'Hasson', 'dQw4w9WgXcQ', 'arydfd'),
('Gina', 'Korman', '', NULL),
('Mark', 'Johnson', 'y6120QOlsfU', 'bl40qw'),
('Richard', 'Hasson', 'dQw4w9WgXcQ', 'ehn1pt'),
('Lopez', '', 'dQw4w9WgXcQ', 'hucyzx'),
('Greg', '', '5qap5aO4i9A', NULL),
('Pauline', 'Wilks', 'jNQXAC9IVRw', 'i2l3oo'),
('Richard', 'Hasson', 'jNQXAC9IVRw', 'i6336w'),
('Johnson', 'y6120QOlsfU', '', 'iey5vi'),
('William', 'Kwan', 'y6120QOlsfU', 'kktiwe'),
('', 'Ct6BUPvE2sM', '', NULL),
('Loretta', 'Crutcher', 'y6120QOlsfU', 'nkjgku'),
('Pauline', 'Wilks', 'jNQXAC9IVRw', 'ov5gd8'),
('Mary', 'Thompson', 'Ct6BUPvE2sM', 'qa16ua'),
('Daniel', 'Bell', '5qap5aO4i9A', 'xciyse'),
('Evelyn', 'Johnson', 'dQw4w9WgXcQ', 'xvhk6d');

/*
Netflix Data Analyst Interview Question :
	For each video, find how many unique users flagged it. A unique user can be identified using the
	combination of their first name and last name. 

	Do not consider rows in which there is no flag ID.
*/
-- select video_id
-- COUNT(unique users)
-- DISTINTC first and last name
-- filter the data for not null flagid
-- GROUP BY 

SELECT 
    video_id,
    COUNT(DISTINCT(CONCAT(user_firstname, user_lastname))) AS cnt_users
FROM user_flags
WHERE flag_id IS NOT NULL
GROUP BY video_id
ORDER BY 2 DESC;

/*
	***************************************************
			Day 33/50 SQL challenge
    ***************************************************
*/
CREATE TABLE fb_active_users (
    user_id INT,
    name VARCHAR(50),
    status VARCHAR(10),
    country VARCHAR(50)
);
INSERT INTO fb_active_users (user_id, name, status, country) VALUES
(33, 'Amanda Leon', 'open', 'Australia'),
(27, 'Jessica Farrell', 'open', 'Luxembourg'),
(18, 'Wanda Ramirez', 'open', 'USA'),
(50, 'Samuel Miller', 'closed', 'Brazil'),
(16, 'Jacob York', 'open', 'Australia'),
(25, 'Natasha Bradford', 'closed', 'USA'),
(34, 'Donald Ross', 'closed', 'China'),
(52, 'Michelle Jimenez', 'open', 'USA'),
(11, 'Theresa John', 'open', 'China'),
(37, 'Michael Turner', 'closed', 'Australia'),
(32, 'Catherine Hurst', 'closed', 'Mali'),
(61, 'Tina Turner', 'open', 'Luxembourg'),
(4, 'Ashley Sparks', 'open', 'China'),
(82, 'Jacob York', 'closed', 'USA'),
(87, 'David Taylor', 'closed', 'USA'),
(78, 'Zachary Anderson', 'open', 'China'),
(5, 'Tiger Leon', 'closed', 'China'),
(56, 'Theresa Weaver', 'closed', 'Brazil'),
(21, 'Tonya Johnson', 'closed', 'Mali'),
(89, 'Kyle Curry', 'closed', 'Mali'),
(7, 'Donald Jim', 'open', 'USA'),
(22, 'Michael Bone', 'open', 'Canada'),
(31, 'Sara Michaels', 'open', 'Denmark');


/*
Meta Data Analyst Question :  
	You have meta table with columns user_id, name, status, country
    
    Output share of US users that are active. Active users are the ones with an "open" status in the table.
	Return total users and active users and active users share for US
*/
-- COUNT FILTER FOR US
-- COUNT ACTIVE users in US
-- active users/total users * 100
-- user_id, name, status, country
SELECT total_users,  active_users, (100 * active_users/total_users) AS act_user_share_USA
FROM (
		SELECT (SELECT COUNT(*) FROM fb_active_users) AS total_users,
				COUNT(status) AS active_users
        FROM fb_active_users
        WHERE country LIKE "%USA%" AND status LIKE "%open%"
	) AS subquery;

-- Your Task
-- Find non_active users share for China

/*
	***********************************************************
				Day 34/50 SQL Challenge
    ***********************************************************
*/
CREATE TABLE bank_transactions (
    transaction_id SERIAL PRIMARY KEY,
    bank_id INT,
    customer_id INT,
    transaction_amount DECIMAL(10, 2),
    transaction_type VARCHAR(10),
    transaction_date DATE
);
INSERT INTO bank_transactions (bank_id, customer_id, transaction_amount, transaction_type, transaction_date) VALUES
(1, 101, 500.00, 'credit', '2024-01-01'),
(1, 101, 200.00, 'debit', '2024-01-02'),
(1, 101, 300.00, 'credit', '2024-01-05'),
(1, 101, 150.00, 'debit', '2024-01-08'),
(1, 102, 1000.00, 'credit', '2024-01-01'),
(1, 102, 400.00, 'debit', '2024-01-03'),
(1, 102, 600.00, 'credit', '2024-01-05'),
(1, 102, 200.00, 'debit', '2024-01-09');

/*
You are given a bank transaction data with columns bank_id, customer_id, amount_type(credit debit), 
transaction_amount and transaction_date
	Write a query to find starting and ending trans amount for each customer. Return cx_id, their first_transaction_amt, 
	last_transaction and these transaction_date

*/
-- first trans details 
-- last trans details 
-- than join these 2 trans
WITH 
	rank_transaction AS (
		SELECT *, RANK() OVER (PARTITION BY customer_id ORDER BY transaction_date ASC) AS rnk
        FROM bank_transactions
	),
    first_transaction AS (
		SELECT customer_id, transaction_amount, transaction_date
        FROM rank_transaction
        WHERE rnk = (SELECT MIN(rnk) FROM rank_transaction)
	),
    last_transaction AS (
		SELECT customer_id, transaction_amount, transaction_date
        FROM rank_transaction
        WHERE rnk = (SELECT MAX(rnk) FROM rank_transaction)
	)
    SELECT customer_id, transaction_amount, transaction_date
    FROM first_transaction
    UNION 
	SELECT customer_id, transaction_amount, transaction_date
	FROM last_transaction
    ORDER BY customer_id;
    
WITH CTE1 AS
(
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY customer_id 
        ORDER BY transaction_date) as rn    
    FROM bank_transactions
),
CTE2 -- first_trans_details
AS    
(
    SELECT 
        customer_id,
        transaction_amount,
        transaction_date
    FROM CTE1
    WHERE rn = (SELECT MIN(rn) FROM CTE1)
),
CTE3 -- -- last_trans_details
AS    
(
    SELECT 
        customer_id,
        transaction_amount,
        transaction_date
    FROM CTE1
    WHERE rn = (SELECT MAX(rn) FROM CTE1)
)

SELECT 
    CTE2.customer_id,
    CTE2.transaction_amount as first_trans_amt,
    CTE2.transaction_date as first_trans_date,
    CTE3.transaction_amount as last_trans_amt,
    CTE3.transaction_date as last_trans_date
FROM CTE2
JOIN
CTE3 
ON CTE2.customer_id = CTE3.customer_id;

-- Your task 
-- Write a query to return each cx_id and their bank balance
-- Note bank balance = Total Credit - Total_debit


/*
	*************************************************************
			Day 35/50 SQL Challenge
    *************************************************************
*/
DROP TABLE IF EXISTS Students;
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    marks INT,
    class VARCHAR(10)
);
INSERT INTO Students (student_id, student_name, marks, class) VALUES
(1, 'John Doe', 85, 'A'),
(2, 'Jane Smith', 92, 'B'),
(3, 'Michael Johnson', 78, 'A'),
(4, 'Emily Brown', 59, 'C'),
(5, 'David Lee', 88, 'B'),
(6, 'Sarah Wilson', 59, 'A'),
(7, 'Daniel Taylor', 90, 'C'),
(8, 'Emma Martinez', 79, 'B'),
(9, 'Christopher Anderson', 87, 'A'),
(10, 'Olivia Garcia', 91, 'C'),
(11, 'James Rodriguez', 83, 'B'),
(12, 'Sophia Hernandez', 94, 'A'),
(13, 'Matthew Martinez', 76, 'C'),
(14, 'Isabella Lopez', 89, 'B'),
(15, 'Ethan Gonzalez', 80, 'A'),
(16, 'Amelia Perez', 93, 'C'),
(17, 'Alexander Torres', 77, 'B'),
(18, 'Mia Flores', 86, 'A'),
(19, 'William Sanchez', 84, 'C'),
(20, 'Ava Ramirez', 97, 'B'),
(21, 'Daniel Taylor', 75, 'A'),
(22, 'Chloe Cruz', 98, 'C'),
(23, 'Benjamin Ortiz', 89, 'B'),
(24, 'Harper Reyes', 99, 'A'),
(25, 'Ryan Stewart', 99, 'C');

/*
Data Analyst Interview Questions:
	Write a query to fetch students with minmum marks and maximum marks 
*/
-- Approach 1
-- minimum marks
-- maximum marks
SELECT * 
FROM students
WHERE 	marks = (SELECT MIN(marks) FROM students)
				OR 
		marks = (SELECT MAX(marks) FROM students);

-- Approach 2
WITH CTE
AS
(
SELECT 
    MIN(marks) as min_marks,
    MAX(marks) as max_marks
FROM students
)
SELECT
    s.*
FROM students as s
JOIN 
CTE ON s.marks = CTE.min_marks
OR
s.marks = CTE.max_marks;

-- Your Task
-- Write a SQL query to return students with maximum marks in each class

/*
	*******************************************************************
				SQL Challenge Day 36
    *******************************************************************
*/

DROP TABLE IF EXISTS Employees36;
CREATE TABLE Employees36 (
  Emp_No DECIMAL(4,0) NOT NULL,
  Emp_Name VARCHAR(10),
  Job_Name VARCHAR(9),
  Manager_Id DECIMAL(4,0),
  HireDate DATE,
  Salary DECIMAL(7,2),
  Commission DECIMAL(7,2),  
  DeptNo DECIMAL(2,0) NOT NULL
);

INSERT INTO Employees36 (Emp_No, Emp_Name, Job_Name, Manager_Id, HireDate, Salary, Commission, DeptNo) VALUES
(7839, 'KING', 'PRESIDENT', NULL, '1981-11-17', 5000, NULL, 10),
(7698, 'BLAKE', 'MANAGER', 7839, '1981-05-01', 2850, NULL, 30),
(7782, 'CLARK', 'MANAGER', 7839, '1981-06-09', 2450, NULL, 10),
(7566, 'JONES', 'MANAGER', NULL, '1981-04-02', 2975, NULL, 20),
(7788, 'SCOTT', 'ANALYST', 7566, '1987-07-29', 3000, NULL, 20),
(7902, 'FORD', 'ANALYST', 7566, '1981-12-03', 3000, NULL, 20),
(7369, 'SMITH', 'CLERK', 7902, '1980-12-17', 800, NULL, 20),
(7499, 'ALLEN', 'SALESMAN', NULL, '1981-02-20', 1600, 300, 30),
(7521, 'WARD', 'SALESMAN', 7698, '1981-02-22', 1250, 500, 30),
(7654, 'MARTIN', 'SALESMAN', 7698, '1981-09-28', 1250, 1400, 30),
(7844, 'TURNER', 'SALESMAN', 7698, '1981-09-08', 1500, 0, 30),
(7876, 'ADAMS', 'CLERK', NULL, '1987-06-02', 1100, NULL, 20),
(7900, 'JAMES', 'CLERK', 7698, '1981-12-03', 950, NULL, 30),
(7934, 'MILLER', 'CLERK', 7782, '1982-01-23', 1300, NULL, 10);

/*
Question :
	Write an SQL script to display the immediate manager of an employee.
	The script should return the employee's name along with their immediate manager's name.
	If an employee has no manager (i.e., Manager_Id is NULL), display "No Boss" for that employee.
*/
SELECT 	e1.Emp_Name, COALESCE(e2.emp_name, 'No Boss') AS Manager_Name
FROM employees36 AS e1
LEFT JOIN 
employees36 AS e2
ON e2.Emp_No = e1.Manager_Id;

/*
	******************************************************
				37/50 SQL challenge
    ******************************************************
*/

CREATE TABLE customers37 (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE spending_records (
    record_id INT PRIMARY KEY,
    customer_id INT,
    spending_amount DECIMAL(10, 2),
    spending_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers37(customer_id)
);

INSERT INTO customers37 (customer_id, customer_name) VALUES
(1, 'John'),
(2, 'Alice'),
(3, 'Bob'),
(4, 'Charlie');

INSERT INTO spending_records (record_id, customer_id, spending_amount, spending_date) VALUES
(9, 1, 120.00, '2024-03-25'),
(10, 2, 80.00, '2024-03-25'),
(11, 3, 150.00, '2024-03-25'),
(12, 4, 70.00, '2024-03-25'),
(13, 1, 90.00, '2024-03-02'),
(14, 2, 100.00, '2024-04-02'),
(15, 3, 160.00, '2024-04-02'),
(16, 4, 30.00, '2024-03-02'),
(17, 1, 110.00, '2024-04-09'),
(18, 2, 70.00, '2024-02-09'),
(19, 3, 140.00, '2024-03-09'),
(20, 4, 60.00, '2024-04-09'),
(21, 1, 100.00, '2024-03-16'),
(22, 2, 60.00, '2024-03-16'),
(23, 3, 130.00, '2024-03-16'),
(24, 4, 50.00, '2024-04-16'),
(25, 1, 80.00, '2024-03-23'),
(26, 2, 50.00, '2024-04-23'),
(27, 3, 120.00, '2024-04-23'),
(28, 4, 40.00, '2024-04-23'),
(29, 1, 70.00, '2024-04-30'),
(30, 2, 40.00, '2024-04-30'),
(31, 3, 110.00, '2024-03-01'),
(32, 4, 30.00, '2024-03-01');

/*
Amazon Data Analyst Interview Question :
	Write a SQL query to show all customers and their total spending show only those 
    customers whos total spending has reduced compare to last month () 
    
    Return customer_name, customer_id, last MONTH spend, current month spent 
    Note consider last month as March Current Month as April
*/

WITH 
	prev_month_spending AS (
		SELECT 	customer_id, 
				EXTRACT(MONTH FROM spending_date) AS date_month, 
				SUM(spending_amount) AS prev_total_spending
		FROM spending_records
		WHERE EXTRACT(MONTH FROM spending_date) = 3
		GROUP BY customer_id, date_month
	),
    cur_month_spending AS (
		SELECT 	customer_id, 
				EXTRACT(MONTH FROM spending_date) AS date_month, 
				SUM(spending_amount) AS cur_total_spending
		FROM spending_records
		WHERE EXTRACT(MONTH FROM spending_date) = 4
		GROUP BY customer_id, date_month
	)
SELECT 	c.customer_name, 			
		p.prev_total_spending,
		cr.cur_total_spending 
FROM customers37 AS c
JOIN prev_month_spending AS p    
USING (customer_id)    
JOIN cur_month_spending AS cr
USING (customer_id)
WHERE p.prev_total_spending > cr.cur_total_spending;


/* 
	*****************************************************************
					SQL challenge 38/50
    *****************************************************************
*/


DROP TABLE IF EXISTS Employees38;
CREATE TABLE Employees38 (
  Emp_No DECIMAL(4,0) NOT NULL,
  Emp_Name VARCHAR(10),
  Job_Name VARCHAR(9),
  Manager_Id DECIMAL(4,0),
  HireDate DATE,
  Salary DECIMAL(7,2),
  Commission DECIMAL(7,2),  
  Department VARCHAR(20) -- Changed from DeptNo to Department
);

INSERT INTO Employees38 (Emp_No, Emp_Name, Job_Name, Manager_Id, HireDate, Salary, Commission, Department) VALUES
(7839, 'KING', 'PRESIDENT', NULL, '1981-11-17', 5000, NULL, 'IT'),
(7698, 'BLAKE', 'MANAGER', 7839, '1981-05-01', 2850, NULL, 'HR'),
(7782, 'CLARK', 'MANAGER', 7839, '1981-06-09', 2450, NULL, 'Marketing'),
(7566, 'JONES', 'MANAGER', 7839, '1981-04-02', 2975, NULL, 'Operations'),
(7788, 'SCOTT', 'ANALYST', 7566, '1987-07-29', 3000, NULL, 'Operations'),
(7902, 'FORD', 'ANALYST', 7566, '1981-12-03', 3000, NULL, 'Operations'),
(7369, 'SMITH', 'CLERK', 7902, '1980-12-17', 800, NULL, 'Operations'),
(7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20', 1600, 300, 'HR'),
(7521, 'WARD', 'SALESMAN', 7698, '1981-02-22', 1250, 500, 'HR'),
(7654, 'MARTIN', 'SALESMAN', 7698, '1981-09-28', 1250, 1400, 'HR'),
(7844, 'TURNER', 'SALESMAN', 7698, '1981-09-08', 1500, 0, 'HR'),
(7876, 'ADAMS', 'CLERK', 7788, '1987-06-02', 1100, NULL, 'Operations'),
(7900, 'JAMES', 'CLERK', 7698, '1981-12-03', 950, NULL, 'HR'),
(7934, 'MILLER', 'CLERK', 7782, '1982-01-23', 1300, NULL, 'Marketing'),
(7905, 'BROWN', 'SALESMAN', 7698, '1981-11-12', 1250, 1400, 'HR'),
(7906, 'DAVIS', 'ANALYST', 7566, '1987-07-13', 3000, NULL, 'Operations'),
(7907, 'GARCIA', 'MANAGER', 7839, '1981-08-12', 2975, NULL, 'IT'),
(7908, 'HARRIS', 'SALESMAN', 7698, '1981-06-21', 1600, 300, 'HR'),
(7909, 'JACKSON', 'CLERK', 7902, '1981-11-17', 800, NULL, 'Operations'),
(7910, 'JOHNSON', 'MANAGER', 7839, '1981-04-02', 2850, NULL, 'Marketing'),
(7911, 'LEE', 'ANALYST', 7566, '1981-09-28', 1250, 1400, 'Operations'),
(7912, 'MARTINEZ', 'CLERK', 7902, '1981-12-03', 1250, NULL, 'Operations'),
(7913, 'MILLER', 'MANAGER', 7839, '1981-01-23', 2450, NULL, 'HR'),
(7914, 'RODRIGUEZ', 'SALESMAN', 7698, '1981-12-03', 1500, 0, 'Marketing'),
(7915, 'SMITH', 'CLERK', 7902, '1980-12-17', 1100, NULL, 'IT'),
(7916, 'TAYLOR', 'CLERK', 7902, '1981-02-20', 950, NULL, 'Marketing'),
(7917, 'THOMAS', 'SALESMAN', 7698, '1981-02-22', 1250, 500, 'Operations'),
(7918, 'WHITE', 'ANALYST', 7566, '1981-09-28', 1300, NULL, 'IT'),
(7919, 'WILLIAMS', 'MANAGER', 7839, '1981-11-17', 5000, NULL, 'Marketing'),
(7920, 'WILSON', 'SALESMAN', 7698, '1981-05-01', 2850, NULL, 'HR'),
(7921, 'YOUNG', 'CLERK', 7902, '1981-06-09', 2450, NULL, 'Operations'),
(7922, 'ADAMS', 'ANALYST', 7566, '1987-07-13', 3000, NULL, 'HR'),
(7923, 'BROWN', 'MANAGER', 7839, '1981-08-12', 2975, NULL, 'Marketing'),
(7924, 'DAVIS', 'SALESMAN', 7698, '1981-06-21', 1600, 300, 'Operations');

/*
Most Asked Data Analyst Interview Questions : 
	Write an SQL query to retrieve employee details from each department who have a salary greater 
	than the average salary in their department.
*/

-- Corelated Subquery
SELECT 
    e1.emp_name,
    e1.salary,
    e1.department
FROM employees38 as e1
WHERE salary > (SELECT AVG(e2.salary)
                FROM employees38 as e2
                WHERE e2.department = e1.department); 

-- Your Task
-- Find the employee who has less than average salary accross company?


/*
	*******************************************************************
				SQL Challenge Day 39/50
	*******************************************************************
*/

DROP TABLE IF EXISTS amazon_products;
CREATE TABLE amazon_products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2),
    country VARCHAR(50)
);

INSERT INTO amazon_products (product_name, category, price, country) VALUES
('iPhone 13 Pro Max', 'Smartphones', 1099.00, 'USA'),
('Samsung Galaxy S21 Ultra', 'Smartphones', 1199.99, 'USA'),
('Google Pixel 6 Pro', 'Smartphones', 899.00, 'USA'),
('Samsung QN90A Neo QLED TV', 'TVs', 2397.99, 'USA'),
('LG OLED C1 Series', 'TVs', 1996.99, 'USA'),
('Sony Bravia XR A90J', 'TVs', 2798.00, 'USA'),
('Apple MacBook Pro 16-inch', 'Laptops', 2399.00, 'USA'),
('Dell XPS 15', 'Laptops', 1899.99, 'USA'),
('Microsoft Surface Laptop 4', 'Laptops', 1299.99, 'USA'),
('Sony WH-1000XM4 Wireless Headphones', 'Headphones', 348.00, 'USA'),
('Bose Noise Cancelling Headphones 700', 'Headphones', 379.00, 'USA'),
('Apple AirPods Pro', 'Headphones', 249.00, 'USA'),
('Samsung Odyssey G9 Gaming Monitor', 'Monitors', 1399.99, 'USA'),
('Dell S2721QS 27-inch 4K Monitor', 'Monitors', 339.99, 'USA'),
('LG 27GN950-B UltraGear Gaming Monitor', 'Monitors', 1296.99, 'USA'),
('Canon EOS R5 Mirrorless Camera', 'Cameras', 3899.00, 'USA'),
('Sony Alpha a7 III Mirrorless Camera', 'Cameras', 1998.00, 'USA'),
('Nikon Z7 II Mirrorless Camera', 'Cameras', 2996.95, 'USA'),
('Nintendo Switch', 'Gaming Consoles', 299.99, 'USA'),
('PlayStation 5', 'Gaming Consoles', 499.99, 'USA'),
('Xbox Series X', 'Gaming Consoles', 499.99, 'USA'),
('Apple Watch Series 7', 'Smartwatches', 399.00, 'USA'),
('Samsung Galaxy Watch 4', 'Smartwatches', 249.99, 'USA'),
('Fitbit Sense', 'Smartwatches', 299.95, 'USA'),
('iPhone 13 Pro Max', 'Smartphones', 1099.00, 'USA'),
('Samsung Galaxy S21 Ultra', 'Smartphones', 1199.99, 'USA'),
('Google Pixel 6 Pro', 'Smartphones', 899.00, 'USA'),
('Samsung QN90A Neo QLED TV', 'TVs', 2397.99, 'USA'),
('LG OLED C1 Series', 'TVs', 1996.99, 'USA'),
('Sony Bravia XR A90J', 'TVs', 2798.00, 'USA'),
('Apple MacBook Pro 16-inch', 'Laptops', 2399.00, 'USA'),
('Dell XPS 15', 'Laptops', 1899.99, 'USA'),
('Microsoft Surface Laptop 4', 'Laptops', 1299.99, 'USA'),
('Sony WH-1000XM4 Wireless Headphones', 'Headphones', 348.00, 'USA'),
('Bose Noise Cancelling Headphones 700', 'Headphones', 379.00, 'USA'),
('Apple AirPods Pro', 'Headphones', 249.00, 'USA'),
('Samsung Odyssey G9 Gaming Monitor', 'Monitors', 1399.99, 'USA'),
('Dell S2721QS 27-inch 4K Monitor', 'Monitors', 339.99, 'USA'),
('LG 27GN950-B UltraGear Gaming Monitor', 'Monitors', 1296.99, 'USA'),
('Canon EOS R5 Mirrorless Camera', 'Cameras', 3899.00, 'USA'),
('Sony Alpha a7 III Mirrorless Camera', 'Cameras', 1998.00, 'USA'),
('Nikon Z7 II Mirrorless Camera', 'Cameras', 2996.95, 'USA'),
('Nintendo Switch', 'Gaming Consoles', 299.99, 'USA'),
('PlayStation 5', 'Gaming Consoles', 499.99, 'USA'),
('Xbox Series X', 'Gaming Consoles', 499.99, 'USA'),
('Apple Watch Series 7', 'Smartwatches', 399.00, 'USA'),
('Samsung Galaxy Watch 4', 'Smartwatches', 249.99, 'USA'),
('Fitbit Sense', 'Smartwatches', 299.95, 'USA'),
('iPhone 13 Pro Max', 'Smartphones', 1099.00, 'USA'),
('Samsung Galaxy S21 Ultra', 'Smartphones', 1199.99, 'USA'),
('Google Pixel 6 Pro', 'Smartphones', 899.00, 'USA'),
('Samsung QN90A Neo QLED TV', 'TVs', 2397.99, 'USA'),
('LG OLED C1 Series', 'TVs', 1996.99, 'USA'),
('Sony Bravia XR A90J', 'TVs', 2798.00, 'USA'),
('Apple MacBook Pro 16-inch', 'Laptops', 2399.00, 'USA'),
('Dell XPS 15', 'Laptops', 1899.99, 'USA'),
('Microsoft Surface Laptop 4', 'Laptops', 1299.99, 'USA'),
('Sony WH-1000XM4 Wireless Headphones', 'Headphones', 348.00, 'USA');

DROP TABLE IF EXISTS return_records;
CREATE TABLE return_records (
    return_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    return_reason VARCHAR(255),
    return_date DATE
);
INSERT INTO return_records (order_id, product_id, return_reason, return_date) VALUES
(1006, 7, 'Defective product', '2024-04-27'),
(1007, 9, 'Wrong color', '2024-04-29'),
(1008, 8, 'Size too small', '2024-05-01'),
(1009, 6, 'Not satisfied with quality', '2024-05-03'),
(1010, 10, 'Received wrong item', '2024-05-05'),
(1011, 12, 'Defective product', '2024-05-07'),
(1012, 11, 'Changed mind', '2024-05-09'),
(1013, 14, 'Item not needed', '2024-05-11'),
(1014, 15, 'Damaged upon arrival', '2024-05-13'),
(1015, 13, 'Wrong quantity', '2024-05-15'),
(1016, 16, 'Defective product', '2024-05-17'),
(1017, 17, 'Wrong size', '2024-05-19'),
(1018, 18, 'Received damaged', '2024-05-21'),
(1019, 19, 'Not as described', '2024-05-23'),
(1020, 20, 'Changed mind', '2024-05-25'),
(1021, 21, 'Item not needed', '2024-05-27'),
(1022, 22, 'Defective product', '2024-05-29'),
(1023, 23, 'Wrong color', '2024-05-31'),
(1024, 24, 'Received wrong item', '2024-06-02'),
(1025, 25, 'Size too small', '2024-06-04'),
(1026, 26, 'Damaged upon arrival', '2024-06-06'),
(1027, 27, 'Defective product', '2024-06-08'),
(1028, 28, 'Not satisfied with quality', '2024-06-10'),
(1029, 29, 'Wrong quantity', '2024-06-12'),
(1030, 30, 'Changed mind', '2024-06-14'),
(1031, 31, 'Item not needed', '2024-06-16'),
(1032, 32, 'Defective product', '2024-06-18'),
(1033, 33, 'Wrong size', '2024-06-20'),
(1034, 34, 'Received damaged', '2024-06-22'),
(1035, 35, 'Not as described', '2024-06-24'),
(1036, 36, 'Changed mind', '2024-06-26'),
(1037, 37, 'Item not needed', '2024-06-28'),
(1038, 38, 'Defective product', '2024-06-30'),
(1039, 39, 'Wrong color', '2024-07-02'),
(1040, 40, 'Received wrong item', '2024-07-04');


/*
Question:
	Write a SQL query to show each product category and its return percentage. 
	return percentage = total_return by category /total_overall_return * 100
	Expected Output:
		Category: Name of the product category.
        Return Percentage: Percentage of returns for each category.
*/

-- category name,
-- total returns
-- each category return count
-- each category return count/total returns * 100
-- product_id, product_name, category, price, country -> amazon_products
-- return_id, order_id, product_id, return_reason, return_date --> returns_records
WITH cat_price AS (
	SELECT 	ap.category, ap.price
	FROM return_records AS rr
	INNER JOIN
	amazon_products AS ap
	USING (product_id)
    ORDER BY ap.category
)
SELECT category, SUM(price) cat_total
FROM cat_price
GROUP BY category;

SELECT SUM(price)FROM cat_price;
SELECT 	category, 
		(100 * (SELECT SUM(price)/(SELECT SUM(price)FROM cat_price) 
		 FROM cat_price
         GROUP BY category) )AS returns_share
FROM cat_price;


/*
	****************************************************************
					SQL Challenge Day 40/50
    ****************************************************************
*/
DROP table if exists order_data;
CREATE TABLE order_data (
    order_id SERIAL PRIMARY KEY,
    order_time TIMESTAMP,
    customer_id INT,
    total_amount DECIMAL(10, 2)
);
INSERT INTO order_data (order_time, customer_id, total_amount) VALUES
    ('2024-03-31 08:30:00', 1001, 25.50),
    ('2024-03-31 09:15:00', 1002, 32.75),
    ('2024-03-31 10:00:00', 1003, 20.00),
    ('2024-03-31 11:45:00', 1004, 18.50),
    ('2024-03-31 12:30:00', 1005, 27.80),
    ('2024-03-31 13:15:00', 1006, 35.20),
    ('2024-03-31 14:00:00', 1007, 40.00),
    ('2024-03-31 15:45:00', 1008, 22.90),
    ('2024-03-31 16:30:00', 1009, 28.75),
    ('2024-03-31 17:15:00', 1010, 30.60),
    ('2024-03-31 18:00:00', 1011, 24.95),
    ('2024-03-31 19:45:00', 1012, 38.25),
    ('2024-03-31 20:30:00', 1013, 42.80),
    ('2024-03-31 21:15:00', 1014, 26.40),
    ('2024-03-31 22:00:00', 1015, 33.10),
    ('2024-03-31 23:45:00', 1016, 20.50),
    ('2024-03-31 00:15:00', 1017, 28.75),
    ('2024-03-31 01:00:00', 1018, 18.90),
    ('2024-03-31 22:45:00', 1019, 23.25),
    ('2024-03-31 22:30:00', 1020, 30.00),
    ('2024-03-31 22:15:00', 1021, 35.80),
    ('2024-03-31 23:00:00', 1022, 38.50),
    ('2024-03-31 06:45:00', 1023, 21.20),
    ('2024-03-31 09:30:00', 1024, 27.95),
    ('2024-03-31 23:15:00', 1025, 32.70),
    ('2024-03-31 09:00:00', 1026, 25.45),
    ('2024-03-31 10:45:00', 1027, 37.80),
    ('2024-03-31 21:30:00', 1028, 40.90),
    ('2024-03-31 23:15:00', 1029, 24.60),
    ('2024-03-31 13:00:00', 1030, 31.75),
    ('2024-03-31 22:45:00', 1031, 22.50),
    ('2024-03-31 22:30:00', 1032, 30.25),
    ('2024-03-31 23:15:00', 1033, 19.80),
    ('2024-03-31 23:00:00', 1034, 24.75),
    ('2024-03-31 20:45:00', 1035, 32.50),
    ('2024-03-31 20:30:00', 1036, 38.20),
    ('2024-03-31 20:15:00', 1037, 41.75),
    ('2024-03-31 22:00:00', 1038, 23.80),
    ('2024-03-31 22:45:00', 1039, 29.95),
    ('2024-03-31 22:30:00', 1040, 31.60);

/*
Swiggy Data Analyst Interview Question:
	Write a SQL query to analyze the order patterns throughout the day, providing insights into each 
	hour's total orders and their respective percentages of the total orders. 

	The output should include the hour, total orders, and order percentage. Order by % order in decending
		%orders = hourly order/total_orders * 100
*/
-- each hour and their total order
-- each hour order/total order * 100
-- ORDER BY 2 Desc

-- SELECT COUNT(*) FROM order_data
-- order_id, order_time, customer_id, total_amount

WITH hourly_order AS (
	SELECT 	EXTRACT(HOUR FROM order_time) AS hrs, 
			total_amount
    FROM order_data
)
SELECT 	hrs, COUNT(hrs) AS ord_cnt,
		ROUND (100 * COUNT(hrs)/(SELECT COUNT(*) FROM hourly_order), 2) AS perc_orders
FROM hourly_order
GROUP BY hrs;


/*
-- Your Task
Create a new time category as Morning, After_noon, Evening and Night 
And Find total orders fall into this category
Morning < 12 O clock
After noon between 12 and 5
Evening 5 and 8
Night > 8 
*/


/*
	****************************************************************
					Day 41/50 SQL Challenge
    ****************************************************************
*/
CREATE TABLE user_purchases41 (
    user_id INT,
    date DATE,
    amount_spent FLOAT,
    day_name VARCHAR(20)
);

-- Insert records into the user_purchases table
INSERT INTO user_purchases41 (user_id, date, amount_spent, day_name) VALUES
(1047, '2023-01-01', 288, 'Sunday'),
(1099, '2023-01-04', 803, 'Wednesday'),
(1055, '2023-01-07', 546, 'Saturday'),
(1040, '2023-01-10', 680, 'Tuesday'),
(1052, '2023-01-13', 889, 'Friday'),
(1052, '2023-01-13', 596, 'Friday'),
(1016, '2023-01-16', 960, 'Monday'),
(1023, '2023-01-17', 861, 'Tuesday'),
(1010, '2023-01-19', 758, 'Thursday'),
(1013, '2023-01-19', 346, 'Thursday'),
(1069, '2023-01-21', 541, 'Saturday'),
(1030, '2023-01-22', 175, 'Sunday'),
(1034, '2023-01-23', 707, 'Monday'),
(1019, '2023-01-25', 253, 'Wednesday'),
(1052, '2023-01-25', 868, 'Wednesday'),
(1095, '2023-01-27', 424, 'Friday'),
(1017, '2023-01-28', 755, 'Saturday'),
(1010, '2023-01-29', 615, 'Sunday'),
(1063, '2023-01-31', 534, 'Tuesday'),
(1019, '2023-02-03', 185, 'Friday'),
(1019, '2023-02-03', 995, 'Friday'),
(1092, '2023-02-06', 796, 'Monday'),
(1058, '2023-02-09', 384, 'Thursday'),
(1055, '2023-02-12', 319, 'Sunday'),
(1090, '2023-02-15', 168, 'Wednesday'),
(1090, '2023-02-18', 146, 'Saturday'),
(1062, '2023-02-21', 193, 'Tuesday'),
(1023, '2023-02-24', 259, 'Friday'),
(1023, '2023-02-24', 849, 'Friday'),
(1009, '2023-02-27', 552, 'Monday'),
(1012, '2023-03-02', 303, 'Thursday'),
(1001, '2023-03-05', 317, 'Sunday'),
(1058, '2023-03-08', 573, 'Wednesday'),
(1001, '2023-03-11', 531, 'Saturday'),
(1034, '2023-03-14', 440, 'Tuesday'),
(1096, '2023-03-17', 650, 'Friday'),
(1048, '2023-03-20', 711, 'Monday'),
(1089, '2023-03-23', 388, 'Thursday'),
(1001, '2023-03-26', 353, 'Sunday'),
(1016, '2023-03-29', 833, 'Wednesday');


/*
SQL Challenge: Friday Purchases
	Scenario:
		IBM wants to analyze user purchases for Fridays in the first quarter of the year. 
		Calculate the average amount users spent per order for each Friday.

Question:
	Write an SQL query to find the average amount spent by users per order for each Friday 
    in the first quarter of the year.
*/
-- user_id, date, amount_spent, day_name --> user_purchases41
WITH qtr_details AS (
	SELECT 	user_id, COUNT(*) AS friday_orders,
			SUM(amount_spent) AS spending		
	FROM user_purchases41
	WHERE day_name LIKE "%Friday%"
	GROUP BY user_id, EXTRACT(QUARTER FROM date) 
)	
SELECT 	user_id,
        spending/(SELECT SUM(friday_orders) FROM qtr_details) AS per_order_spending
FROM qtr_details;
    

/*
	********************************************************************
				SQL Challenge 42/50
    ********************************************************************
*/
 DROP TABLE IF EXISTS uber_ride;
CREATE TABLE uber_ride (
    ride_id SERIAL PRIMARY KEY,
    ride_timestamp TIMESTAMP,
    ride_status VARCHAR(20)  -- "ride_completed", "cancelled_by_driver" or "cancelled_by_user"
);
INSERT INTO uber_ride (ride_timestamp, ride_status)
VALUES
    ('2024-05-09 08:30:00', 'cancelled_by_driver'),
    ('2024-05-09 09:00:00', 'cancelled_by_user'),
    ('2024-05-09 10:00:00', 'ride_completed'),
    ('2024-05-09 11:00:00', 'cancelled_by_user'),
    ('2024-05-09 12:00:00', 'cancelled_by_driver'),
    ('2024-05-09 13:00:00', 'cancelled_by_user'),
    ('2024-05-09 14:00:00', 'cancelled_by_user'),
    ('2024-05-09 15:00:00', 'cancelled_by_user'),
    ('2024-05-09 16:00:00', 'ride_completed'),
    ('2024-05-09 17:00:00', 'cancelled_by_user'),
    ('2024-05-09 18:00:00', 'ride_completed'),
    ('2024-05-09 19:00:00', 'cancelled_by_user'),
    ('2024-05-09 20:00:00', 'cancelled_by_user'),
    ('2024-05-09 21:00:00', 'cancelled_by_user'),
    ('2024-05-09 22:00:00', 'cancelled_by_driver'),
    ('2024-05-09 13:00:00', 'cancelled_by_user'),
    ('2024-05-09 14:00:00', 'cancelled_by_user'),
    ('2024-05-09 15:00:00', 'cancelled_by_user'),
    ('2024-05-09 16:00:00', 'ride_completed'),
    ('2024-05-09 17:00:00', 'cancelled_by_user'),
    ('2024-05-09 18:00:00', 'cancelled_by_driver'),
    ('2024-05-09 19:00:00', 'cancelled_by_user'),
    ('2024-05-09 20:00:00', 'cancelled_by_user'),
    ('2024-05-09 21:00:00', 'cancelled_by_user'),
    ('2024-05-09 22:00:00', 'cancelled_by_driver');
/*
UBER Data Analyst Interview Question :
	Find out % of ride cancelled by uber_driver
*/

-- total cnt of cancelled ride
-- total ride that was cancelled by driver
-- 2/1 * 100

SELECT ROUND(100 * (SELECT COUNT(*) 
			  FROM uber_ride 
			  WHERE ride_status LIKE "%cancelled_by_driver%")/total_cancelled_rides, 2) AS ride_cancelled_by_drivers
FROM (
		SELECT COUNT(*) AS total_cancelled_rides
		FROM uber_ride 
        WHERE ride_status LIKE "%cancelled%"
	) AS cancelled_rides;


SELECT   
    ROUND( 
    SUM(
    CASE 
       WHEN ride_status = 'cancelled_by_driver' 
       THEN 1 
        ELSE 0
    END
    )::numeric/(SELECT COUNT(1) FROM uber_ride 
        WHERE ride_status <> 'ride_completed' )::numeric
    * 100,2) as percentage_ride_cancelled_driver
FROM uber_ride;

-- -- Your Task is to find out how how many ride were cancelled by user in the evening 
-- hour > 17 is considered as evening 

/*
	****************************************************************
				SQL Challenge 43/50
    ****************************************************************
*/
CREATE TABLE forbes_global (
    company VARCHAR(100),
    sector VARCHAR(100),
    industry VARCHAR(100),
    country VARCHAR(100),
    sales FLOAT,
    profits FLOAT,
    rnk INT
);

insert into forbes_global VALUES  
('Walmart', 'Consumer Discretionary', 'General Merchandisers', 'United States', 482130.0, 14694.0, 1),
('Sinopec-China Petroleum', 'Energy', 'Oil & Gas Operations', 'China', 448452.0, 7840.0, 2),
('Royal Dutch Shell', 'Energy', 'Oil & Gas Operations', 'Netherlands', 396556.0, 15340.0, 3),
('China National Petroleum', 'Energy', 'Oil & Gas Operations', 'China', 392976.0, 2837.0, 4),
('State Grid', 'Utilities', 'Electric Utilities', 'China', 387056.0, 9573.0, 5),
('Saudi Aramco', 'Energy', 'Oil & Gas Operations', 'Saudi Arabia', 355905.0, 11002.0, 6),
('Volkswagen', 'Consumer Discretionary', 'Auto & Truck Manufacturers', 'Germany', 283565.0, 17742.4, 7),
('BP', 'Energy', 'Oil & Gas Operations', 'United Kingdom', 282616.0, 3591.0, 8),
('Amazon.com', 'Consumer Discretionary', 'Internet Services and Retailing', 'United States', 280522.0, 5362.0, 9),
('Toyota Motor', 'Consumer Discretionary', 'Auto & Truck Manufacturers', 'Japan', 275288.0, 18499.3, 10),
('Apple', 'Information Technology', 'Computers, Office Equipment', 'United States', 265595.0, 55256.0, 11),
('Exxon Mobil', 'Energy', 'Oil & Gas Operations', 'United States', 263910.0, 15850.0, 12),
('Berkshire Hathaway', 'Financials', 'Diversified Financials', 'United States', 247837.0, 8971.0, 13),
('Samsung Electronics', 'Information Technology', 'Electronics', 'South Korea', 245898.0, 19783.3, 14),
('McKesson', 'Health Care', 'Health Care: Pharmacy and Other Services', 'United States', 231091.0, 5070.0, 15),
('Glencore', 'Materials', 'Diversified Metals & Mining', 'Switzerland', 219754.0, 5436.0, 16),
('UnitedHealth Group', 'Health Care', 'Health Care: Insurance and Managed Care', 'United States', 201159.0, 13650.0, 17),
('Daimler', 'Consumer Discretionary', 'Auto & Truck Manufacturers', 'Germany', 197515.0, 8245.1, 18),
('CVS Health', 'Health Care', 'Health Care: Pharmacy and Other Services', 'United States', 194579.0, 6634.0, 19),
('AT&T', 'Telecommunication Services', 'Telecommunications', 'United States', 181193.0, 13906.0, 20),
('Foxconn', 'Technology', 'Electronics', 'Taiwan', 175617.0, 4103.4, 21),
('General Motors', 'Consumer Discretionary', 'Auto & Truck Manufacturers', 'United States', 174049.0, 6710.0, 22),
('Verizon Communications', 'Telecommunication Services', 'Telecommunications', 'United States', 170756.0, 19225.0, 23),
('Total', 'Energy', 'Oil & Gas Operations', 'France', 149769.0, 7480.0, 24),
('IBM', 'Information Technology', 'Information Technology Services', 'United States', 141682.0, 6606.0, 25),
('Ford Motor', 'Consumer Discretionary', 'Auto & Truck Manufacturers', 'United States', 140545.0, 6471.0, 26),
('Hon Hai Precision Industry', 'Technology', 'Electronics', 'Taiwan', 135129.0, 4493.3, 27),
('Trafigura Group', 'Energy', 'Trading', 'Singapore', 131638.0, 975.0, 28),
('General Electric', 'Industrials', 'Diversified Industrials', 'United States', 126661.0, 5136.0, 29),
('AmerisourceBergen', 'Health Care', 'Wholesalers: Health Care', 'United States', 122848.0, 1605.5, 30),
('Fannie Mae', 'Financials', 'Diversified Financials', 'United States', 120472.0, 18418.0, 31),
('Trafigura Group', 'Energy', 'Trading', 'Switzerland', 120438.0, 975.0, 32),
('Koch Industries', 'Diversified', 'Diversified', 'United States', 115095.0, 5142.0, 33),
('Cardinal Health', 'Health Care', 'Wholesalers: Health Care', 'United States', 113982.0, 1377.0, 34),
('Alphabet', 'Technology', 'Internet Services and Retailing', 'United States', 110855.0, 18616.0, 35),
('Chevron', 'Energy', 'Oil & Gas Operations', 'United States', 110360.0, 5520.0, 36),
('Costco Wholesale', 'Consumer Discretionary', 'General Merchandisers', 'United States', 110215.0, 2115.0, 37),
('Cardinal Health', 'Health Care', 'Health Care: Pharmacy and Other Services', 'United States', 109838.0, 1718.0, 38),
('Ping An Insurance Group', 'Financials', 'Insurance', 'China', 109254.0, 2047.4, 39),
('Walgreens Boots Alliance', 'Consumer Staples', 'Food and Drug Stores', 'United States', 109026.0, 4563.0, 40),
('Costco Wholesale', 'Consumer Discretionary', 'Retailing', 'United States', 105156.0, 2115.0, 41),
('JPMorgan Chase', 'Financials', 'Diversified Financials', 'United States', 105153.0, 30615.0, 42),
('Verizon Communications', 'Telecommunication Services', 'Telecommunications', 'United States', 104887.0, 13568.0, 43),
('China Construction Bank', 'Financials', 'Banks', 'China', 104693.0, 38369.0, 44),
('China Construction Bank', 'Financials', 'Major Banks', 'China', 104692.9, 38369.2, 45),
('Trafigura Group', 'Energy', 'Trading', 'Netherlands', 103752.0, 975.0, 46),
('Exor Group', 'Financials', 'Diversified Financials', 'Netherlands', 103606.6, -611.2, 47),
('Anheuser-Busch InBev', 'Consumer Staples', 'Beverages', 'Belgium', 101541.0, 9536.0, 48),
('Bank of America', 'Financials', 'Banks', 'United States', 100264.0, 18724.0, 49),
('Bank of China', 'Financials', 'Banks', 'China', 99237.3, 28202.1, 50),
('Trafigura Group', 'Energy', 'Trading', 'Switzerland', 97296.0, 975.0, 51),
('Dell Technologies', 'Technology', 'Computers, Office Equipment', 'United States', 94477.0, 2743.0, 52),
('CVS Health', 'Health Care', 'Health Care: Insurance and Managed Care', 'United States', 94005.0, 6239.0, 53),
('Trafigura Group', 'Energy', 'Trading', 'United Kingdom', 90345.0, 975.0, 54),
('Trafigura Group', 'Energy', 'Trading', 'Switzerland', 88265.0, 975.0, 55),
('Trafigura Group', 'Energy', 'Trading', 'Netherlands', 88111.0, 975.0, 56),
('Trafigura Group', 'Energy', 'Trading', 'Switzerland', 87044.0, 975.0, 57),
('Trafigura Group', 'Energy', 'Trading', 'Switzerland', 84795.0, 975.0, 58),
('Trafigura Group', 'Energy', 'Trading', 'Switzerland', 84361.0, 975.0, 59),
('Trafigura Group', 'Energy', 'Trading', 'Switzerland', 83156.0, 975.0, 60),
('Trafigura Group', 'Energy', 'Trading', 'Switzerland', 82276.0, 975.0, 61);

/*
Most Profitable Companies :
	Find out each country's most most profitable company details
*/
-- company, sector, industry, country, sales, profits, rnk --> forbes_global
SELECT country, company, profits
FROM (
		SELECT 	country, company, profits,
				DENSE_RANK() OVER(PARTITION BY country ORDER BY profits DESC) AS rk
		FROM forbes_global
	) AS subquery
WHERE rk = 1;



SELECT *
FROM
(    
    SELECT *,
            RANK() OVER(PARTITION BY 
            country ORDER BY profits DESC) as rn
    FROM forbes_global
)
WHERE rn = 1;

-- -- Your Task 
-- Find out each sector top 2 most profitable company details

/*
	****************************************************************
						SQL Challenge 44/50
	****************************************************************
*/

CREATE TABLE house_price (
    id INT,
    state VARCHAR(255),
    city VARCHAR(255),
    street_address VARCHAR(255),
    mkt_price INT
);
-- Insert all the records
INSERT INTO house_price (id, state, city, street_address, mkt_price) VALUES
(1, 'NY', 'New York City', '66 Trout Drive', 449761),
(2, 'NY', 'New York City', 'Atwater', 277527),
(3, 'NY', 'New York City', '58 Gates Street', 268394),
(4, 'NY', 'New York City', 'Norcross', 279929),
(5, 'NY', 'New York City', '337 Shore Ave.', 151592),
(6, 'NY', 'New York City', 'Plainfield', 624531),
(7, 'NY', 'New York City', '84 Central Street', 267345),
(8, 'NY', 'New York City', 'Passaic', 88504),
(9, 'NY', 'New York City', '951 Fulton Road', 270476),
(10, 'NY', 'New York City', 'Oxon Hill', 118112),
(11, 'CA', 'Los Angeles', '692 Redwood Court', 150707),
(12, 'CA', 'Los Angeles', 'Lewiston', 463180),
(13, 'CA', 'Los Angeles', '8368 West Acacia Ave.', 538865),
(14, 'CA', 'Los Angeles', 'Pearl', 390896),
(15, 'CA', 'Los Angeles', '8206 Old Riverview Rd.', 117754),
(16, 'CA', 'Los Angeles', 'Seattle', 424588),
(17, 'CA', 'Los Angeles', '7227 Joy Ridge Rd.', 156850),
(18, 'CA', 'Los Angeles', 'Battle Ground', 643454),
(19, 'CA', 'Los Angeles', '233 Bedford Ave.', 713841),
(20, 'CA', 'Los Angeles', 'Saint Albans', 295852),
(21, 'IL', 'Chicago', '8830 Baker St.', 12944),
(22, 'IL', 'Chicago', 'Watertown', 410766),
(23, 'IL', 'Chicago', '632 Princeton St.', 160696),
(24, 'IL', 'Chicago', 'Waxhaw', 464144),
(25, 'IL', 'Chicago', '7773 Tailwater Drive', 129393),
(26, 'IL', 'Chicago', 'Bonita Springs', 174886),
(27, 'IL', 'Chicago', '31 Summerhouse Rd.', 296008),
(28, 'IL', 'Chicago', 'Middleburg', 279000),
(29, 'IL', 'Chicago', '273 Windfall Avenue', 424846),
(30, 'IL', 'Chicago', 'Graham', 592268),
(31, 'TX', 'Houston', '91 Canterbury Dr.', 632014),
(32, 'TX', 'Houston', 'Dallas', 68868),
(33, 'TX', 'Houston', '503 Elmwood St.', 454184),
(34, 'TX', 'Houston', 'Kennewick', 186280),
(35, 'TX', 'Houston', '739 Chapel Street', 334474),
(36, 'TX', 'Houston', 'San Angelo', 204460),
(37, 'TX', 'Houston', '572 Parker Dr.', 678443),
(38, 'TX', 'Houston', 'Bellmore', 401090),
(39, 'TX', 'Houston', '8653 South Oxford Street', 482214),
(40, 'TX', 'Houston', 'Butler', 330868),
(41, 'AZ', 'Phoenix', '8667 S. Joy Ridge Court', 316291),
(42, 'AZ', 'Phoenix', 'Torrance', 210392),
(43, 'AZ', 'Phoenix', '35 Harvard St.', 167502),
(44, 'AZ', 'Phoenix', 'Nutley', 327554),
(45, 'AZ', 'Phoenix', '7313 Vermont St.', 285135),
(46, 'AZ', 'Phoenix', 'Lemont', 577667),
(47, 'AZ', 'Phoenix', '8905 Buttonwood Dr.', 212301),
(48, 'AZ', 'Phoenix', 'Lafayette', 317504);

/*
	Identify properites where the mkt_price of the house exceeds the city's average mkt_price.
*/

SELECT h1.id, h1.state, h1.city, h1.mkt_price
FROM house_price h1 
WHERE  h1.mkt_price > (SELECT AVG(h2.mkt_price) 
						FROM house_price h2
						WHERE h2.city = h1.city
					  );

-- Your Task
-- Write a query to find the property that has house mkt_price greater 
-- than average of the city's average price but less than nation's average price


/*
	*********************************************************
						SQL Challenge 45/50
    *********************************************************
*/
DROP TABLE IF EXISTS orders45;
CREATE TABLE Orders45 (
    Order_id INT PRIMARY KEY,
    Customer_id INT,
    Order_Date DATE,
    Amount DECIMAL(10, 2)
);
DROP TABLE IF EXISTS Customers45;
CREATE TABLE Customers45 (
    Customer_id INT PRIMARY KEY,
    Customer_Name VARCHAR(50),
    Join_Date DATE
);

INSERT INTO Orders45 (Order_id, Customer_id, Order_Date, Amount)
VALUES
    (1, 1, '2024-05-01', 100),
    (2, 2, '2024-05-02', 150),
    (3, 3, '2023-12-15', 200),
    (4, 1, '2024-05-03', 120),
    (5, 2, '2024-01-20', 180),
    (6, 4, '2024-03-10', 90);
INSERT INTO Customers45 (Customer_id, Customer_Name, Join_Date)
VALUES
    (1, 'Alice', '2024-01-15'),
    (2, 'Bob', '2024-02-20'),
    (3, 'Charlie', '2023-12-01'),
    (4, 'David', '2024-03-01');

/*
Amazon Data Analyst interview :	questions for exp 1-3 year!
	Write an SQL query to calculate the total order amount for each customer who joined 
	in the current year. 
    
    The output should contain Customer_Name and the total amount.
*/
-- join both table based on cx id
-- filter the cx records for current_year 
-- based on eacx cx id sum the amount
-- group by cx id

SELECT c.Customer_Name, SUM(o.Amount) AS total_amount
FROM orders45 AS o
LEFT JOIN
customers45 AS c
USING (Customer_id)
WHERE EXTRACT(YEAR FROM Join_Date) = 2024
GROUP BY o.customer_id;

SELECT
    c.customer_name,
    SUM(o.amount)
FROM orders as o
JOIN 
customers as c
on c.customer_id = o.customer_id    
WHERE EXTRACT(YEAR FROM c.join_date) = 
    EXTRACT(YEAR FROM CURRENT_DATE)
GROUP by 1;

-- Your Task
-- Write a SQL query to return each and and total orders for current year
-- return month_number, total orders


/*
	******************************************************
					SQL Challenge 46/50
    ******************************************************
*/
DROP TABLE IF EXISTS orders46;
CREATE TABLE orders46 (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount FLOAT
);

INSERT INTO orders46 (customer_id, order_date, total_amount)
VALUES
    (1001, '2024-01-01', 120.25),
    (1002, '2024-01-03', 80.99),
    (1003, '2024-01-05', 160.00),
    (1004, '2024-01-07', 95.50),
    (1001, '2024-02-09', 70.75),
    (1002, '2024-02-11', 220.00),
    (1003, '2024-02-13', 130.50),
    (1004, '2024-02-15', 70.25),
    (1001, '2024-02-17', 60.75),
    (1002, '2024-03-19', 180.99),
    (1003, '2024-03-21', 140.00),
    (1004, '2024-03-23', 110.50),
    (1001, '2024-03-25', 90.25),
    (1002, '2024-03-27', 200.00),
    (1003, '2024-03-29', 160.50),
    (1004, '2024-03-31', 120.75),
    (1001, '2024-03-02', 130.25),
    (1002, '2024-03-04', 90.99),
    (1003, '2024-03-06', 170.00),
    (1004, '2024-04-08', 105.50),
    (1001, '2024-04-10', 80.75),
    (1002, '2024-04-12', 240.00),
    (1003, '2024-04-14', 150.50),
    (1004, '2024-04-16', 80.25),
    (1001, '2024-04-18', 70.75);

/*
Amazon Data Analyst Interview Question :
	Calculate the running total of orders for each customer. 
	
    Return the customer ID, order date, total amount of each order, and the 
	cumulative total of orders for each customer sorted by customer ID and order date.
*/

SELECT *,
     SUM(total_amount) OVER(PARTITION BY 
    customer_id ORDER BY order_date)
    as running_total
FROM orders46
ORDER BY customer_id, order_date;

-- Find each customer_id and revenue collected from them in each month


/*
	************************************************************
				SQL Challenge 47/50
    ************************************************************
*/

DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    quantity INT,
    price_per_unit FLOAT
);


INSERT INTO inventory (product_name, quantity, price_per_unit)
VALUES
    ('Laptop', 20, 999.99),
    ('Smartphone', 15, 699.99),
    ('Tablet', 8, 399.99),
    ('Headphones', 25, 149.99),
    ('Mouse', 30, 29.99),
    ('Wireless Earbuds', 12, 79.99),
    ('Portable Charger', 10, 49.99),
    ('Bluetooth Speaker', 18, 129.99),
    ('Fitness Tracker', 7, 89.99),
    ('External Hard Drive', 9, 149.99),
    ('Gaming Mouse', 14, 59.99),
    ('USB-C Cable', 22, 19.99),
    ('Smart Watch', 6, 199.99),
    ('Desk Lamp', 11, 34.99),
    ('Power Bank', 16, 39.99),
    ('Wireless Mouse', 13, 29.99),
    ('Bluetooth Headset', 20, 59.99),
    ('MicroSD Card', 5, 24.99),
    ('USB Flash Drive', 8, 14.99),
    ('HDMI Cable', 17, 9.99);

/*
Question:
	Write an SQL query to display inventory details including the product name, quantity in stock, 
	remaining stock level ('Medium' if quantity is more than 10, 'Low' otherwise), and supplier ID. 
    
	Assume each product has a unique supplier ID associated with it.
*/
-- product name, quantity in stock, stock level
-- qty > 10 medium, Low
-- supplier ID


SELECT *,
    CASE 
        WHEN  quantity > 10   THEN  'Medium'
        ELSE 'low'
    END as stock_level
FROM inventory
ORDER BY stock_level;

/*
	*******************************************************
					SQL Challenge 48/50
    *******************************************************
*/
DROP TABlE IF EXISTS Customers48;
DROP TABlE IF EXISTS Orders48;
CREATE TABLE Customers48 (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    City VARCHAR(50),
    Country VARCHAR(50)
);
CREATE TABLE Orders48 (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers48(CustomerID)
);
-- Insert records into the 'Customers' table
INSERT INTO Customers48 (CustomerID, CustomerName, City, Country) 
VALUES 
(1, 'John Doe', 'New York', 'USA'),
(2, 'Jane Smith', 'Los Angeles', 'USA'),
(3, 'Michael Johnson', 'Chicago', 'USA'),
(4, 'Emily Brown', 'Houston', 'USA');

-- Insert records into the 'Orders' table
INSERT INTO Orders48 (OrderID, CustomerID, OrderDate, TotalAmount) 
VALUES 
(101, 1, '2024-05-10', 150.00),
(102, 2, '2024-05-11', 200.00),
(103, 1, '2024-05-12', 100.00),
(104, 3, '2024-05-13', 300.00);

/*
Question :
	Write an SQL query to retrive customer details along with their total order amounts (if any). 
    Include the customer's name, city, country, and total order amount. 
    
    If a customer hasn't placed any orders, display 'NULL' for the total order amount."
*/

-- CustomerID, CustomerName, City, Country --> customers48
-- OrderID, CustomerID, OrderDate, TotalAmount -- > orders48

SELECT 
    c.*,
    SUM(o.totalamount) as total_orders
FROM customers48 as c
LEFT JOIN
orders48 as o
ON o.customerid = c.customerid
GROUP BY 1;


/*
	********************************************************
				SQL Challenge 49/50
    ********************************************************
*/
DROP TABLE IF EXISTS orders49;
CREATE TABLE orders49 (
    order_id SERIAL PRIMARY KEY,
    order_date DATE
);
INSERT INTO orders49 (order_date)VALUES
    ('2024-05-01'),
    ('2024-05-01'),
    ('2024-05-01'),
    ('2024-05-02'),
    ('2024-05-02'),
    ('2024-05-02'),
    ('2024-05-03'),
    ('2024-05-03'),
    ('2024-05-03'),
    ('2024-05-03'),
    ('2024-05-03'),
    ('2024-05-04'),
    ('2024-05-04'),
    ('2024-05-04'),
    ('2024-05-04'),
    ('2024-05-04'),
    ('2024-05-05'),
    ('2024-05-05'),
    ('2024-05-05'),
    ('2024-05-05'),
    ('2024-05-06'),
    ('2024-05-06'),
    ('2024-05-06'),
    ('2024-05-06'),
    ('2024-05-06');

/*
Question:
	Identify the busiest day for orders along with the total number of orders placed on that day. 
*/
SELECT order_date, COUNT(1) AS cnt  
FROM orders49
GROUP BY order_date
ORDER BY cnt DESC
LIMIT 1;

/* re-visit it*/
SELECT order_date, cnt  
FROM ( 	
		SELECT order_date, COUNT(1) AS cnt, 
				RANK() OVER(PARTITION BY COUNT(1) ORDER BY order_date, COUNT(1) DESC) AS rk
		FROM orders49
        GROUP BY order_date
	) AS rank_cnt
WHERE rk = 1;


/*
	*********************************************************
				SQL Challenge 50/50
    *********************************************************
*/

DROP TABLE IF EXISTS sellers50;
DROP TABLE IF EXISTS orders50;
CREATE TABLE sellers50 (
    seller_id SERIAL PRIMARY KEY,
    seller_name VARCHAR(100) NOT NULL
);
INSERT INTO sellers50 (seller_name) VALUES 
    ('Seller A'),
    ('Seller B'),
    ('Seller C');

-- Create table for orders
CREATE TABLE orders50 (
    order_id SERIAL PRIMARY KEY,
    seller_id INT REFERENCES sellers(seller_id),
    product_id INT,
    category VARCHAR(50),
    quantity INT,
    price_per_unit FLOAT
);

-- Insert sample records into the orders table
INSERT INTO orders50 (seller_id, product_id, category, quantity, price_per_unit)
VALUES 
    (1, 1, 'Electronics', 2, 999.99),
    (1, 2, 'Electronics', 3, 699.99),
    (2, 3, 'Home & Kitchen', 1, 49.99),
    (2, 4, 'Home & Kitchen', 2, 79.99),
    (2, 5, 'Electronics', 1, 29.99),
    (3, 1, 'Electronics', 2, 999.99),
    (3, 4, 'Home & Kitchen', 1, 79.99),
    (1, 3, 'Home & Kitchen', 2, 49.99),
    (2, 1, 'Electronics', 1, 999.99),
    (3, 2, 'Electronics', 1, 699.99),
    (1, 4, 'Home & Kitchen', 3, 79.99),
    (2, 2, 'Electronics', 2, 699.99),
    (3, 3, 'Home & Kitchen', 1, 49.99),
    (1, 5, 'Electronics', 2, 29.99),
    (2, 4, 'Home & Kitchen', 1, 79.99),
    (3, 1, 'Electronics', 1, 999.99),
    (1, 2, 'Electronics', 1, 699.99),
    (2, 3, 'Home & Kitchen', 2, 49.99),
    (3, 5, 'Electronics', 1, 29.99),
    (1, 3, 'Home & Kitchen', 1, 49.99),
    (2, 1, 'Electronics', 3, 999.99),
    (3, 2, 'Electronics', 2, 699.99),
    (1, 4, 'Home & Kitchen', 1, 79.99),
    (2, 2, 'Electronics', 1, 699.99),
    (3, 3, 'Home & Kitchen', 3, 49.99),
    (1, 5, 'Electronics', 1, 29.99);

/*
	Write an SQL query to find each seller's revenue from each category and each product.
	return seller_name, total_revenue in each product inside each category

*/
 
-- seller_name get from seller_table
-- category_name orders TABLE
-- product_id
-- revenue

SELECT
    s.seller_name,
    o.category,
    o.product_id,
    SUM(o.price_per_unit * o.quantity) as total_revenue
FROM orders50 as o
JOIN
sellers50 as s
ON s.seller_id = o.seller_id
GROUP BY 1, 2, 3
ORDER BY 1, 3 




