
-- Product Name in dim_product table
-- Variant in dim_product table
-- Month in fact_sales_monthly table
-- Sold Quantity in fact_sales_monthly table
-- Gross Price Per Item in fact_gross_price
-- Gross Price Total in fact_gross_price

-- Croma India Product wise sales Report 
-- for fiscal year 2021

-- Total Sold Qty in a year
SELECT SUM(sold_quantity), YEAR(date) AS a_year
FROM fact_sales_monthly
GROUP BY a_year;

-- Total Sold Qty in 2021 productwise
SELECT SUM(sold_quantity), product_code
FROM fact_sales_monthly
WHERE YEAR(date) = 2021
GROUP BY product_code;

-- Details of Sales for Croma
SELECT * 
FROM fact_sales_monthly
WHERE customer_code = 90002002
ORDER BY date DESC;

-- Details of Sales for Croma in 2021
SELECT * 
FROM fact_sales_monthly
WHERE YEAR(date) = 2021 AND customer_code = 90002002
ORDER BY date DESC;

-- total sales for Croma in 2021 product wise list
SELECT SUM(sold_quantity), product_code
FROM fact_sales_monthly
WHERE YEAR(date) = 2021 AND customer_code = 90002002
GROUP BY product_code;

-- Fiscal year for Atliq starts from Sep
SELECT YEAR(DATE_ADD(date, INTERVAL 4 MONTH)) AS fiscal_year FROM fact_sales_monthly;

SELECT *
FROM fact_sales_monthly
WHERE YEAR(DATE_ADD(date, INTERVAL 4 MONTH)) = 2021 AND customer_code = 90002002
ORDER BY date DESC;

-- Using Functions for this type of requirement
SELECT *
FROM fact_sales_monthly
WHERE get_fiscal_year (date) = 2021 AND customer_code = 90002002
ORDER BY date;

/*
	report on sales for 2021 with quaterwise details
    -- 9, 10, 11 -> Q1
    -- 12, 1, 2 -> Q2
    -- 3, 4, 5 -> Q3
    -- 6, 7, 8 -> Q4
*/

SELECT *
FROM fact_sales_monthly
WHERE 
	customer_code = 90002002 AND
    get_fiscal_year (date) = 2021 AND 
    get_fiscal_quarter (date) = "Q4"
ORDER BY date DESC;

-- to get product_name & Variant 
-- Join is needed with dim_product
SELECT 
	sm.date, sm.product_code, sm.sold_quantity,
    p.product, p.variant
FROM fact_sales_monthly sm
JOIN dim_product p
USING (product_code)
WHERE 
	customer_code = 90002002 AND
    get_fiscal_year (date) = 2021 AND 
    get_fiscal_quarter (date) = "Q4"
ORDER BY date DESC;

-- to get Gross_Price per Item
-- and total_gross_price
-- Join is needed with fact_gross_price
SELECT 
	sm.date, sm.product_code, sm.sold_quantity,
    p.product, p.variant,
    gp.gross_price, 
    ROUND(gp.gross_price*sm.sold_quantity, 2) AS Total_gross_price
FROM fact_sales_monthly sm
JOIN dim_product p
USING (product_code)
JOIN fact_gross_price gp
ON 
	get_fiscal_year(date) = gp.fiscal_year AND 
    gp.product_code = sm.product_code
WHERE 
	customer_code = 90002002 AND
    get_fiscal_year (date) = 2021 AND 
    get_fiscal_quarter (date) = "Q4"
ORDER BY date DESC;

/*
	Agreegate monthly gross report for Croma India
    to track sales by particular customer is generating 
    for Atliq
    
    report contains 
    -- month 
    -- Total gross sales amount from croma in this month
*/
SELECT customer_code 
FROM dim_customer
WHERE customer LIKE '%croma%';

SELECT 
	sm.date,
    SUM(g.gross_price*sm.sold_quantity) AS total_gross_price
FROM fact_sales_monthly sm
JOIN fact_gross_price g
ON 
	sm.product_code = g.product_code AND
    g.fiscal_year = get_fiscal_year (sm.date)
WHERE customer_code = 90002002
GROUP BY sm.date
ORDER BY sm.date;

/*
	Generate a yearly report for Croma India where there are two columns
	-- 1. Fiscal Year
	-- 2. Total Gross Sales amount In that year from Croma
*/

SELECT 
	get_fiscal_year (sm.date) AS fiscal_year,
    ROUND(SUM(g.gross_price*sm.sold_quantity),2) AS yearly_sales
FROM fact_sales_monthly sm
JOIN fact_gross_price g
ON 
	sm.product_code = g.product_code AND
    g.fiscal_year = get_fiscal_year (sm.date)
WHERE customer_code = 90002002
GROUP BY get_fiscal_year(sm.date)
ORDER BY fiscal_year;

/*
	Create Stored procedure that can determine the market badge based on the 
    on the following logic:
		-- if total sold quantity > 5 million that 
		-- market is Gold else it is Silver
	Inputs will be
		-- market
        -- fiscal year
	Output should be
		-- Market Badge
*/

SELECT c.market, SUM(s.sold_quantity) AS total_sales
FROM dim_customer c
JOIN fact_sales_monthly s
ON s.customer_code = c.customer_code
WHERE get_fiscal_year (s.date) = 2021
GROUP BY c.market;

/*
	Importance of Stored Procedures
		-- Convenience
        -- Security
        -- Interoperability (used in other Prog lang)
        -- Maintainability
        -- Performance
        -- Developer Productivity increases
*/