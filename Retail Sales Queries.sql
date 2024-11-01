SELECT count(*) FROM retail_sales;

SELECT * FROM retail_sales
LIMIT 100;

-- Data Cleaning
ALTER TABLE retail_sales
RENAME COLUMN ï»¿transactions_id TO transactions_id;

ALTER TABLE retail_sales
RENAME COLUMN quantiy TO quantity;

ALTER TABLE retail_sales
MODIFY COLUMN sale_date DATE;

ALTER TABLE retail_sales
MODIFY COLUMN sale_time TIME;

SELECT * FROM retail_sales
WHERE transactions_id IS NULL 
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL OR gender = ''
OR age IS NULL
OR category IS NULL OR category = ''
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;

-- Exploratory Data Analysis

-- All column data for the transactions made on 5th November 2022
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- All transactions for the sales made in November 2022 under the category 'Clothing' where quantity sold is more than 3
SELECT * 
FROM retail_sales
WHERE category = 'Clothing' AND
quantity >= 4 AND
sale_date LIKE '2022-11%';

-- Total Sales for each category
SELECT category, COUNT(*) AS total_transactions, SUM(total_sale) AS total_sales 
FROM retail_sales
GROUP BY category;

-- Average age of customers who purchased itmes under 'Beauty' category
SELECT ROUND(AVG(age)) AS avg_age 
FROM retail_sales
WHERE category = 'Beauty';

-- All transactions where the total sales is greater than 1000
SELECT * 
FROM retail_sales
WHERE total_sale > 1000;

-- Total transactions made by each gender under each category
SELECT category, gender, COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Calculate the average sales for each month and best selling month in each year 
WITH cte AS(
SELECT YEAR(sale_date) AS `year`, MONTHNAME(sale_date) AS `month`, ROUND(AVG(total_sale),2) AS avg_sales,
RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS sales_rank
FROM retail_sales
GROUP BY YEAR(sale_date), MONTHNAME(sale_date)
)
SELECT `year`, `month`, avg_sales FROM CTE
WHERE sales_rank = 1;


-- Top 5 customers based on highest total sales
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- The number of unique customers under each category
SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

-- Create 3 shifts and number of orders of each shift
SELECT 
(CASE WHEN HOUR(sale_time) <=12 THEN 'Morning'
     WHEN HOUR(sale_time) BETWEEN 13 AND 17 THEN 'Afternoon'
     WHEN HOUR(sale_time) > 17 THEN 'Evening'
     ELSE 'Unspecified'
 END) AS shift, COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY shift;
