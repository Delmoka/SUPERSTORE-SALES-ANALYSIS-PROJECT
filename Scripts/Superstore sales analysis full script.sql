/*==================================
SUPERSTORE SALES ANALYSIS PROJECT 
====================================
	THIS PROJECT CONTAINS 3 PHASES 
		- EDA
        - ADVANCE ANALYTICS
        - REPORTING
-------------------------------------------------------------------------------------------------------------------
PROJECT OBJECTIVE
	Analyze Superstore sales data to uncover trends, identify top and bottom-performing products.
    Understand customer purchasing behavior, measure business performance over time, 
    and generate actionable insights that support data-driven decision-making.
----------------------------------------------------------------------------------------------------
============================================================================
PHASE 1: EXPLORATORY DATA ANALYSIS (EDA)
	GOAL: Understand the dataset, validate data quality, 
		explore business entities, 
        identify key metrics, 
        and uncover patterns before performing advanced analytics.
==========================================================================

STEP 1 : DATABASE EXPLORATION & DATA UNDERSTANDING
	GOAL: Understand our database structure, what data do we have and what business questions can it help us answer */
    
    /*-----------------
    THE STEPS TO COVER 
    --------------------
    STEP 1: Explore the dabase structure ( find out the tables you have in your database )
    */
    
    USE superstore_db_copy;
    
    SHOW tables;
    -- this shows the tables you have in your database . ( in our db we have one table = superstore_sales)
    
/* STEP 2 : Explore the columns of each table */
		SHOW COLUMNS 
		FROM superstore_sales;
		-- This show that we have 21 columns in our table and it shows the columns data types . those that contain date, sales metrics and IDs
    
/* STEPS 3: Preview the Data */
		SELECT*
		FROM superstore_sales
		LIMIT 10;
        -- This shows the columns and rows informations . each column contain an information about each transaction which is defined by a row ID. the row ID is the unique ID that identify each transaction.
        
/* STEP 4: Count Records */
		SELECT
			COUNT(*)AS total_rows
        FROM superstore_sales;
        -- This shows the number of transaction we have in our table ( 10194)
    
/* STEP 5: Identify primary Keys */
		SELECT
			COUNT(*) AS total_record,
			COUNT(DISTINCT order_id) AS total_order_id,
			COUNT(DISTINCT row_id) As total_row_id
        FROM superstore_sales;
        -- total_row_id = total_record , which means that each row_id identify a unique record which makes it a Primary Key in our data . it is also called a unique key 
        
/* STEP 6: Check Date range*/ 
		SELECT
			TIMESTAMPDIFF (YEAR, first_order_date, last_order_date) AS sales_period
		FROM
        (
        SELECT
			MIN(order_date)AS first_order_date,
			MAX(order_date)AS last_order_date
        FROM superstore_sales) AS t
        ;
        -- The date range gives us the analysis period or the time lapse between the first and last transcation ( in our project, it is 3 years )
        
/* STEP 7: Understand Business Metrics ( the measurable values of our data that gives us information about the business financial performance) 
	- sales metrics 
    - profit metrics
	- quantity metrics
    - discount metrics */
    
		/* SALES METRICS */
			SELECT
				ROUND(MIN( sales),2) as min_sales_amount,
				ROUND(MAX( sales),2) as max_sales_amount,
                ROUND(AVG( sales),2) as avg_sales_amount
            FROM superstore_sales;
	-- this provides us with the lowest and highest sale in our dataset 
    
		/* PROFIT METRICS */
			SELECT
				ROUND(MIN(profit),2) as min_profit,
				ROUND(MAX(profit),2) as max_profit,
                ROUND(AVG(profit),2) as avg_profit
            FROM superstore_sales;

		/* QUANTITY METRICS */
			SELECT
				ROUND(MIN(quantity),0) as min_qdt_sold,
				ROUND(MAX(quantity),0) as max_qdt_sold,
                ROUND(AVG(quantity),0) as avg_qdt_sold
            FROM superstore_sales;
            
		/* DISCOUNT METRICS */
			SELECT
				ROUND(MIN(discount),2) as min_discount_applied,
				ROUND(MAX(discount),2) as max_discount_applied,
                ROUND(AVG(discount),2) as avg_discount_applied
            FROM superstore_sales;	
		-- Those business metrics provide us with insights about the lowest, average and highest amount in sales, profit, quantity sold and amount of discount applied 
        
/* STEP 8: Missing Values 
	For each important column, find out if there are any missing values */
    
-- Using the cased when statement. 
SELECT
    SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) AS missing_row_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS missing_customer_name,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS missing_ship_date,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS missing_profit,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS missing_discount
FROM superstore_sales;

/* STEP 9: Check for Duplicate Records  */

		SELECT
			row_id,
			COUNT(row_id) AS id_total
		FROM superstore_sales
		GROUP BY row_id
		HAVING COUNT(row_id) > 1;
 
-- TABLE GRAIN ANALYSIS ( what does each row represent) 

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(order_id) As total_orders2
FROM superstore_sales;

	-- The superstore_sales table contains 10,194 rows and 5,111 unique orders.
	-- The table grain is one product line item per order.
	-- A single order may contain multiple products, causing the same order_id to appear in multiple rows.
	-- Therefore:
		-- - row_id is unique
		--  - order_id is not unique
		--  - customer_id is not unique
		--  - product_id is not unique
-- This behavior is expected and reflects the business process of customers purchasing multiple products in a single order.	
/*-------------------------------------------------------------------------------------------------------------------------*/
/* STEP 10: CREATE A DATA DISCTIONARY 

		COLUMNS    &     MEANING

		Order ID    =   Unique order number

		Order Date  =   Date order was placed

		Customer ID =   Customer identifier

		Product ID  =   Product identifier

		Sales       =    Revenue generated

		Profit      =    Profit earned

		Quantity    =    Units sold

		Discount    =    Discount applied */
        
/*===============================================================================
STEP 2 : DIMENSION EXPLORATION
		GOAL : Understand the business dimensions ( who, what, when and where) before analyzing sales and profit.
			   That helps us group our data to get more insight
=================================================================================
		OUR DIMENSIONS IN THE DATASET 
			Customers
			Products
			Geopraphy
			Time
			Shipping 
---------------------------------------------------------------------------------

CUSTOMER DIEMENSION EXPLORATION
	Purpose: explore customer dimenison to know customers numbers and customer segments available
=================================*/
SELECT*
FROM superstore_sales;

-- Find out the total customers available in our data 
SELECT
	COUNT(DISTINCT customer_id) AS total_customer
FROM superstore_sales;

-- Find out the availabale customer segments available 
SELECT
	segment,
	COUNT(DISTINCT customer_id) As total_customer_by_segment
FROM superstore_sales
GROUP BY segment
ORDER BY COUNT(DISTINCT customer_id) DESC ;

/*-----------------------------------------
PRODUCT DIMENSION EXPLORATION
	Purpose : to find out total product we have available, the categories and sub categories available
==========================================*/

-- Find out the total product available
SELECT
COUNT(DISTINCT product_id) As total_product
FROM superstore_sales;

-- Find out the product categories available and their totals 
SELECT
category,
COUNT(DISTINCT product_id) As product
FROM superstore_sales
GROUP BY
	category
ORDER BY product DESC;

-- Find out the sub_category of products available and their totals 
SELECT
    sub_category,
    COUNT(DISTINCT product_id) AS products
FROM superstore_sales
GROUP BY sub_category
ORDER BY products DESC;

/*--------------------------------------------------------------------------------
GEOGRAPHIC DIMENSION EXPLORATION
	Purpose: Find out the number of country and states we have in each country ; regions and states we have in those regions and cities by region  we have 
===========================================================================*/

-- regions available 
SELECT
	DISTINCT region
FROM superstore_sales;

-- States by region
SELECT
	region,
	COUNT(DISTINCT state) As state
FROM superstore_sales
GROUP BY region
ORDER BY state DESC;

-- Cities by region
SELECT
	region,
	COUNT(DISTINCT city) As cities
FROM superstore_sales
GROUP BY region 
ORDER BY cities DESC;

-- countries available
SELECT
	DISTINCT country
FROM superstore_sales;

-- States by country
SELECT
	country,
	COUNT(DISTINCT state) As state
FROM superstore_sales
GROUP BY country
ORDER BY state DESC;

