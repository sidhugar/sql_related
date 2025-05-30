#Finance Analytics

# Croma India product wise sales report for fiscal year 2021
SELECT * FROM gdb0041.dim_customer
where customer like "%croma%" and market = "India";

select 
	s.date, 
    s.product_code, 
    p.product, 
    p.variant, 
    s.sold_quantity, 
    g.gross_price, 
    round(g.gross_price*s.sold_quantity,2) as gross_price_total
from 
	fact_sales_monthly s
join 
	dim_product p
using 
	(product_code)
join 
	fact_gross_price g
on 
	g.product_code=s.product_code 
and 
	g.fiscal_year=get_fiscal_year(s.date)
where 
	customer_code= 90002002 
and 
	get_fiscal_year(date)=2021 
order by 
	date asc;

# Gross Sales Report: yearly Product Transactions for croma
select 
	g.fiscal_year, 
	concat(round(sum(g.gross_price*s.sold_quantity) /1000000, 2),'M') as gross_price_total
from 
	fact_sales_monthly s
join 
	fact_gross_price g
on 
	g.product_code=s.product_code 
and 
	g.fiscal_year=get_fiscal_year(s.date)
where 
	customer_code= 90002002
group by 
	g.fiscal_year
order by 
	g.fiscal_year asc;

# total quantity sold in india
SELECT 
	c.market, 
	sum(sold_quantity) as total_qty FROM fact_sales_monthly s
join 
	dim_customer c
on 
	s.customer_code=c.customer_code
where 
	get_fiscal_year(s.date)=2021 and c.market="India"
group by 
	c.market;


with cte1 as (select 
s.date, s.product_code, s.sold_quantity,
p.product, p.variant, g.gross_price, round(g.gross_price*s.sold_quantity,2) as gross_price_total,
pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p
using (product_code)
join fact_gross_price g
on g.product_code=s.product_code and g.fiscal_year=s.fiscal_year
join fact_pre_invoice_deductions pre
on pre.customer_code=s.customer_code and pre.fiscal_year=s.fiscal_year
where 
s.fiscal_year=2021)


select *, (1 - pre_invoice_discount_pct)*gross_price_total  as net_invoice_sales,
(po.discounts_pct+po.other_deductions_pct) as post_invoice_dicount_pct
from sales_preinv_discount s
join fact_post_invoice_deductions po
on s.date=po.date and 
s.product_code=po.product_code and 
s.customer_code= po.customer_code;

select *,
	(1- post_invoice_discount_pct)*net_invoice_sales as net_sales
from
	sales_postinv_discount;

select s.date, s.fiscal_year, s.customer_code, c.customer, c.market, s.product_code, p.product, p.variant, s.sold_quantity, 
g.gross_price as gross_price_per_item, s.sold_quantity*g.gross_price as gross_price_total
from fact_sales_monthly s	
join fact_gross_price g
on s.product_code=g.product_code
join dim_customer c
on s.customer_code=c.customer_code
join dim_product p
on s.product_code = p.product_code
and s.fiscal_year=g.fiscal_year;

select c.customer, round(sum(net_sales)/1000000,2) as net_sales_mln
from net_sales s
join dim_customer c
on s.customer_code=c.customer_code
where fiscal_year = 2021
group by c.customer
order by net_sales_mln desc
limit 5;

# top markets by net sales
select 
	market, 
	round(sum(net_sales)/1000000,2) as net_sales_mln
from 
	net_sales
where 
	fiscal_year = 2021
group by 
	market
order by 
	net_sales_mln desc
limit 5;

#top products by net sales
select 
	product, 
    round(sum(net_sales)/1000000,2) as net_sales_mln
from 
	net_sales
where 
	fiscal_year = 2021
group by 
	product
order by 
	net_sales_mln desc
limit 5;

#net sales global market share
with cte1 as (
	select 
		customer, 
		round(sum(net_sales)/1000000,2) as net_sales_mln
	from 
		net_sales s
	join 
		dim_customer c
	on 
		s.customer_code=c.customer_code
	where 
		fiscal_year = 2021
	group by 
		customer
)
	select 
		*, 
		net_sales_mln*100/ sum(net_sales_mln) over() as pct 
	from 
		cte1 
	order by 
		net_sales_mln desc;

# region wise % of netsales breakdown by customer
select 
	c.customer, 
	c.region, 
    n.net_sales*100/ sum(n.net_sales) 
    over( partition by region) as net_pct
from 
	net_sales n
join 
	dim_customer c
on 
	n.customer_code=c.customer_code
where 
	n.fiscal_year = 2021
group by 
	c.customer, 
    c.region
order by 
	net_pct desc ;

#  netsales and pct_share region  by customer
with cte1 as (
		select 
			c.customer,
			c.region,
			round(sum(net_sales)/1000000,2) as net_sales_mln
		from 
			gdb0041.net_sales n
		join 
			dim_customer c
		on 
			n.customer_code=c.customer_code
		where 
			fiscal_year=2021
		group by 
			c.customer, c.region)
	select
             *,
             net_sales_mln*100/sum(net_sales_mln) 
             over (partition by region) as pct_share_region
	from 
		cte1
	order by 
		region, 
        pct_share_region desc;

# top n products in each division by their quantity sold
with cte1 as (SELECT p.division,p.product, 
sum(sold_quantity) as total_qty
FROM fact_sales_monthly s
join dim_product p
on s.product_code=p.product_code
where fiscal_year=2021 
group by p.product),
cte2 as (select *,
	dense_rank() over(partition by division order by total_qty desc) as drnk
from cte1)
select * from cte2 
order by drnk;

