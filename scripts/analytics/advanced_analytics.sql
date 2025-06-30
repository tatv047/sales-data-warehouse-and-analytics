
/*Changes over time*/

-- High level insights on sales over the years
SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year

-- High level insights on sales over the months
SELECT
MONTH(order_date) AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY order_month

/*Cumulative Analysis*/

-- Calculate sales for each month and the running total of sales over time
SELECT 
order_date,
total_sales,
SUM(total_sales) OVER(PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM (
	SELECT
	DATETRUNC(MONTH,order_date) AS order_date,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales 
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH,order_date)
)t

SELECT 
order_date,
total_sales,
SUM(total_sales) OVER( ORDER BY order_date) AS running_total_sales,
avg_price,
AVG(avg_price) OVER(ORDER BY order_date) AS moving_average_price
FROM (
	SELECT
	DATETRUNC(YEAR,order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
	FROM gold.fact_sales 
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR,order_date)
)t

/*Performance Analysis*/
/* Comparing the current value to a target value */

-- Analyse the yearly performance of products by comparing the sales 
-- to both their average sales performance of the product and the previous year's sales
WITH yearly_product_sales AS (
SELECT
YEAR(s.order_date) AS order_year,
p.product_name,
SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
GROUP BY YEAR(s.order_date),p.product_name
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS average_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
	ELSE 'Avg'
END AS avg_change,
-- Year-Over-Year Analyses
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS pyr_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS diff_py,
CASE WHEN current_sales -LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Decrease'
	ELSE 'No change'
END AS py_change
FROM yearly_product_sales
ORDER BY product_name,order_year

/*Data Segmentation*/
/*Segment products into cost ranges and count how many products fall into each category*/
WITH product_segment AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products )

SELECT
cost_range,
COUNT(product_name) AS total_prodcuts
FROM product_segment
GROUP BY cost_range
ORDER BY total_prodcuts DESC


/* Group customers into three segments based on their spending behavior:
   - VIP: Customers with at least 12 months of history and spending more than €5,000.
   - Regular: Customers with at least 12 months of history but spending €5,000 or less.
   - New: Customers with a lifespan less than 12 months.
   And find the total number of customers by each group
*/
WITH customer_spending AS (
SELECT
c.customer_key,
SUM(s.sales_amount) AS total_spending,
MIN(s.order_date) AS first_order,
MAX(s.order_date) AS last_order,
DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) AS lifespan
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key)


SELECT 
customer_segments,
COUNT(DISTINCT customer_key) AS total_customers
FROM (
SELECT
customer_key,
total_spending,
lifespan,
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	ELSE 'New'
END AS customer_segments
FROM customer_spending)t
GROUP BY customer_segments
ORDER BY total_customers