-- Cities by country
SELECT
	country,
	COUNT(DISTINCT city) As cities
FROM superstore_sales
GROUP BY country 
ORDER BY cities DESC;

/*-----------------------------------------
TIME DIMENSION EXPLORATION
	Purpose : Find out the business period covered in our analysis ( years and months )
==========================================*/

-- Years covered 
SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	TIMESTAMPDIFF(YEAR, MIN(order_date) , MAX(order_date)) AS years_covered
FROM superstore_sales;

-- Months covered 
SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	TIMESTAMPDIFF(MONTH, MIN(order_date) , MAX(order_date)) AS months_covered
FROM superstore_sales;

/*-----------------------------------------
SHIPPING DIMENSION EXPLORATION
	Purpose : Find out the different methods of shipping available for our business
==========================================*/

-- Shipping methods available 
SELECT
	DISTINCT ship_mode
FROM superstore_sales;

        
/*===============================================================================
STEP 3 : DATE EXPLORATION
		GOAL : Understand the period covered in the business in months and years 
=================================================================================*/

-- first and last order, business period covered  
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(YEAR, MIN(order_date), MAX(order_date)) AS years_covered,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS months_covered
FROM superstore_sales;

-- Years available 
SELECT 
DISTINCT YEAR(order_date) As order_year
FROM superstore_sales
ORDER BY order_year ASC;

/*===============================================================================
STEP 4:MEASURE EXPLORATION
		GOAL : Understand the numerical measures or values  available in the dataset before analysis 
			SALES ( revenue generated)
            PROFIT ( profit earned)
            QUANTITY (units sold)
            DISCOUNT (discount applied)
=================================================================================*/

/*SALES*/
SELECT
	ROUND(SUM(sales),2) As total_sale,
	ROUND(MIN(sales),2) AS lowest_sale,
	ROUND(MAX(sales),2) AS highest_sale,
	ROUND(AVG(sales),2) As avg_sale
FROM superstore_sales;

/*PROFIT*/
SELECT
	ROUND(SUM(profit),2) As total_profit,
	ROUND(MIN(profit),2) AS lowest_profit,
	ROUND(MAX(profit),2) AS highest_profit,
	ROUND(AVG(profit),2) As avg_profit
FROM superstore_sales;

/*QUANTITY*/
SELECT
	ROUND(SUM(quantity),0) As total_qdt_sold,
	ROUND(MIN(quantity),0) AS lowest_qdt_sold,
	ROUND(MAX(quantity),0) AS highest_qdt_sold,
	ROUND(AVG(quantity),0) As avg_qdt_sold
FROM superstore_sales;

/*DISCOUNT*/
SELECT
	ROUND(SUM(discount),2) As total_discount,
	ROUND(MIN(discount),2) AS lowest_discount,
	ROUND(MAX(discount),2) AS highest_discount,
	ROUND(AVG(discount),2) As avg_discount
FROM superstore_sales;

/*===============================================================================
STEP 5:KEY METRICS REPORT
		GOAL : provide a high-level snapshot of the business performance
			TOTAL SALES 
            TOTAL PROFIT
            TOTAL ORDERS
            TOTAL CUSTOMERS
            TOTAL PRODUCTS
            TOTAL QUANTITY (units sold)
            AVERAGE ORDER VALUE 
            AVERAGE SELLING PRICE
            TOTAL DISCOUNT (discount applied)
=================================================================================*/

-- Metrics Report ( the snapshot of the business performance)
SELECT
	ROUND(SUM(sales),2) AS total_sale,
	ROUND(SUM(profit),2) AS total_profit,
	COUNT(DISTINCT order_id) AS total_order,
	COUNT(DISTINCT customer_id) AS total_customer,
	COUNT(DISTINCT product_id) AS total_product,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(profit) / SUM(sales)*100,2) AS profit_margin,
	ROUND(AVG(discount)*100,2) AS Avg_discount_applied,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id),2) AS average_Order_Value,
    ROUND(SUM(sales) / SUM(quantity),2) AS Average_selling_price
FROM superstore_sales
;

/*==============================================================================
STEP 6:MAGNITUDE ANALYSIS
		GOAL : Goal: Analyze the contribution of different business dimensions (Region, Category, Product, Customer Segment, etc.) 
			         to understand which groups drive the most and least business performance.
===================================================================================

1. Sales Contribution Analysis
   - Sales by Region
   - Sales by Category
   - Sales by Sub-Category
   - Sales by Product
   - Sales by Customer Segment

2. Profit Contribution Analysis
   - Profit by Region
   - Profit by Category
   - Profit by Sub-Category
   - Profit by Product
   - Profit by Customer Segment

3. Quantity Contribution Analysis
   - Quantity by Region
   - Quantity by Category
   - Quantity by Sub-Category
   - Quantity by Product

4. Order Contribution Analysis
   - Orders by Region
   - Orders by Category
   - Orders by Customer Segment
=================================================================================*/

/*SALES CONTRIBUTION ANALYSIS */

	-- Sales by region
SELECT
	region,
	ROUND(SUM(sales),0) AS sales
FROM superstore_sales
GROUP BY region
ORDER BY sales DESC;

-- Sales by category
SELECT
	category,
	ROUND(SUM(sales),0) AS sales
FROM superstore_sales
GROUP BY category
ORDER BY sales DESC;

-- Sales by sub_category
SELECT
	sub_category,
	ROUND(SUM(sales),0) AS sales
FROM superstore_sales
GROUP BY sub_category
ORDER BY sales DESC;

-- sales by product
SELECT
	product_name,
	ROUND(SUM(sales),0) AS sales
FROM superstore_sales
GROUP BY product_name
ORDER BY sales DESC;

-- Sales by customer segment 
SELECT
	segment,
	ROUND(SUM(sales),0) AS sales
FROM superstore_sales
GROUP BY segment
ORDER BY sales DESC;

/*PROFIT CONTRIBUTION ANALYSIS */

	-- Profit by region
SELECT
	region,
	ROUND(SUM(Profit),0) AS profit
FROM superstore_sales
GROUP BY region
ORDER BY profit DESC;

-- Profit by category
SELECT
	category,
	ROUND(SUM(Profit),0) AS Profit
FROM superstore_sales
GROUP BY category
ORDER BY Profit DESC;

-- Profit by sub_category
SELECT
	sub_category,
	ROUND(SUM(Profit),0) AS Profit
FROM superstore_sales
GROUP BY sub_category
ORDER BY Profit DESC;

-- Profit by product
SELECT
	product_name,
	ROUND(SUM(Profit),0) AS Profit
FROM superstore_sales
GROUP BY product_name
ORDER BY Profit DESC;

-- Profit by customer segment 
SELECT
	segment,
	ROUND(SUM(Profit),0) AS Profit
FROM superstore_sales
GROUP BY segment
ORDER BY Profit DESC;


/*QUANTITY CONTRIBUTION ANALYSIS*/

	-- Quantity by region
SELECT
	region,
	ROUND(SUM(Quantity),0) AS Quantity
FROM superstore_sales
GROUP BY region
ORDER BY Quantity DESC;

-- Quantity by category
SELECT
	category,
	ROUND(SUM(Quantity),0) AS Quantity
FROM superstore_sales
GROUP BY category
ORDER BY Quantity DESC;

-- Quantity by sub_category
SELECT
	sub_category,
	ROUND(SUM(Quantity),0) AS Quantity
FROM superstore_sales
GROUP BY sub_category
ORDER BY Quantity DESC;

-- Quantity by product
SELECT
	product_name,
	ROUND(SUM(Quantity),0) AS Quantity
FROM superstore_sales
GROUP BY product_name
ORDER BY Quantity DESC;

/*ORDER CONTRIBUTION ANALYSIS*/

-- Order by region
SELECT
	region,
	ROUND(COUNT(DISTINCT order_id),0) AS Orders
FROM superstore_sales
GROUP BY region
ORDER BY Orders DESC;

-- Order by category
SELECT
	category,
	ROUND(COUNT(DISTINCT order_id),0) AS Orders
FROM superstore_sales
GROUP BY category
ORDER BY Orders DESC;

-- Order by customer segment 
SELECT
	segment,
	ROUND(COUNT(DISTINCT order_id),0) AS Orders
FROM superstore_sales
GROUP BY segment
ORDER BY Orders DESC;

