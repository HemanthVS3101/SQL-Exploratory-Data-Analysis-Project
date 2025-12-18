/*
===============================================================================
Exploration of Data
===============================================================================
Script Purpose:
    This scripts helps in understanding all the tables and columns present in
	the Datawarehouse along with all the measures and dimensions which can be
	created and used to get insights.
===============================================================================
*/

--EXPLORE ALL OBJECTS IN THE DATABASE
SELECT * FROM INFORMATION_SCHEMA.TABLES

--EXPLORE ALL COLUMNS IN THE DATABASE
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

--EXPLORE ALL COUNTRIES WHERE CUSTOMER COME FROM
SELECT DISTINCT country from gold.dim_customers

--EXPLORE ALL PRODUCT DETAILS
SELECT DISTINCT category, subcategory, product_name from gold.dim_products

--FIND FIRST AND LAST ORDER DATE
SELECT MIN(order_date), MAX(order_date) from gold.fact_sales 

--FIND Youngest AND Oldest Customer
SELECT MIN(birthdate) as Oldest, 
DATEDIFF(YEAR,MIN(birthdate),GETDATE()) as Oldest_age,
MAX(birthdate) as Youngest,
DATEDIFF(YEAR,MAX(birthdate),GETDATE()) as Youngest_age
from gold.dim_customers 

--FIND TOTAL SALES
SELECT SUM(sales_amount) as Total_Sales from gold.fact_sales

--FIND HOW MANY ITEMS ARE SOLD
SELECT SUM(quantity) as Total_Quantity from gold.fact_sales

--FIND THE AVERAGE SELLING PRICE
SELECT AVG(price) as Average_Selling_Price from gold.fact_sales

--FIND THE TOTAL NUMBER OF ORDERS
SELECT  COUNT(DISTINCT(order_number)) as Total_Orders from gold.fact_sales

--FIND THE TOTAL NUMBER OF PRODUCTS
SELECT  COUNT(DISTINCT(product_name)) as Total_Products from gold.dim_products

--FIND THE TOTAL NUMBER OF CUSTOMERS
SELECT  COUNT(DISTINCT(customer_id)) as Total_Products from gold.dim_customers

--FIND TOTAL NUMBER OF CUSTOMERS THAT HAS PLACED AN ORDER
SELECT  COUNT(DISTINCT(customer_key)) as Total_Products from gold.fact_sales

--Report that shows all the key metrics
SELECT 'Total Sales' as measure_name, SUM(sales_amount) as measure_value from gold.fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name,SUM(quantity) as measure_value  from gold.fact_sales
UNION ALL
SELECT 'Average Selling Price' as measure_name,AVG(price) as measure_value  from gold.fact_sales
UNION ALL
SELECT 'Total No.Of.Orders' as measure_name,COUNT(DISTINCT(order_number)) as measure_value  from gold.fact_sales
UNION ALL
SELECT 'Total No.Of.Products' as measure_name,COUNT(DISTINCT(product_name)) as measure_value  from gold.dim_products
UNION ALL
SELECT 'Total No.Of.Customers' as measure_name,COUNT(DISTINCT(customer_id)) as measure_value  from gold.dim_customers

--FIND TOTAL CUSTOMERS BY COUNTRY
SELECT country, COUNT(DISTINCT(customer_id)) as Total_Customers FROM gold.dim_customers group by country order by Total_Customers desc

--FIND TOTAL CUSTOMERS BY GENDER
SELECT gender, COUNT(DISTINCT(customer_id)) as Total_Customers FROM gold.dim_customers group by gender order by Total_Customers desc

--FIND TOTAL PRODUCTS BY CATEGORY
SELECT category, COUNT(DISTINCT(product_id)) as Total_Products FROM gold.dim_products group by category order by Total_Products desc

--WHAT IS THE TOTAL REVENUE IN EACH CATEGORY?
SELECT pr.category as Category, SUM(sl.sales_amount) as Total_Amount
FROM gold.fact_sales as sl
LEFT JOIN gold.dim_products as pr
ON sl.product_key = pr.product_key
group by pr.category 
order by Total_Amount desc

--WHAT IS THE TOTAL REVENUE by EACH Customer?
SELECT cs.customer_name as Customer,cs.first_name as First_Name, SUM(sl.sales_amount) as Total_Amount
FROM gold.fact_sales as sl
LEFT JOIN gold.dim_customers as cs
ON sl.customer_key = cs.customer_key
group by cs.customer_name, cs.first_name
order by Total_Amount desc

--WHAT IS THE DISTRIBUSTION OF SOLD ITEMS ACROSS COUNTRIES
SELECT cs.country, SUM(sl.quantity) as Total_Quantity 
from gold.fact_sales as sl
LEFT JOIN gold.dim_customers as cs
ON sl.customer_key = cs.customer_key
group by cs.country
order by Total_Quantity desc

--WHICH 5 PRODUCTS GENERATES THE HIGHEST REVENUE
SELECT product_name, Total_Amount
From(
SELECT pr.product_name as product_name, SUM(sl.sales_amount) as Total_Amount, 
DENSE_RANK() OVER (Order by SUM(sl.sales_amount) desc) as R
FROM gold.fact_sales as sl
LEFT JOIN gold.dim_products as pr
ON sl.product_key = pr.product_key
group by pr.product_name) as t
Where R <= 5

--WHICH 5 PRODUCTS GENERATES THE LOWEST REVENUE
SELECT product_name, Total_Amount
From(
SELECT pr.product_name as product_name, SUM(sl.sales_amount) as Total_Amount, 
DENSE_RANK() OVER (Order by SUM(sl.sales_amount) asc) as R
FROM gold.fact_sales as sl
LEFT JOIN gold.dim_products as pr
ON sl.product_key = pr.product_key
group by pr.product_name) as t
Where R <= 5

--WHICH 10 CUSTOMERS HAVE GENERATED THE HIGHEST REVENUE
SELECT customer_name, Total_Amount
From(
SELECT cs.first_name as customer_name, SUM(sl.sales_amount) as Total_Amount, 
DENSE_RANK() OVER (Order by SUM(sl.sales_amount) desc) as R
FROM gold.fact_sales as sl
LEFT JOIN gold.dim_customers as cs
ON sl.customer_key = cs.customer_key
group by cs.first_name) as t
Where R <= 10

--WHICH 3 CUSTOMERS HAS THE LEAST ORDERS PLACED
SELECT customer_name, Total_Orders
From(
SELECT cs.first_name as customer_name, COUNT(DISTINCT(sl.order_number)) as Total_Orders, 
DENSE_RANK() OVER (Order by COUNT(DISTINCT(sl.order_number)) asc) as R
FROM gold.fact_sales as sl
LEFT JOIN gold.dim_customers as cs
ON sl.customer_key = cs.customer_key
group by cs.first_name) as t
Where R <= 3
