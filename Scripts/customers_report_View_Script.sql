/*----------------------------------------------------------------------------------------------------------------------*/
		-- 2. CUSTOMER REPORT
		-- Answer the question:
		-- Who are our customers, how valuable are they, and how do they behave?
/*-------------------------------------------------------------------------------------------------

CUSTOMER METRIC              MEANING
customer_id                  Unique customer
customer_name                Customer full name
total_orders                 Number of orders placed
total_sales                  Revenue from customer
total_profit                 Profit from customer
total_quantity               Items purchased
first_order_date             First purchase date
last_order_date              Most recent purchase date
customer_lifespan_months     Time between first and last order
customer_segment             VIP, Regular, or New

------------------------------------------------------------*/
-- CUSTOMER REPORT
SELECT
	customer_id,
	customer_name,
	COUNT(DISTINCT order_id) AS total_orders,
	ROUND(SUM(sales),2)AS total_sales,
	ROUND(SUM(profit),2)AS total_profit,
	SUM(quantity) AS total_quantity,
	MIN(order_date) AS first_purchased_date,
	MAX(order_date) AS last_purchased_date,
	TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) AS customer_lifespan_months,
	CASE
		WHEN TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) > 12 AND SUM(sales) >= 5000 THEN 'VIP'
		WHEN TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) > 12 AND SUM(sales) < 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment
FROM superstore_sales
GROUP BY customer_id,customer_name
ORDER BY customer_lifespan_months DESC
;

/*--------------------------------------------------------------------------------------------------------------------*/
-- report_customers_View
CREATE VIEW superstore_db_copy.Report_Customers AS
	SELECT
		customer_id,
		customer_name,
		COUNT(DISTINCT order_id) AS total_orders,
		ROUND(SUM(sales),2)AS total_sales,
		ROUND(SUM(profit),2)AS total_profit,
		SUM(quantity) AS total_quantity,
		MIN(order_date) AS first_purchased_date,
		MAX(order_date) AS last_purchased_date,
		TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) AS customer_lifespan_months,
		CASE
			WHEN TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) > 12 AND SUM(sales) >= 5000 THEN 'VIP'
			WHEN TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) > 12 AND SUM(sales) < 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_segment
	FROM superstore_sales
	GROUP BY customer_id,customer_name
	ORDER BY customer_lifespan_months DESC
;