/*============================================================
STEP 7: RANKING ANALYSIS
		Goal:Rank business entities based on their performance to identify
		     top and bottom performers across key business metrics.
=============================================================

Product Ranking
- Top 10 Products by Sales
- Bottom 10 Products by Sales
- Top 10 Products by Profit
- Bottom 10 Products by Profit

Customer Ranking
- Top 10 Customers by Sales
- Top 10 Customers by Profit
- Top 10 Customers by Orders

State Ranking
- Top 10 States by Sales
- Top 10 States by Profit

Category Ranking
- Categories Ranked by Sales
- Categories Ranked by Profit

Sub-Category Ranking
- Sub-Categories Ranked by Sales
- Sub-Categories Ranked by Profit
===========================================================================*/

/*Product Ranking*/

-- Top 10 Products by Sales
SELECT
	 product_name,
     ROUND(SUM(sales),2) AS sales
FROM superstore_sales
GROUP BY product_name
ORDER BY sales DESC
LIMIT 10 ;

-- Bottom 10 Products by Sales
SELECT
	 product_name,
     ROUND(SUM(sales),2) AS sales
FROM superstore_sales
GROUP BY product_name
ORDER BY sales ASC
LIMIT 10 ;

-- Top 10 Products by Profit
SELECT
	 product_name,
     ROUND(SUM(Profit),2) AS Profit
FROM superstore_sales
GROUP BY product_name
ORDER BY Profit DESC
LIMIT 10 ;

-- Bottom 10 Products by Profit
SELECT
	 product_name,
     ROUND(SUM(Profit),2) AS Profit
FROM superstore_sales
GROUP BY product_name
ORDER BY Profit ASC
LIMIT 10 ;


/* Customer Ranking */

-- Top 10 Customers by Sales
SELECT
	customer_name,
	ROUND(SUM(sales),2) AS sales
FROM superstore_sales
GROUP BY customer_name
ORDER BY sales DESC
LIMIT 10;

-- Top 10 Customers by Profit
SELECT
	customer_name,
	ROUND(SUM(profit),2) AS profit
FROM superstore_sales
GROUP BY customer_name
ORDER BY profit DESC
LIMIT 10;

-- Bottom 10 Customers by Profit
SELECT
	customer_name,
	ROUND(SUM(profit),2) AS profit
FROM superstore_sales
GROUP BY customer_name
ORDER BY profit ASC
LIMIT 10;

-- Top 10 Customers by Orders
SELECT
	customer_name,
	ROUND(COUNT(DISTINCT order_id),0) AS Orders
FROM superstore_sales
GROUP BY customer_name
ORDER BY Orders DESC
LIMIT 10;

/* State Ranking */

-- Top 10 States by Sales
SELECT
	state,
	ROUND(SUM(sales),2) AS sales
FROM superstore_sales
GROUP BY state
ORDER BY sales DESC
LIMIT 10;

-- Bottom 10 States by Sales
SELECT
	state,
	ROUND(SUM(sales),2) AS sales
FROM superstore_sales
GROUP BY state
ORDER BY sales ASC
LIMIT 10;

-- Top 10 States by Profit
SELECT
	state,
	ROUND(SUM(profit),2) AS profit
FROM superstore_sales
GROUP BY state
ORDER BY profit DESC
LIMIT 10;

-- Bottom 10 States by Profit
SELECT
	state,
	ROUND(SUM(profit),2) AS profit
FROM superstore_sales
GROUP BY state
ORDER BY profit ASC
LIMIT 10;

/* Category Ranking */

-- Categories Ranked by Sales
SELECT
	category,
	ROUND(SUM(sales),2) AS sales
FROM superstore_sales
GROUP BY category
ORDER BY sales DESC;

-- Categories Ranked by Profit
SELECT
	category,
	ROUND(SUM(profit),2) AS profit
FROM superstore_sales
GROUP BY category
ORDER BY profit DESC;


/* Sub-Category Ranking */

-- Sub-Categories Ranked by Sales
SELECT
	sub_category,
	ROUND(SUM(sales),2) AS sales
FROM superstore_sales
GROUP BY sub_category
ORDER BY sales DESC;

-- Sub-Categories Ranked by Profit
SELECT
	sub_category,
	ROUND(SUM(profit),2) AS profit
FROM superstore_sales
GROUP BY sub_category
ORDER BY profit DESC;

/*==========================================================================================================================
PHASE 2: ADVANCE ANALYTICS 
		 This phase is the deeper part of data analysis. It helps us understand why the business is performiang the way it it . 
         While EDA provides the results of the business performance 
         ADVANCE ANALYTICS provides the explanation of those results. 
		
		PURPOSE: To find insight and provide explanation about the business performance 
==========================================================================================================================

			ADVANCED ANALYTICS flow

		1. Change Over Time Analysis
				↓
		2. Cumulative Analysis
				↓
		3. Moving Average Analysis
				↓
		4. Performance Analysis
				↓
		5. Part-to-Whole Analysis
				↓
		6. Profitability Analysis
				↓
		7. Customer Analytics
				↓
		8. Product Analytics
				↓
		9. Customer Segmentation
				↓
		10. Product Segmentation
---------------------------------------------------------------------------------------------------------------*/

-- 1. CHANGE OVER TIME ANALYSIS ( it examines how a business metrics evolve across a period of time)
	 -- It helps management understand seasonality ( peek and downward period in the business)
	 -- the important question to ask is not what is total sales but rather how is sales changing over time
     -- PURPOSE : To identify trends (direction of the metric)
     
			/* KEY ENTITIES
				1. Sales Trend
				2. Profit Trend
				3. Order Trend
				4. Customer Trend
--------------------------------------------------------------------------------------------------------------------*/

/* SALES TREND(monthly & yearly)*/

	-- Montly trend 
		SELECT
			DATE_FORMAT(order_date, '%Y - %m') AS order_month,
			ROUND(SUM(sales),2) AS _total_sales
        FROM superstore_sales
        GROUP BY DATE_FORMAT(order_date, '%Y - %m')
        ORDER BY DATE_FORMAT(order_date, '%Y - %m') ASC;
        
     -- Yearly trend   
		SELECT
			DATE_FORMAT(order_date,'%Y') AS order_year,
			ROUND(SUM(sales),2) AS total_sales
        FROM superstore_sales
        GROUP BY order_year
        ORDER BY order_year ASC;

/* PROFIT TREND(monthly & yearly) */

	-- Monthly trend
    SELECT
		DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        ROUND(SUM(profit),2) As total_profit
	FROM superstore_sales
    GROUP BY order_month
    ORDER BY order_month;
    
    -- Yearly trend
    SELECT
		DATE_FORMAT(order_date, '%Y') AS order_year,
        ROUND(SUM(profit),2) As total_profit
	FROM superstore_sales
    GROUP BY order_year
    ORDER BY order_year;

/* ORDER TREND(monthly & yearly) */

-- Monthly trend
    SELECT
		DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        ROUND(COUNT(DISTINCT order_id),0) As total_order
	FROM superstore_sales
    GROUP BY order_month
    ORDER BY order_month;

-- Yearly trend
    SELECT
		DATE_FORMAT(order_date, '%Y') AS order_year,
        ROUND(COUNT(DISTINCT order_id),0) As total_order
	FROM superstore_sales
    GROUP BY order_year
    ORDER BY order_year;

/* CUSTOMER TREND(monthly & yearly) */

-- Monthly trend
    SELECT
		DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        ROUND(COUNT(DISTINCT customer_id),0) As total_customer
	FROM superstore_sales
    GROUP BY order_month
    ORDER BY order_month;

-- Yearly trend
    SELECT
		DATE_FORMAT(order_date, '%Y') AS order_year,
        ROUND(COUNT(DISTINCT customer_id),0) As total_customer
	FROM superstore_sales
    GROUP BY order_year
    ORDER BY order_year;
    
