/*-----------------------------------------------------------------------------------------------------------------------
			-- 1. KPI REPORT ( answers the question how the business is performing overall)
			KPI CATEGORY        KPI
			Revenue           Total Sales
			Revenue           Average Order Value
			Profitability     Total Profit
			Profitability     Profit Margin %
			Orders            Total Orders
			Orders            Total Quantity Sold
			Customers         Total Customers
			Customers         Average Revenue Per Customer
			Products          Total Products
/*----------------------------------------------------------------------------------------------------------------------*/
		-- KPI REPORT 
SELECT
	ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id),2)AS Avg_Order_Value,
    ROUND(SUM(profit) / SUM(sales)*100,2)AS profit_margin,
    SUM(quantity) As total_qt_sold,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT customer_id),2) AS Avg_revenue_per_customer,
    COUNT(DISTINCT product_id) As total_product
FROM superstore_sales;

/*----------------------------------------------------------------------------------------------------------------------*/
-- report_KPI_View
CREATE VIEW superstore_db_copy.Report_KPI AS
	SELECT
		ROUND(SUM(sales),2) AS total_sales,
		ROUND(SUM(profit),2) AS total_profit,
		COUNT(DISTINCT order_id) AS total_orders,
		ROUND(SUM(sales) / COUNT(DISTINCT order_id),2)AS Avg_Order_Value,
		ROUND(SUM(profit) / SUM(sales)*100,2)AS profit_margin,
		SUM(quantity) As total_qt_sold,
		COUNT(DISTINCT customer_id) AS total_customers,
		ROUND(SUM(sales) / COUNT(DISTINCT customer_id),2) AS Avg_revenue_per_customer,
		COUNT(DISTINCT product_id) As total_product
	FROM superstore_sales
;

