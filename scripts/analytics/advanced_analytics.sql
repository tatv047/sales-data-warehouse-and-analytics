-- Analyze sales performance over time
SELECT
YEAR(order_date) order_year,
SUM(sales_amount) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) 
ORDER BY YEAR(order_date);



SELECT
MONTH(order_date) order_month,
SUM(sales_amount) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);



SELECT
YEAR(order_date) order_year,
MONTH(order_date) order_month,
SUM(sales_amount) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date);


SELECT
DATETRUNC(MONTH,order_date) order_date,
SUM(sales_amount) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date);


SELECT
FORMAT(order_date,'yyyy-MMMM') order_date,
SUM(sales_amount) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date,'yyyy-MMMM')
ORDER BY FORMAT(order_date,'yyyy-MMMM');

-- CUMULATIVE ANALYSIS

-- Calculate the total sales per month
-- and the running total of sales over time
SELECT
order_month,
sales_per_month,
SUM(sales_per_month) OVER(ORDER BY order_month) running_total_of_sales
FROM (
	SELECT
	DATETRUNC(MONTH,order_date) order_month,
	SUM(sales_amount) sales_per_month 
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH,order_date)
)t;

-- PERFORMANCE ANALYSIS
-- Analyse the yearLy performance of products by comparing each product's sales
-- to both its average sales performance and the previous year's sales.

WITH yearly_product_sales AS (
	SELECT
		YEAR(s.order_date) order_year,
		p.product_name,
		SUM(s.sales_amount) current_sales
	FROM 
		gold.fact_sales s
	LEFT JOIN 
		gold.dim_products p
	ON 
		s.product_key = p.product_key
	WHERE
		s.order_date IS NOT NULL
	GROUP BY 
		YEAR(s.order_date),
		p.product_name
)

SELECT
product_name,
order_year,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) average_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above avg'
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
	ELSE 'Avg'
END avg_change,
current_sales,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) last_year_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) yoy_diff,
CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'growth'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'decline'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) = 0 THEN 'no change'
	ELSE '-'
END yoy_change
FROM yearly_product_sales
ORDER BY product_name,order_year;

-- PART-TO-WHOLE ANALYSIS

-- Which categories contribute the most to overall Sales?
SELECT
p.category,
ROUND(CAST(SUM(s.sales_amount) AS FLOAT)*100/(SELECT SUM(sales_amount) FROM gold.fact_sales),2) sales_contribution
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.category;

-- or you can use CTEs
WITH category_sales AS (
	SELECT
	p.category,
	SUM(sales_amount) total_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
	GROUP BY p.category
)

SELECT
category,
total_sales,
SUM(total_sales) OVER() overall_sales,
CONCAT(ROUND(CAST(total_sales AS FLOAT)*100/SUM(total_sales) OVER(),2),'%') percenatge_of_total
FROM category_sales
ORDER BY total_sales DESC;


-- DATA SEGMENTATION

/* Segment products into cost ranges and  
 count how many products fall into each segment */
WITH product_segments AS (
SELECT
product_key, 
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
END cost_range
FROM gold.dim_products
)
SELECT
cost_range,
COUNT(product_key) total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;
								   
/* Group Customers into three segments based on their spending behaviour:
	- VIP: Customers with at least 12 months of history and spending more than €5000
	- Regular: Customers with at least 12 months of history but spending €5000 or less
	- New: Customers with a lifespan less than 12 months
And find the total numbers of customers by each group
*/
WITH customers_category AS (
SELECT
c.customer_key,
SUM(s.sales_amount) total_spending,
MIN(s.order_date) first_order,
MAX(s.order_date) last_order,
CASE WHEN DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) >= 12 AND SUM(s.sales_amount) > 5000 THEN 'VIP'
	WHEN DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) >= 12 AND SUM(s.sales_amount) <= 5000 THEN 'Regular'
	ELSE 'New'
END customer_type
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT
customer_type,
COUNT(customer_key) total_customers
FROM customers_category
GROUP BY customer_type
ORDER BY total_customers;

-- CUSTOMER REPORT
/*

*/