/*================================================================================================================
-- 2.CUMULATIVE ANALYSIS
		It measure the running total of a metric over time ( Ex: how much have sell up to now )
        PURPOSE : To measure business growth over time
        
		CUMULATIVE ANALYSIS flow 
		1. Cumulative Sales
			   ↓
		2. Cumulative Profit
			   ↓
		3. Cumulative Orders
			   ↓
		4. Cumulative Customers
-----------------------------------------------------------------------------------------------------*/
 
		-- 1. Cumulative Sales
        
       WITH monthly_sales AS
       (
       SELECT
			DATE_FORMAT(order_date, '%Y-%m') AS order_month,
			ROUND(SUM(sales),2)AS monthly_sales
        FROM superstore_sales
        GROUP BY order_month
        ORDER BY order_month ASC)
        
        SELECT
			order_month,
			monthly_sales,
            SUM(monthly_sales) OVER(ORDER BY order_month)AS running_sales
		FROM monthly_sales
        GROUP BY order_month
        ORDER BY order_month ASC
        ;
			
		-- 2. Cumulative Profit
        
	 WITH monthly_profit AS
       (
       SELECT
			DATE_FORMAT(order_date, '%Y-%m') AS order_month,
			ROUND(SUM(profit),2)AS monthly_profit
        FROM superstore_sales
        GROUP BY order_month
        ORDER BY order_month ASC)
        
        SELECT
			order_month,
			monthly_profit,
            SUM(monthly_profit) OVER(ORDER BY order_month )AS running_profit
		FROM monthly_profit
        GROUP BY order_month
        ORDER BY order_month ASC
        ;	   
               
		-- 3. Cumulative Orders
        
		WITH monthly_order AS
       (
       SELECT
			DATE_FORMAT(order_date, '%Y-%m') AS order_month,
			ROUND(COUNT(DISTINCT order_id),0)AS monthly_order
        FROM superstore_sales
        GROUP BY order_month
        ORDER BY order_month ASC)
        
        SELECT
			order_month,
			monthly_order,
            SUM(monthly_order) OVER(ORDER BY order_month )AS running_orders
		FROM monthly_order
        GROUP BY order_month
        ORDER BY order_month ASC
        ;	   
               
		-- 4. Cumulative Customers
   	 WITH monthly_customer AS
       (
       SELECT
			DATE_FORMAT(order_date, '%Y-%m') AS order_month,
			ROUND(COUNT(DISTINCT customer_id),0)AS monthly_customers
        FROM superstore_sales
        GROUP BY order_month
        ORDER BY order_month ASC)
        
        SELECT
			order_month,
			monthly_customers,
            SUM(monthly_customers) OVER(ORDER BY order_month )AS running_customers
		FROM monthly_customer
        GROUP BY order_month
        ORDER BY order_month ASC
        ;	     
/*==========================================================================================================				
-- 3.MOVING AVERAGE ANALYSIS 
		it provides us with a clear view of the underlying trend by reducing monthly metric fluctuation
        Ex: Monthly sales will provide results at a granular lever and those results could drastically fluctuate within months 
        but moving average reduces those fluactuation and provide a steady trend.
        
        MOVING AVERAGE ANALYSIS flow

			1. Sales Moving Average
				   ↓
			2. Profit Moving Average
				   ↓
			3. Orders Moving Average
				   ↓
			4. Customers Moving Average
----------------------------------------------------------------------------------------------------------------------*/

-- 1. Sales Moving Average (3_month_moving_average)
		-- answer the question what is the sales trend
        
	WITH monthly_sales AS 
    (
    SELECT
		DATE_FORMAT(order_date,'%Y-%m') AS order_month,
		ROUND(SUM(sales),2) AS total_sales
    FROM superstore_sales
    GROUP BY order_month
    ORDER BY order_month)
    
    SELECT
    order_month,
    total_sales,
    CASE 
		WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN  ROUND(AVG(total_sales)OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) 
        ELSE NULL
        END AS moving_avg_sales
    FROM monthly_sales
    GROUP BY order_month
    ;
/*--------------------------------------------------------------------------------------------------------------------------------------------------*/
-- 2. Profit Moving Average (3_month_moving_average)
		-- answer the question what is the profit trend
        
	WITH monthly_profit AS 
    (
    SELECT
		DATE_FORMAT(order_date,'%Y-%m') AS order_month,
		ROUND(SUM(profit),2) AS total_profit
    FROM superstore_sales
    GROUP BY order_month
    ORDER BY order_month)
    
    SELECT
    order_month,
    total_profit,
    CASE 
		WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN  ROUND(AVG(total_profit)OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) 
        ELSE NULL
        END AS moving_avg_profit
    FROM monthly_profit
    GROUP BY order_month
    ;
/*--------------------------------------------------------------------------------------------------------------------------------------------------*/       
-- 3. Orders Moving Average (3_month_moving_average)
		-- answer the question what is the orders trend
        
	WITH monthly_order AS 
    (
    SELECT
		DATE_FORMAT(order_date,'%Y-%m') AS order_month,
		ROUND(COUNT(DISTINCT order_id),2) AS total_orders
    FROM superstore_sales
    GROUP BY order_month
    ORDER BY order_month)
    
    SELECT
    order_month,
    total_orders,
    CASE 
		WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN  ROUND(AVG(total_orders)OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),0) 
        ELSE NULL
        END AS moving_avg_orders
    FROM monthly_order
    GROUP BY order_month
    ;
/*--------------------------------------------------------------------------------------------------------------------------------------------------*/       
-- 4. Customers Moving Average (3_month_moving_average)
		-- answer the question what is the customers trend
        
	WITH monthly_customer AS 
    (
    SELECT
		DATE_FORMAT(order_date,'%Y-%m') AS order_month,
		ROUND(COUNT(DISTINCT customer_id),2) AS total_customers
    FROM superstore_sales
    GROUP BY order_month
    ORDER BY order_month)
    
    SELECT
    order_month,
    total_customers,
    CASE 
		WHEN COUNT(*) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) = 3 THEN  ROUND(AVG(total_customers)OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),0) 
        ELSE Null
        END AS moving_avg_customers
    FROM monthly_customer
    GROUP BY order_month
    ;

/*===============================================================================================================
-- 4. PERFORMANCE ANALYSIS
		Evaluates the performance of business entities by comparing them agains a beanchmark
        
	PERFORMANCE ANALYSIS flow
    
 -- 1. Product Performance
        -- VS Average Product Performance

 -- 2. Customer Performance
        -- VS Average Customer Performance

 -- 3. Category Performance
        -- VS Average Category Performance

 -- 4. Region Performance
        -- VS Average Region Performance

 -- 5. State Performance
        -- VS Average State Performance
-------------------------------------------------------------------------------------------------------------*/
       
-- 1. Product Performance VS Average Product Performance
/*--------------------------------------------------------------------------------------------------------------------------------------------------*/  
	-- * Sales vs Average Product Sales
    
   WITH product_sale AS 
   (
    SELECT 
		product_name,
		ROUND(SUM(sales),2) AS total_sale
    FROM superstore_sales
    GROUP BY product_name
    ORDER BY total_sale DESC)
    ,
    Average_sale AS 
    (
    SELECT
		product_name,
		total_sale,
		ROUND(AVG(total_sale)OVER(),2)AS avg_sale
    FROM product_sale
    ORDER BY total_sale DESC)
    SELECT
		product_name,
		total_sale,
        avg_sale,
        ROUND(total_sale - avg_sale,2) AS difference_from_avg,
        CASE 
			WHEN total_sale > avg_sale THEN 'Over Performed'
            WHEN total_sale < avg_sale THEN 'Under Performed'
            ELSE 'Average performance'
	END AS performance_status
    FROM Average_sale;
/*--------------------------------------------------------------------------------------------------------------------------------------------------*/    
	-- * Profit vs Average Product Profit
    
   WITH product_sale AS 
   (
    SELECT 
		product_name,
		ROUND(SUM(sales),2) AS total_sale
    FROM superstore_sales
    GROUP BY product_name
    ORDER BY total_sale DESC)
    ,
    Average_sale AS 
    (
    SELECT
		product_name,
		total_sale,
		ROUND(AVG(total_sale)OVER(),2)AS avg_sale
    FROM product_sale
    ORDER BY total_sale DESC)
    SELECT
		product_name,
		total_sale,
        avg_sale,
        ROUND(total_sale - avg_sale,2) AS difference_from_avg,
        CASE 
			WHEN total_sale > avg_sale THEN 'Over Performed'
            WHEN total_sale < avg_sale THEN 'Under Performed'
            ELSE 'Average performance'
	END AS performance_status
    FROM Average_sale;
