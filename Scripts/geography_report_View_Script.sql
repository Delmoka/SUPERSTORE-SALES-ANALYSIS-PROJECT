/*----------------------------------------------------------------------------------------------------------------------           
		-- 4. GEOGRAPHY REPORT
		-- Answer the question:
		-- Where is the business performing best and worst?
		------------------------------------------------------------

		GEOGRAPHY METRIC             MEANING
		region                       Geographic region
		state                        State
		city                         City
		total_sales                  Revenue generated
		total_profit                 Profit generated
		total_orders                 Number of orders
		total_customers              Number of customers
		total_quantity               Units sold
		profit_margin_pct            Profitability percentage
		geography_performance        High, Mid-Range, or Low Performance

		------------------------------------------------------------*/
		-- GEOGRAPHY REPORT

WITH geography_report AS
(
	SELECT
		region,
		state,
		city,
		ROUND(SUM(sales),2) AS total_sales,
		ROUND(SUM(profit),2) AS total_profit,
		COUNT(DISTINCT order_id) AS total_orders,
		COUNT(DISTINCT customer_id) AS total_customers,
		SUM(quantity) AS total_quantity,
		ROUND(SUM(profit) / SUM(sales) *100,2) AS profit_margin_pct,
		ROUND(AVG(SUM(sales))OVER(),2) AS avg_sales
	FROM superstore_sales
	GROUP BY region, state, city )

	SELECT
			region,
			state,
			city,
			total_sales,
			total_profit,
			total_orders,
			total_customers,
			total_quantity,
			profit_margin_pct,
			avg_sales,
			CASE
				WHEN total_sales > avg_sales THEN 'High Performance'
				WHEN total_sales < avg_sales THEN 'Low Performance'
				ELSE 'Mid-Range'
			END AS geography_performance
	FROM geography_report
    ORDER BY total_sales DESC
;

/*--------------------------------------------------------------------------------------------------------------------*/

-- report_geography_View
CREATE VIEW superstore_db_copy.Report_Geography AS
	WITH geography_report AS
	(
		SELECT
			region,
			state,
			city,
			ROUND(SUM(sales),2) AS total_sales,
			ROUND(SUM(profit),2) AS total_profit,
			COUNT(DISTINCT order_id) AS total_orders,
			COUNT(DISTINCT customer_id) AS total_customers,
			SUM(quantity) AS total_quantity,
			ROUND(SUM(profit) / SUM(sales) *100,2) AS profit_margin_pct,
			ROUND(AVG(SUM(sales))OVER(),2) AS avg_sales
		FROM superstore_sales
		GROUP BY region, state, city )

		SELECT
				region,
				state,
				city,
				total_sales,
				total_profit,
				total_orders,
				total_customers,
				total_quantity,
				profit_margin_pct,
				avg_sales,
				CASE
					WHEN total_sales > avg_sales THEN 'High Performance'
					WHEN total_sales < avg_sales THEN 'Low Performance'
					ELSE 'Mid-Range'
				END AS geography_performance
		FROM geography_report
		ORDER BY total_sales DESC
;
