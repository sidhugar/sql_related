/*
	Window Function Related
*/

SELECT * 
FROM random_tables.expenses
ORDER BY category;

SELECT SUM(amount) AS total_sum  #65800
FROM random_tables.expenses;

SELECT 
	*,
    amount*100/SUM(amount) OVER() AS pct
FROM random_tables.expenses
ORDER BY category;

-- pct based on per catogery
SELECT 
	*,
    amount*100/SUM(amount) OVER(PARTITION BY category) AS pct
FROM random_tables.expenses
ORDER BY category;

-- Cummulative Expences
SELECT *
FROM random_tables.expenses
ORDER BY category, date;

SELECT 
	category,
    SUM(amount) AS total_amt_category
FROM random_tables.expenses
GROUP BY category
ORDER BY category;

SELECT 
	*,
    SUM(amount)
    OVER (PARTITION BY category ORDER BY date) AS total_expence_till_date
FROM random_tables.expenses
ORDER BY category, date;


WITH cte1 AS (
	SELECT 
		customer,
		ROUND(SUM(net_sales)/1000000, 2) AS total_net_sales_mln
	FROM net_sales_report n
	JOIN dim_customer d
		ON n.customer_code = d.customer_code
	WHERE n.fiscal_year = 2021 
	GROUP BY customer )
SELECT 
	*,
	total_net_sales_mln * 100 / SUM(total_net_sales_mln) OVER () AS pct
FROM cte1
ORDER BY pct DESC;