/*--------------------------------------------------------------------------------------------------------------------------------------------------*/    
	-- * Orders vs Average Product Orders
    
   WITH product_orders AS 
   (
    SELECT
	product_name,
	COUNT(order_id) AS total_order
    FROM superstore_sales
    GROUP BY product_name)
    ,
    avg_product_order AS 
    (
    SELECT
    product_name,
    total_order,
    ROUND(AVG(total_order)OVER(),2) AS avg_order
    FROM product_orders
    ORDER BY total_order DESC)
    
    SELECT
		product_name,
		total_order,
		total_order - avg_order AS diff_btw_total_avg_order,
		CASE 
			WHEN total_order > avg_order THEN 'High Performance'
			WHEN total_order < avg_order THEN 'Low Performance'
			ELSE 'Average performance'
		END AS performance_status
	FROM avg_product_order
    ;    
/*--------------------------------------------------------------------------------------------------------------------------------------------------*/           
-- 2. Customer Performance VS Average Customer Performance

	-- * Customer Sales vs Average Customer Sales

WITH customer_sales AS 
(
	SELECT
		customer_name,
		ROUND(SUM(sales),2) AS total_sale
	FROM superstore_sales
	GROUP BY customer_name)
,
avg_sales AS 
(
	SELECT 
		customer_name,
		total_sale,
		ROUND(AVG(total_sale)OVER(),2)AS avg_sale
	FROM customer_sales)

	SELECT
		customer_name,
		total_sale,
		avg_sale,
		total_sale - avg_sale AS diff_btw_total_avg_sale,
		CASE 
			WHEN total_sale > avg_sale THEN 'High performance'
			WHEN total_sale < avg_sale THEN 'Low performance'
			ELSE 'Average performance'
		END AS performance_status
	FROM avg_sales
    ORDER BY total_sale DESC
	;

	-- * Customer Profit vs Average Customer Profit
WITH customer_profits AS 
(
	SELECT
		customer_name,
		ROUND(SUM(profit),2) AS total_profit
	FROM superstore_sales
	GROUP BY customer_name)
,
avg_profits AS 
(
	SELECT 
		customer_name,
		total_profit,
		ROUND(AVG(total_profit)OVER(),2)AS avg_profit
	FROM customer_profits)

	SELECT
		customer_name,
		total_profit,
		avg_profit,
		total_profit - avg_profit AS diff_btw_total_avg_profit,
		CASE 
			WHEN total_profit > avg_profit THEN 'High performance'
			WHEN total_profit < avg_profit THEN 'Low performance'
			ELSE 'Average performance'
		END AS performance_status
	FROM avg_profits
    ORDER BY total_profit DESC
	;

	-- * Customer Orders vs Average Customer Orders
WITH customer_orders AS 
(
	SELECT
		customer_name,
		ROUND(COUNT(order_id),0) AS total_order
	FROM superstore_sales
	GROUP BY customer_name)
,
avg_orders AS 
(
	SELECT 
		customer_name,
		total_order,
		ROUND(AVG(total_order)OVER(),0)AS avg_order
	FROM customer_orders)

	SELECT
		customer_name,
		total_order,
		avg_order,
		total_order - avg_order AS diff_btw_total_avg_order,
		CASE 
			WHEN total_order > avg_order THEN 'High performance'
			WHEN total_order < avg_order THEN 'Low performance'
			ELSE 'Average performance'
		END AS performance_status
	FROM avg_orders
    ORDER BY total_order DESC
	;
/*----------------------------------------------------------------------------------------*/
-- 3. Category Performance VS Average Category Performance

	-- * Category Sales vs Average Category Sales
    
WITH category_sales AS 
(
	SELECT
		category,
		ROUND(SUM(sales),2) AS total_sale
	FROM superstore_sales
	GROUP BY category)
,
avg_category_sales AS 
(
	SELECT 
		category,
		total_sale,
		ROUND(AVG(total_sale)OVER(),2)AS avg_sale
	FROM category_sales)

	SELECT
		category,
		total_sale,
		avg_sale,
		total_sale - avg_sale AS diff_btw_total_avg_sale,
		CASE 
			WHEN total_sale > avg_sale THEN 'High performance'
			WHEN total_sale < avg_sale THEN 'Low performance'
			ELSE 'Average performance'
		END AS performance_status
	FROM avg_category_sales
    ORDER BY total_sale DESC
	;
/*----------------------------------------------------------------------------------------*/
-- Category Profit vs Average Category Profit

WITH category_profits AS 
(
	SELECT
		category,
		ROUND(SUM(profit),2) AS total_profit
	FROM superstore_sales
	GROUP BY category)
,
avg_category_profits AS 
(
	SELECT 
		category,
		total_profit,
		ROUND(AVG(total_profit)OVER(),2)AS avg_profit
	FROM category_profits)

	SELECT
		category,
		total_profit,
		avg_profit,
		total_profit - avg_profit AS diff_btw_total_avg_profit,
		CASE 
			WHEN total_profit > avg_profit THEN 'High performance'
			WHEN total_profit < avg_profit THEN 'Low performance'
			ELSE 'Average performance'
		END AS performance_status
	FROM avg_category_profits
    ORDER BY total_profit DESC;
    
	-- * Category Orders vs Average Category Orders
WITH category_orders AS 
(
	SELECT
		category,
		ROUND(COUNT(order_id),0) AS total_order
	FROM superstore_sales
	GROUP BY category)
,
avg_category_orders AS 
(
	SELECT 
		category,
		total_order,
		ROUND(AVG(total_order)OVER(),2)AS avg_order
	FROM category_orders)

	SELECT
		category,
		total_order,
		avg_order,
		total_order - avg_order AS diff_btw_total_avg_order,
		CASE 
			WHEN total_order > avg_order THEN 'High performance'
			WHEN total_order < avg_order THEN 'Low performance'
			ELSE 'Average performance'
		END AS performance_status
	FROM avg_category_orders
    ORDER BY total_order DESC
	;
/*--------------------------------------------------------------------------------------------------*/    
-- 4. Region Performance VS Average Region Performance  
	-- * Region Sales vs Average Region Sales
    
WITH region_sales AS 
(
	SELECT
		region,
		ROUND(SUM(sales),2) AS total_sale
	FROM superstore_sales
	GROUP BY region)
	,
	avg_region_sales AS 
	(
	SELECT
		region,
		total_sale,
		ROUND(AVG(total_sale)OVER(),2) AS avg_sale
	FROM region_sales
	GROUP BY region)

	SELECT
		region,
		total_sale,
		avg_sale,
		total_sale - avg_sale AS diff_btw_total_avg_sale,
		CASE 
			WHEN total_sale > avg_sale THEN 'High Performance'
			WHEN total_sale < avg_sale THEN 'Low Performance'
			ELSE 'Average Performance'
		END AS Performance_status
	FROM avg_region_sales
    ORDER BY total_sale DESC;
    
	-- * Region Profit vs Average Region Profit
    
WITH region_profits AS 
(
	SELECT
		region,
		ROUND(SUM(profit),2) AS total_profit
	FROM superstore_sales
	GROUP BY region)
	,
	avg_region_profits AS 
	(
	SELECT
		region,
		total_profit,
		ROUND(AVG(total_profit)OVER(),2) AS avg_profit
	FROM region_profits
	GROUP BY region)

	SELECT
		region,
		total_profit,
		avg_profit,
		total_profit - avg_profit AS diff_btw_total_avg_profit,
		CASE 
			WHEN total_profit > avg_profit THEN 'High Performance'
			WHEN total_profit < avg_profit THEN 'Low Performance'
			ELSE 'Average Performance'
		END AS Performance_status
	FROM avg_region_profits
    ORDER BY total_profit DESC
;
	-- * Region Orders vs Average Region Orders
    
WITH region_orders AS 
(
	SELECT
		region,
		ROUND(COUNT(order_id),0) AS total_order
	FROM superstore_sales
	GROUP BY region)
	,
	avg_region_orders AS 
	(
	SELECT
		region,
		total_order,
		ROUND(AVG(total_order)OVER(),2) AS avg_order
	FROM region_orders
	GROUP BY region)

	SELECT
		region,
		total_order,
		avg_order,
		total_order - avg_order AS diff_btw_total_avg_order,
		CASE 
			WHEN total_order > avg_order THEN 'High Performance'
			WHEN total_order < avg_order THEN 'Low Performance'
			ELSE 'Average Performance'
		END AS Performance_status
	FROM avg_region_orders
    ORDER BY total_order DESC