#top 2 markets in every region by their gross sales amount in FY=2021
with cte1 as (select 
        	    n.market, c.region,
                    round(sum(net_sales)/1000000,2) as net_sales_mln
                from net_sales n
                join dim_customer c
                    on n.customer_code=c.customer_code
		where fiscal_year=2021
		group by c.market, c.region),
 cte2 as (select *, dense_rank() over(partition by region order by net_sales_mln desc) as dsrk
 from cte1)
 select * from cte2
 where dsrk <= 2;
  
#supplychain 
SET GLOBAL wait_timeout = 600; -- Set the wait_timeout to 10 minutes (600 seconds)
SET GLOBAL interactive_timeout = 600; -- Set the interactive_timeout to 10 minutes (600 seconds)

  
#create helper table to bring sold and forecast qty to a table
create table fact_act_est
	(
        	select 
                    s.date as date,
                    s.fiscal_year as fiscal_year,
                    s.product_code as product_code,
                    s.customer_code as customer_code,
                    s.sold_quantity as sold_quantity,
                    f.forecast_quantity as forecast_quantity
        	from 
                    fact_sales_monthly s
        	left join fact_forecast_monthly f 
        	using (date, customer_code, product_code)
	)
	union
	(
        	select 
                    f.date as date,
                    f.fiscal_year as fiscal_year,
                    f.product_code as product_code,
                    f.customer_code as customer_code,
                    s.sold_quantity as sold_quantity,
                    f.forecast_quantity as forecast_quantity
        	from 
		    fact_forecast_monthly  f
        	left join fact_sales_monthly s 
        	using (date, customer_code, product_code)
	);
    SET SQL_SAFE_UPDATES = 0;

   update fact_act_est
	set sold_quantity = 0
	where sold_quantity is null;

	update fact_act_est
	set forecast_quantity = 0
	where forecast_quantity is null; 
    
    
    with forecast_err_table as (
             select
                  s.customer_code as customer_code,
                  c.customer as customer_name,
                  c.market as market,
                  sum(s.sold_quantity) as total_sold_qty,
                  sum(s.forecast_quantity) as total_forecast_qty,
                  sum(s.forecast_quantity-s.sold_quantity) as net_error,
                  round(sum(s.forecast_quantity-s.sold_quantity)*100/sum(s.forecast_quantity),1) as net_error_pct,
                  sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_error,
                  round(sum(abs(s.forecast_quantity-sold_quantity))*100/sum(s.forecast_quantity),2) as abs_error_pct
             from fact_act_est s
             join dim_customer c
             on s.customer_code = c.customer_code
             where s.fiscal_year=2021
             group by customer_code
	)
	select 
            *,
            if (abs_error_pct > 100, 0, 100.0 - abs_error_pct) as forecast_accuracy
	from forecast_err_table
        order by forecast_accuracy desc;
        
        
# step 1: Get forecast accuracy of FY 2021 and store that in a temporary table
drop table if exists forecast_accuracy_2021;
create temporary table forecast_accuracy_2021
with forecast_err_table as (
        select
                s.customer_code as customer_code,
                c.customer as customer_name,
                c.market as market,
                sum(s.sold_quantity) as total_sold_qty,
                sum(s.forecast_quantity) as total_forecast_qty,
                sum(s.forecast_quantity-s.sold_quantity) as net_error,
                round(sum(s.forecast_quantity-s.sold_quantity)*100/sum(s.forecast_quantity),1) as net_error_pct,
                sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_error,
                round(sum(abs(s.forecast_quantity-sold_quantity))*100/sum(s.forecast_quantity),2) as abs_error_pct
        from fact_act_est s
        join dim_customer c
        on s.customer_code = c.customer_code
        where s.fiscal_year=2021
        group by customer_code
)
select 
        *,
    if (abs_error_pct > 100, 0, 100.0 - abs_error_pct) as forecast_accuracy
from 
	forecast_err_table
order by forecast_accuracy desc;

# step 2: Get forecast accuracy of FY 2020 and store that also in a temporary table
drop table if exists forecast_accuracy_2020;
create temporary table forecast_accuracy_2020
with forecast_err_table as (
        select
                s.customer_code as customer_code,
                c.customer as customer_name,
                c.market as market,
                sum(s.sold_quantity) as total_sold_qty,
                sum(s.forecast_quantity) as total_forecast_qty,
                sum(s.forecast_quantity-s.sold_quantity) as net_error,
                round(sum(s.forecast_quantity-s.sold_quantity)*100/sum(s.forecast_quantity),1) as net_error_pct,
                sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_error,
                round(sum(abs(s.forecast_quantity-sold_quantity))*100/sum(s.forecast_quantity),2) as abs_error_pct
        from fact_act_est s
        join dim_customer c
        on s.customer_code = c.customer_code
        where s.fiscal_year=2020
        group by customer_code
)
select 
        *,
    if (abs_error_pct > 100, 0, 100.0 - abs_error_pct) as forecast_accuracy
from 
	forecast_err_table
order by forecast_accuracy desc;

-- step 3: Join forecast accuracy tables for 2020 and 2021 using a customer_code
select 
	f_2020.customer_code,
	f_2020.customer_name,
	f_2020.market,
	f_2020.forecast_accuracy as forecast_acc_2020,
	f_2021.forecast_accuracy as forecast_acc_2021
from forecast_accuracy_2020 f_2020
join forecast_accuracy_2021 f_2021
on f_2020.customer_code = f_2021.customer_code 
where f_2021.forecast_accuracy < f_2020.forecast_accuracy
order by forecast_acc_2020 desc;
























