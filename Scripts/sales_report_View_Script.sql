/*----------------------------------------------------------------------------------------------------------------------
		-- 5. SALES REPORT
		-- Answer the question:
		-- How is the business performing over time?
--------------------------------------------------------------

		SALES METRIC                 MEANING
		order_month                  Month of analysis
		total_sales                  Revenue generated
		total_profit                 Profit generated
		total_orders                 Number of orders
		total_customers              Number of customers
		running_total_sales          Cumulative sales
		running_total_profit         Cumulative profit
		moving_avg_sales             3-month average sales
		moving_avg_profit            3-month average profit
		moving_avg_orders            3-month average orders
		moving_avg_customers         3-month average customers

-----------------------------------------------------------------------------*/
		-- SALES REPORT
WITH sales_report AS 
(
SELECT
	DATE_FORMAT(order_date,'%Y-%m') AS order_month,
	ROUND(SUM(sales),2) As total_sales,
	ROUND(SUM(profit),2) As total_profit,
	COUNT(DISTINCT order_id) As total_orders,
	COUNT(DISTINCT customer_id) As total_customers
FROM superstore_sales
GROUP BY order_month )

SELECT
	order_month,
	total_sales,
	total_profit,
	total_orders,
	total_customers,
    ROUND(SUM(total_sales) OVER(ORDER BY order_month),2) AS running_total_sales,
    ROUND(SUM(total_profit) OVER(ORDER BY order_month),2) AS running_total_profit,
    CASE
		WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN ROUND(AVG(total_sales) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
		ELSE NULL
END AS moving_avg_sales,
	CASE
		WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN ROUND(AVG(total_profit) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
		ELSE NULL
END AS moving_avg_profit,
	CASE
		WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN ROUND(AVG(total_orders) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
		ELSE NULL
END AS moving_avg_orders,
	CASE
		WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN ROUND(AVG(total_customers) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
		ELSE NULL
END AS moving_avg_customers
FROM sales_report
ORDER BY order_month
;

/*--------------------------------------------------------------------------------------------------------------------*/

-- report_sales_View
CREATE VIEW superstore_db_copy.Report_Sales AS
	WITH sales_report AS 
	(
	SELECT
		DATE_FORMAT(order_date,'%Y-%m') AS order_month,
		ROUND(SUM(sales),2) As total_sales,
		ROUND(SUM(profit),2) As total_profit,
		COUNT(DISTINCT order_id) As total_orders,
		COUNT(DISTINCT customer_id) As total_customers
	FROM superstore_sales
	GROUP BY order_month )

	SELECT
		order_month,
		total_sales,
		total_profit,
		total_orders,
		total_customers,
		ROUND(SUM(total_sales) OVER(ORDER BY order_month),2) AS running_total_sales,
		ROUND(SUM(total_profit) OVER(ORDER BY order_month),2) AS running_total_profit,
		CASE
			WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN ROUND(AVG(total_sales) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
			ELSE NULL
	END AS moving_avg_sales,
		CASE
			WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN ROUND(AVG(total_profit) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
			ELSE NULL
	END AS moving_avg_profit,
		CASE
			WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN ROUND(AVG(total_orders) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
			ELSE NULL
	END AS moving_avg_orders,
		CASE
			WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN ROUND(AVG(total_customers) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
			ELSE NULL
	END AS moving_avg_customers
	FROM sales_report
	ORDER BY order_month
;