;
/*------------------------------------------------------------------------------------------*/    
-- 5. State Performance VS Average State Performance
	-- * State Sales vs Average State Sales
    
WITH state_sales AS 
(
	SELECT
		state,
		ROUND(SUM(sales),2) AS total_sale
	FROM superstore_sales
	GROUP BY state)
	,
	avg_state_sales AS 
	(
	SELECT
		state,
		total_sale,
		ROUND(AVG(total_sale)OVER(),2) AS avg_sale
	FROM state_sales
	GROUP BY state)

	SELECT
		state,
		total_sale,
		avg_sale,
		total_sale - avg_sale AS diff_btw_total_avg_sale,
		CASE 
			WHEN total_sale > avg_sale THEN 'High Performance'
			WHEN total_sale < avg_sale THEN 'Low Performance'
			ELSE 'Average Performance'
		END AS Performance_status
	FROM avg_state_sales
    ORDER BY total_sale DESC;
    
	-- * State Profit vs Average State Profit
WITH state_profits AS 
(
	SELECT
		state,
		ROUND(SUM(profit),2) AS total_profit
	FROM superstore_sales
	GROUP BY state)
	,
	avg_state_profits AS 
	(
	SELECT
		state,
		total_profit,
		ROUND(AVG(total_profit)OVER(),2) AS avg_profit
	FROM state_profits
	GROUP BY state)

	SELECT
		state,
		total_profit,
		avg_profit,
		total_profit - avg_profit AS diff_btw_total_avg_profit,
		CASE 
			WHEN total_profit > avg_profit THEN 'High Performance'
			WHEN total_profit < avg_profit THEN 'Low Performance'
			ELSE 'Average Performance'
		END AS Performance_status
	FROM avg_state_profits
    ORDER BY total_profit DESC;    
    
	-- * State Orders vs Average State Orders
    
WITH state_orders AS 
(
	SELECT
		state,
		ROUND(COUNT(order_id),0) AS total_order
	FROM superstore_sales
	GROUP BY state)
	,
	avg_state_orders AS 
	(
	SELECT
		state,
		total_order,
		ROUND(AVG(total_order)OVER(),2) AS avg_order
	FROM state_orders
	GROUP BY state)

	SELECT
		state,
		total_order,
		avg_order,
		total_order - avg_order AS diff_btw_total_avg_order,
		CASE 
			WHEN total_order > avg_order THEN 'High Performance'
			WHEN total_order < avg_order THEN 'Low Performance'
			ELSE 'Average Performance'
		END AS Performance_status
	FROM avg_state_orders
    ORDER BY total_order DESC
;    
/*==============================================================================================================
-- 5. PART-TO-WHOLE-ANALYSIS
		This analysis is to understand the contribution of each business entity to the business performance. 
		for our project we will answer the question of the contribution of category, state and region to the business sales and profit 
        
-----------------------------------------------------------------------------------------------------------------        
		 PART-TO-WHOLE ANALYSIS flow

		1. Category Contribution Analysis
			├── Sales Contribution %
			└── Profit Contribution %

		2. State Contribution Analysis
			├── Sales Contribution %
			└── Profit Contribution %

		3. Region Contribution Analysis
			├── Sales Contribution %
			└── Profit Contribution %       
-------------------------------------------------------------------------------------------------------------------- */            
-- 1. Category Contribution Analysis
		-- Category Sales Contribution %
        
WITH category_sales AS 
(
	SELECT
	category,
	ROUND(SUM(sales),2) AS category_sale
	FROM superstore_sales
	GROUP BY category)
,    
total_sales AS
	(	
    SELECT
	category,
	category_sale,
	ROUND(SUM(category_sale) OVER(),2) AS total_sale
FROM category_sales)

	SELECT 
    category,
	category_sale,
	total_sale,
  ROUND(category_sale / total_sale * 100,2) AS category_sale_contribution 
FROM total_sales
ORDER BY category_sale DESC;

/*-------------------------------------------------------------------------------------------------*/
		--  Category Profit Contribution %
        
WITH category_profits AS 
(
	SELECT
	category,
	ROUND(SUM(profit),2) AS category_profit
	FROM superstore_sales
	GROUP BY category)
,    
total_profits AS
	(	
    SELECT
	category,
	category_profit,
	ROUND(SUM(category_profit) OVER(),2) AS total_profit
FROM category_profits)

	SELECT 
    category,
	category_profit,
	total_profit,
  ROUND(category_profit / total_profit * 100,2) AS category_profit_contribution 
FROM total_profits
ORDER BY category_profit DESC;

/*----------------------------------------------------------------------------------------------------*/
-- 2. State Contribution Analysis
		-- State Sales Contribution %
        
WITH state_sales AS 
(
	SELECT
	state,
	ROUND(SUM(sales),2) AS state_sale
	FROM superstore_sales
	GROUP BY state)
,    
total_sales AS
	(	
    SELECT
	state,
	state_sale,
	ROUND(SUM(state_sale) OVER(),2) AS total_sale
FROM state_sales)

	SELECT 
    state,
	state_sale,
	total_sale,
  ROUND(state_sale / total_sale * 100,2) AS state_sale_contribution 
FROM total_sales
ORDER BY state_sale DESC;

		-- State Profit Contribution %
        
WITH state_profits AS 
(
	SELECT
	state,
	ROUND(SUM(profit),2) AS state_profit
	FROM superstore_sales
	GROUP BY state)
,    
total_profits AS
	(	
    SELECT
	state,
	state_profit,
	ROUND(SUM(state_profit) OVER(),2) AS total_profit
FROM state_profits)

	SELECT 
    state,
	state_profit,
	total_profit,
  ROUND(state_profit / total_profit * 100,2) AS state_profit_contribution 
FROM total_profits
ORDER BY state_profit DESC;

/*----------------------------------------------------------------------------------------------*/
-- 3. Region Contribution Analysis
		-- Region Sales Contribution %
        
WITH region_sales AS 
(
	SELECT
	region,
	ROUND(SUM(sales),2) AS region_sale
	FROM superstore_sales
	GROUP BY region)
,    
total_sales AS
	(	
    SELECT
	region,
	region_sale,
	ROUND(SUM(region_sale) OVER(),2) AS total_sale
FROM region_sales)

	SELECT 
    region,
	region_sale,
	total_sale,
  ROUND(region_sale / total_sale * 100,2) AS region_sale_contribution 
FROM total_sales
ORDER BY region_sale DESC;

		-- Region Profit Contribution % 
        
WITH region_profits AS 
(
	SELECT
	region,
	ROUND(SUM(profit),2) AS region_profit
	FROM superstore_sales
	GROUP BY region)
,    
total_profits AS
	(	
    SELECT
	region,
	region_profit,
	ROUND(SUM(region_profit) OVER(),2) AS total_profit
FROM region_profits)

	SELECT 
    region,
	region_profit,
	total_profit,
  ROUND(region_profit / total_profit * 100,2) AS region_profit_contribution 
FROM total_profits
ORDER BY region_profit DESC;

/*==========================================================================================================
-- 6. PROFITABILITY ANALYSIS
	It is the process of analysis the profit margin of the business entities. we want to know from each entity who performes better or worst in terms of profit compare to sales 

		PROFITABILITY ANALYSIS flow

		1. Category Profitability
			   └── Profit Margin %

		2. State Profitability
			   └── Profit Margin %

		3. Region Profitability
			   └── Profit Margin %
-----------------------------------------------------------------------------------------------------------*/

-- 1. Category Profitability
       --  Profit Margin %
SELECT
	category,
	ROUND(SUM(sales),2) AS total_sale,
	ROUND(SUM(profit),2) AS total_profit,
	CONCAT(ROUND(SUM(profit) / SUM(sales) * 100,2),'%') AS profit_margin
FROM superstore_sales
GROUP BY category
ORDER BY SUM(profit) / SUM(sales) DESC;

-- 2. State Profitability
       --  Profit Margin %
SELECT
	state,
	ROUND(SUM(sales),2) AS total_sale,
	ROUND(SUM(profit),2) AS total_profit,
	CONCAT(ROUND(SUM(profit) / SUM(sales) * 100,2),'%') AS profit_margin
