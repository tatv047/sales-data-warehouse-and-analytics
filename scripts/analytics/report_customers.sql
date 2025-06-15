/*
==============================================================
CUSTOMER REPORT
==============================================================
Purpose:
	This report consolidates key cutsomer metrics and behaviors
Highlights:
	1. Gathers essential fields such as names,ages and transaction details.
	2. Segments customers into categories (VIP,Regualr,New) and age groups
	3. Aggregate customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend

===============================================================
*/
CREATE VIEW gold.report_customers AS 

WITH base_query AS (
/* 
1. Base query: retrieves core columns from the table. 
*/
	SELECT
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name,' ',c.last_name) customer_name,
		DATEDIFF(YEAR,c.birthdate,GETDATE()) age
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
	WHERE s.order_date IS NOT NULL
),
customer_aggregation AS (
/* 
1. Customer Aggregations: Summarises key metrics at the customer level. 
*/
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(order_number) total_orders,
		SUM(sales_amount) total_sales,
		SUM(quantity) total_quantity,
		COUNT(DISTINCT product_key) total_products,
		MAX(order_date) last_order,
		DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) lifespan
	FROM base_query
	GROUP BY
		customer_key,
		customer_number,
		customer_name,
		age
)

SELECT
	customer_key,
	customer_number,
	customer_name,	
	CASE WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END age_group,
	CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_segment,
	last_order,
	DATEDIFF(MONTH,last_order,GETDATE()) recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- Compute average order value (AVO)
	CASE WHEN total_orders = 0 THEN 0
		ELSE ROUND(CAST(total_sales AS FLOAT)/total_orders,2)
	END avg_order_value,
	-- Compute averge monthly spend
	CASE WHEN lifespan = 0 THEN total_sales
		ELSE ROUND(CAST(total_sales AS FLOAT)/lifespan,2)
	END avg_monthly_spend
FROM customer_aggregation;



