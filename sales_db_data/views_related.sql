/*
	Problem Statement for pre-Invoice Discount Report :
	-- report for Top Customers, Products and Markets by net sales 
		for a goven fin year
*/

	SELECT 
		s.date, s.product_code,
		p.product, p.variant,
		s.sold_quantity,
		g.gross_price AS  gross_price_per_item,
		ROUND(s.sold_quantity * g.gross_price, 2) AS gross_price_total,
		pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
		ON s.product_code = p.product_code
	JOIN fact_gross_price g
		ON g.fiscal_year = get_fiscal_year(s.date)
		AND g.product_code = s.product_code
	JOIN fact_pre_invoice_deductions pre
	ON 
		pre.customer_code = s.customer_code 
		AND pre.fiscal_year = get_fiscal_year(s.date)
	WHERE 
		get_fiscal_year(s.date) = 2021
	LIMIT 1000000;


/*
	-- the Above query is time consuming
	-- it is time for optimisation
	-- So, think of look-up tables, Generated COlumsget_fiscal_year, CTE, views is necesary
*/

-- By creating a new table or Look-up Table
EXPLAIN ANALYZE
SELECT 
	s.date, s.product_code,
    p.product, p.variant,
    s.sold_quantity,
    g.gross_price AS  gross_price_per_item,
    ROUND(s.sold_quantity * g.gross_price, 2) AS gross_price_total,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p
	ON s.product_code = p.product_code
JOIN dim_date d
	ON d.calendar_date = s.date
JOIN fact_gross_price g
	ON g.fiscal_year = d.fiscal_year
    AND g.product_code = s.product_code
JOIN fact_pre_invoice_deductions pre
ON 
	pre.customer_code = s.customer_code 
    AND pre.fiscal_year = d.fiscal_year
WHERE 
    d.fiscal_year = 2021
LIMIT 1000000;


-- By creating a new generated column in fact_sales_monthly table
EXPLAIN ANALYZE
SELECT 
	s.date, s.product_code,
    p.product, p.variant,
    s.sold_quantity,
    g.gross_price AS  gross_price_per_item,
    ROUND(s.sold_quantity * g.gross_price, 2) AS gross_price_total,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p
	ON s.product_code = p.product_code
JOIN fact_gross_price g
	ON g.fiscal_year = s.fiscal_year
    AND g.product_code = s.product_code
JOIN fact_pre_invoice_deductions pre
ON 
	pre.customer_code = s.customer_code 
    AND pre.fiscal_year = s.fiscal_year
WHERE 
    s.fiscal_year = 2021
LIMIT 1000000;

-- by creating CTE for the above query
WITH cte1 AS (
	SELECT 
		s.date, s.product_code,
		p.product, p.variant,
		s.sold_quantity,
		g.gross_price AS  gross_price_per_item,
		ROUND(s.sold_quantity * g.gross_price, 2) AS gross_price_total,
		pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
		ON s.product_code = p.product_code
	JOIN fact_gross_price g
		ON g.fiscal_year = s.fiscal_year
		AND g.product_code = s.product_code
	JOIN fact_pre_invoice_deductions pre
	ON 
		pre.customer_code = s.customer_code 
		AND pre.fiscal_year = s.fiscal_year
	WHERE 
		s.fiscal_year = 2021)
SELECT 
	*, 
    (gross_price_total - gross_price_total * pre_invoice_discount_pct) AS net_invoice_sales
FROM cte1;


-- By using VIEWS CONCEPT - it creats virtual table
SELECT
	*, 
	(gross_price_total - gross_price_total * pre_invoice_discount_pct) AS net_invoice_sales
FROM sales_pre_invoice_discount;

SELECT 
	*, 
	(1 - pre_invoice_discount_pct) * gross_price_total  AS net_invoice_sales
FROM sales_pre_invoice_discount;


SELECT 
	*, 
	(1 - s.pre_invoice_discount_pct) * s.gross_price_total  AS net_invoice_sales,
    (po.discounts_pct + po.other_deductions_pct) AS post_invoice_discount_pct
FROM sales_pre_invoice_discount s
JOIN fact_post_invoice_deductions po
	ON  s.date = po.date AND
		s.product_code = po.product_code AND
        s.customer_code = po.customer_code;

SELECT
	*,
    (1 - post_invoice_discount_pct) * net_invoice_sales  AS net_sales
FROM sales_post_invoice_discount;

/*
	Create a view for gross sales. It should have the following columns,
		-- date, fiscal_year, 
        -- customer_code, customer, 
        -- market, 
        -- product_code, product, variant,
		-- sold_quanity, 
        -- gross_price_per_item, 
        -- gross_price_total
*/
SELECT
	s.date, s.fiscal_year,
    s.customer_code,
    c.market,
    s.product_code, p.product, p.variant, 
    s.sold_quantity,
    gp.gross_price AS gross_price_item,
    ROUND((s.sold_quantity * gp.gross_price), 2) AS gross_price_total
FROM fact_sales_monthly s
JOIN dim_product p
	ON s.product_code = p.product_code AND
		s.customer_code = s.customer_code
JOIN dim_customer c
	ON s.customer_code = c.customer_code
JOIN fact_gross_price gp
	ON s.product_code = gp.product_code AND
		s.fiscal_year = gp.fiscal_year;

-- Top N Markets
SELECT 
	market,
    ROUND(SUM(net_sales)/1000000, 2) AS total_net_sales_mln
FROM net_sales_report
WHERE fiscal_year = 2021
GROUP BY market 
ORDER BY total_net_sales_mln DESC
LIMIT 5;

-- Top N Customers
SELECT 
	customer,
    ROUND(SUM(net_sales)/1000000, 2) AS total_net_sales_mln
FROM net_sales_report n
JOIN dim_customer c
	ON n.customer_code = c.customer_code
WHERE fiscal_year = 2021
GROUP BY c.customer 
ORDER BY total_net_sales_mln DESC
LIMIT 5;

/*
	Write a stored procedure to get the top n products by net sales for a given year. 
    Use product name without a variant.
*/
SELECT 
	product,
    ROUND(SUM(net_sales), 2) AS total_net_sales
FROM net_sales_report
WHERE fiscal_year = 2021
GROUP BY product
ORDER BY total_net_sales DESC
LIMIT 5;