FROM superstore_sales
GROUP BY state
ORDER BY SUM(profit) / SUM(sales) DESC;

-- 3. Region Profitability
       --  Profit Margin % 
SELECT
	region,
	ROUND(SUM(sales),2) AS total_sale,
	ROUND(SUM(profit),2) AS total_profit,
	CONCAT(ROUND(SUM(profit) / SUM(sales) * 100,2),'%') AS profit_margin
FROM superstore_sales
GROUP BY region
ORDER BY SUM(profit) / SUM(sales) DESC;

/*==========================================================================================================       
-- 7.CUSTOMER ANALYTICS
	 It is the process of analyzing customers behavior, their purchasing patterns and their sales contribution to business performance in order to understand their value and make business informed decison
     
		CUSTOMER ANALYTICS flow

1. Customer Behavior Analysis
       ├── Purchase Frequency
       ├── Average Order Value
       └── Customer Lifespan

2. Customer Contribution Analysis
       ├── Sales
       ├── Profit
       └── Orders

3. Customer Segmentation
       ├── VIP
       ├── Regular
       └── New
------------------------------------------------------------------------------------------------------------*/

-- 1. Customer Behavior Analysis
       -- Purchase Frequency
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders
FROM superstore_sales
GROUP BY customer_id, customer_name
ORDER BY total_orders DESC;

       -- Average Order Value
SELECT
	customer_id,
	customer_name,
	total_sale,
	total_order,
    ROUND(total_sale / total_order,2) AS avg_order_value
	FROM
	(
		SELECT
			customer_id,
			customer_name,
			ROUND(SUM(sales),2) As total_sale,
			COUNT(DISTINCT order_id) As total_order
		FROM superstore_sales
		GROUP BY customer_id,customer_name) AS t
		ORDER BY total_sale / total_order DESC;

       -- Customer Lifespan
SELECT
	customer_id
	customer_name,
	first_order_date,
	last_order_date,
	TIMESTAMPDIFF(YEAR, first_order_date, last_order_date)AS customer_lifespan_in_years,
    TIMESTAMPDIFF(MONTH, first_order_date, last_order_date)AS customer_lifespan_in_months 
FROM
(
	SELECT
		customer_id,
		customer_name,
		MIN(order_date) AS first_order_date,
		MAX(order_date) AS last_order_date
	FROM superstore_sales
	GROUP BY customer_id, customer_name)AS t
	ORDER BY customer_lifespan_in_months DESC;

-- 2. Customer Contribution Analysis
       -- Customer Sales Contribution
WITH customer_sales AS 
(
	SELECT
	customer_id,
	customer_name,
	ROUND(SUM(sales),2) AS customer_sale
	FROM superstore_sales
	GROUP BY customer_id, customer_name)
,
total_sales AS 	
(
    SELECT
		customer_id,
		customer_name,
		customer_sale,
		SUM(customer_sale)OVER() AS total_sale 
	FROM customer_sales)
			
		SELECT
				customer_id,
				customer_name,
				customer_sale,
				total_sale,
                CONCAT(ROUND(customer_sale / total_sale *100,2),'%') AS customer_contribution
                FROM total_sales
                ORDER BY customer_sale / total_sale DESC;

	-- Customer Profit contribution
WITH customer_profits AS 
(
	SELECT
	customer_id,
	customer_name,
	ROUND(SUM(profit),2) AS customer_profit
	FROM superstore_sales
	GROUP BY customer_id, customer_name)
,
total_profits AS 	
(
    SELECT
		customer_id,
		customer_name,
		customer_profit,
		SUM(customer_profit)OVER() AS total_profit
	FROM customer_profits)
			
		SELECT
				customer_id,
				customer_name,
				customer_profit,
				total_profit,
                CONCAT(ROUND(customer_profit / total_profit *100,2),'%') AS customer_contribution
                FROM total_profits
                ORDER BY customer_profit / total_profit DESC;
                
  -- Customer Orders Contribution
WITH customer_orders AS 
(
	SELECT
	customer_id,
	customer_name,
	COUNT(DISTINCT order_id) AS customer_order
	FROM superstore_sales
	GROUP BY customer_id, customer_name)
,
total_orders AS 	
(
    SELECT
		customer_id,
		customer_name,
		customer_order,
		SUM(customer_order)OVER() AS total_order
	FROM customer_orders)
			
		SELECT
				customer_id,
				customer_name,
				customer_order,
				total_order,
                CONCAT(ROUND(customer_order / total_order *100,2),'%') AS customer_contribution
                FROM total_orders
                ORDER BY customer_order / total_order DESC;
                
/*------------------------------------------------------------------------------------------
-- 3. Customer Segmentation ( VIP, Regular, New)
       Process of grouping customers based on the same charasteristics  

		CUSTOMER SEGMENTATION charasteristics 

			VIP : Lifespan >= 12 Months
				AND
				Sales > $5,000

			Regular : Lifespan >= 12 Months
				AND
				Sales <= $5,000

			New : Lifespan < 12 Months
-----------------------------------------------------------------------------------------*/

-- Customer Segmentation
WITH customer_segment AS 
(	
    SELECT
		customer_id,
		customer_name,
		ROUND(SUM(sales),2) AS total_sale,
		MIN(order_date) AS first_order_date,
		MAX(order_date) AS last_order_date
	FROM superstore_sales
GROUP BY customer_id, customer_name)
,
customer_lifespan AS
(
	SELECT 
			customer_id,
			customer_name,
			total_sale,
			first_order_date,
			last_order_date,
			TIMESTAMPDIFF(MONTH,first_order_date,last_order_date)AS customer_lifespan
FROM customer_segment)

	SELECT
			customer_id,
			customer_name,
			total_sale,
			customer_lifespan,
            CASE 
				WHEN customer_lifespan >= 12 AND total_sale > 5000 THEN 'VIP'
                WHEN customer_lifespan >= 12 AND total_sale <= 5000 THEN 'Regular'
                ELSE 'New'
			END AS customer_segment
FROM customer_lifespan
ORDER BY total_sale DESC;

/*==========================================================================================================       
-- 8.PRODUCT ANALYTICS
		It is the process of analyzing the products to understand their performance and contribution to the business
         Each product contribution to sales, profit and orders 
         
         PRODUCT ANALYTICS flow

1. Product Performance Analysis
       ├── Sales
       ├── Profit
       └── Orders

2. Product Behavior Analysis
       ├── Order Frequency
       └── Average Sales per Order

3. Product Contribution Analysis
       ├── Sales Contribution %
       └── Profit Contribution %

4. Product Profitability Analysis
       └── Profit Margin %
 ------------------------------------------------------------------------------------------------------------*/
 
-- 1. Product Performance Analysis
       --  product Sales performance
       
	-- TOP 10 products by sales 
SELECT
	product_name,
    ROUND(SUM(sales),2) As total_sale
FROM superstore_sales
GROUP BY product_name
ORDER BY total_sale DESC
LIMIT 10;

-- bottom 10 products by sales 
SELECT
	product_name,
    ROUND(SUM(sales),2) As total_sale
FROM superstore_sales
GROUP BY product_name
ORDER BY total_sale ASC
LIMIT 10;

/*product Profit performance*/
       
	-- TOP 10 products by profit 
SELECT
	product_name,
    ROUND(SUM(profit),2) As total_profit
FROM superstore_sales
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;

	-- BOTTOM 10 products by profit 
SELECT
	product_name,
    ROUND(SUM(profit),2) As total_profit
FROM superstore_sales
GROUP BY product_name
ORDER BY total_profit ASC
LIMIT 10;

 /*product Orders performance*/
       
-- TOP 10 products by order 
SELECT
	product_name,
    COUNT(DISTINCT order_id) As total_order
FROM superstore_sales
GROUP BY product_name
ORDER BY total_order DESC
LIMIT 10;
       
-- BOTTOM 10 products by order 
SELECT
	product_name,
    COUNT(DISTINCT order_id) As total_order
FROM superstore_sales
GROUP BY product_name
ORDER BY total_order ASC
LIMIT 10;

-- 2. Product Behavior Analysis
       --  product Order Frequency
	SELECT
		product_name,
		COUNT(DISTINCT order_id) AS order_frequency
FROM superstore_sales
GROUP BY product_name
ORDER BY order_frequency DESC;

	 --  product Average Sales per Order
SELECT
	product_name,
	ROUND(SUM(sales),2) AS total_sale,
	COUNT(DISTINCT order_id) AS total_order,
	ROUND(SUM(sales) / COUNT(DISTINCT order_id),2) AS product_avg_sale
FROM superstore_sales
GROUP BY product_name
 ORDER BY product_avg_sale DESC
;

-- 3. Product Contribution Analysis
       --  product Sales Contribution %
WITH product_sales AS
(
	SELECT 
	product_name,
	ROUND(SUM(sales),2) AS product_sale,
	ROUND(SUM(SUM(sales))OVER(),2) AS total_sale
	FROM superstore_sales
	GROUP BY product_name)

SELECT 
	product_name,
	product_sale,
	total_sale,
    ROUND(product_sale / total_sale * 100,2)AS product_sale_contribution
	FROM product_sales
    ORDER BY product_sale DESC;

       --  product Profit Contribution %
WITH product_profits AS
(
	SELECT 
	product_name,
	ROUND(SUM(profit),2) AS product_profit,
	ROUND(SUM(SUM(profit))OVER(),2) AS total_profit
	FROM superstore_sales
	GROUP BY product_name)

SELECT 
	product_name,
	product_profit,
	total_profit,
    ROUND(product_profit / total_profit * 100,2)AS product_profit_contribution
	FROM product_profits
    ORDER BY product_profit DESC;

-- 4. Product Profitability Analysis
       --  Profit Margin %
SELECT
	product_name,
	ROUND(SUM(sales),2) AS product_sale,
	ROUND(SUM(profit),2) AS product_profit,
	ROUND(SUM(profit) / SUM(sales)*100,2) AS profit_margin
FROM superstore_sales
GROUP BY product_name
ORDER BY SUM(profit) / SUM(sales) DESC;

/*==========================================================================================================       
-- 9.CUSTOMER SEGMENTATION
------------------------------------------------------------------------------------------------------------*/
-- Customer Segmentation
WITH customer_segment AS 
(	
    SELECT
		customer_id,
		customer_name,
		ROUND(SUM(sales),2) AS total_sale,
		MIN(order_date) AS first_order_date,
		MAX(order_date) AS last_order_date
	FROM superstore_sales
GROUP BY customer_id, customer_name)
,
customer_lifespan AS
(
	SELECT 
			customer_id,
			customer_name,
			total_sale,
			first_order_date,
			last_order_date,
			TIMESTAMPDIFF(MONTH,first_order_date,last_order_date)AS customer_lifespan
FROM customer_segment)

	SELECT
			customer_id,
			customer_name,
			total_sale,
			customer_lifespan,
            CASE 
				WHEN customer_lifespan >= 12 AND total_sale > 5000 THEN 'VIP'
                WHEN customer_lifespan >= 12 AND total_sale <= 5000 THEN 'Regular'
                ELSE 'New'
			END AS customer_segment
FROM customer_lifespan
ORDER BY total_sale DESC;       
        
/*==========================================================================================================        
-- 10.PRODUCT SEGMENTATION
	PRODUCT SEGMENTATION

1. Calculate Product Sales

2. Calculate Average Product Sales

3. Classify Products
       ── High Performing
       ── Mid-Range
       ── Low Performing
------------------------------------------------------------------------------------------------------------*/

WITH product_sales AS
(
    SELECT
        product_name,
        ROUND(SUM(sales),2) AS product_sale
    FROM superstore_sales
    GROUP BY product_name
),
avg_product_sales AS
(
    SELECT
        product_name,
        product_sale,
        ROUND(AVG(product_sale) OVER(),2) AS avg_product_sale
    FROM product_sales
)

SELECT
    product_name,
    product_sale,
    avg_product_sale,
    CASE 
        WHEN product_sale > avg_product_sale THEN 'High Performance'
        WHEN product_sale < avg_product_sale THEN 'Low Performance'
        ELSE 'Mid-range'
    END AS product_segment
FROM avg_product_sales
ORDER BY product_sale DESC;

/*=====================================================================================================================================
PHASE 3 : REPORTING 
		The process of organizing the business data, metrics and insights in a structure format that allows decision-makers to understand the business performance and make informed decision.
        - data and findings are organized in a report format
        - Decision makers can look at the file and understand business overall performance
========================================================================================================================================

			-- 1. KPI REPORT
				  ↓
			-- 2. CUSTOMER REPORT
				  ↓
			-- 3. PRODUCT REPORT
				  ↓
			-- 4. GEOGRAPHY REPORT
				  ↓
			-- 5. SALES REPORT
				  ↓
			-- 6. REPORTING VIEWS CREATION
				  ↓
			-- 7. BUSINESS INSIGHTS DOCUMENTATION
				  ↓
			-- 8. BUSINESS RECOMMENDATIONS
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
            
/*----------------------------------------------------------------------------------------------------------------------
	-- 3. PRODUCT REPORT
	-- Answer the question:
	-- Which products are driving sales, profit, and quantity sold?
	----------------------------------------------------------------------------------

	PRODUCT METRIC               MEANING
	product_id                   Unique product
	product_name                 Product name
	category                     Product category
	sub_category                 Product sub-category
	total_orders                 Number of orders containing the product
	total_sales                  Revenue generated by the product
	total_profit                 Profit generated by the product
	total_quantity               Total units sold
	profit_margin_pct            Profitability percentage
	product_performance          High Performing, Mid-Range, or Low Performing
-------------------------------------------------------------------------------- */
 		-- PRODUCT REPORT 
WITH product_report AS 
(
	SELECT
		product_id, 
		product_name,
		category,
		sub_category,
		ROUND(SUM(sales),2)AS total_sales,
		ROUND(SUM(profit),2)AS total_profit,
		COUNT(DISTINCT order_id) AS total_orders,
		SUM(quantity) AS total_quantity,
		ROUND(SUM(profit) / SUM(sales)*100,2) AS profit_margin_pct,
        ROUND(AVG(SUM(sales))OVER(),2)AS avg_sales
	FROM superstore_sales
	GROUP BY 
		product_id,
		product_name,
		category,
		sub_category )

		SELECT
				product_id,
				product_name,
				category,
				sub_category,
				total_sales,
				total_profit,
				total_orders,
				total_quantity,
				profit_margin_pct,
                avg_sales,
                CASE
					WHEN total_sales > avg_sales THEN 'High Performance'
                    WHEN total_sales < avg_sales THEN 'Low Performance'
                    ELSE 'Mid-Range'
				END AS product_Performance
			FROM product_report
            ORDER BY total_sales DESC
;
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
/*===========================================================================================
	-- 6. REPORTING VIEWS CREATION
		report_kpi
		report_customers
		report_products
		report_geography
		report_sales
            
/*----------------------------------------------------------------------------------------------------------------------*/
-- REPORT_KPI
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
/*--------------------------------------------------------------------------------------------------------------------*/
-- report_CUSTOMERS
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
/*--------------------------------------------------------------------------------------------------------------------*/

-- REPORT_PRODUCTS
CREATE VIEW superstore_db_copy.Report_Products AS
	WITH product_report AS 
	(
		SELECT
			product_id, 
			product_name,
			category,
			sub_category,
			ROUND(SUM(sales),2)AS total_sales,
			ROUND(SUM(profit),2)AS total_profit,
			COUNT(DISTINCT order_id) AS total_orders,
			SUM(quantity) AS total_quantity,
			ROUND(SUM(profit) / SUM(sales)*100,2) AS profit_margin_pct,
			ROUND(AVG(SUM(sales))OVER(),2)AS avg_sales
		FROM superstore_sales
		GROUP BY 
			product_id,
			product_name,
			category,
			sub_category )

			SELECT
					product_id,
					product_name,
					category,
					sub_category,
					total_sales,
					total_profit,
					total_orders,
					total_quantity,
					profit_margin_pct,
					avg_sales,
					CASE
						WHEN total_sales > avg_sales THEN 'High Performance'
						WHEN total_sales < avg_sales THEN 'Low Performance'
						ELSE 'Mid-Range'
					END AS product_Performance
				FROM product_report
				ORDER BY total_sales DESC
;
/*--------------------------------------------------------------------------------------------------------------------*/

-- REPORT_GEOGRAPHY
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

/*--------------------------------------------------------------------------------------------------------------------*/

-- REPORT_SALES
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
