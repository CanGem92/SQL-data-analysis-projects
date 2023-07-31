--https://bit.io/emiliano/Capstone_Project

-- How many customers do we have in the data? 795
SELECT COUNT(*) AS number_of_customers
FROM customers;

-- What was the city with the most profit for the company in 2015? New York City, New York (14753)
SELECT EXTRACT(year FROM order_date) AS year, 
       CONCAT(shipping_city,', ',shipping_state) AS shipping_city, 
       SUM(order_profits) AS order_profits
FROM orders o
JOIN order_details od
USING (order_id)
WHERE order_date BETWEEN '2015-01-01' AND '2016-01-01'
GROUP BY 1, 2
ORDER BY order_profits DESC
LIMIT 1;
      
-- How many different cities do we have in the data? 604
SELECT COUNT(DISTINCT shipping_city||shipping_state) AS number_of_cities
FROM orders o

--Show the total spent by customers from low to high. (456)
SELECT customer_id, SUM(order_sales) AS amount_spent
FROM customers c
JOIN orders o
USING (customer_id)
JOIN order_details od
USING (order_id)
GROUP BY customer_id
ORDER BY 2; 

--What is the most profitable city in the State of Tennessee? Lebanon
SELECT shipping_city, shipping_state, 
       SUM(order_profits) AS order_profits
FROM orders o
JOIN order_details
USING (order_id)
WHERE shipping_state = 'Tennessee'
GROUP BY shipping_city, shipping_state
ORDER BY 3 DESC
LIMIT 1;

----What’s the average annual profit for that city across all years? 27.67
WITH lebanons_yearly_profits AS 
			(SELECT shipping_city|| ', ' || shipping_state AS shipping_city,
                             SUM(order_profits) AS order_profits
                      FROM orders o
                      JOIN order_details
                      USING (order_id)
                      WHERE shipping_city = 'Lebanon' AND shipping_state = 'Tennessee'
                      GROUP BY 1, EXTRACT(year FROM order_date))
SELECT shipping_city, 
       ROUND(AVG(order_profits),2) AS lebanon_avg_profit
FROM lebanons_yearly_profits
GROUP BY shipping_city;

--What is the distribution of customer types in the data? (410)
SELECT customer_segment, COUNT(*) AS number_of_customers
FROM customers
GROUP BY customer_segment;

--What’s the most profitable product category on average in Iowa across all years? Furniture
WITH iowa_profits AS 
              (SELECT shipping_state, product_category,  
                      EXTRACT('year' FROM order_date) AS year, 
                      SUM(order_profits) AS profits
               FROM orders o
               JOIN order_details od
               USING (order_id)
               JOIN product
               USING (product_id)
               WHERE shipping_state = 'Iowa'
               GROUP BY shipping_state, product_category, year)
SELECT shipping_state, product_category, 
       ROUND(AVG(profits),2) as avg_profits
FROM iowa_profits
GROUP BY shipping_state, product_category
ORDER BY avg_profits DESC;

--What is the most popular product in that category across all states in 2016? Global Push Button Manager's Chair, Indigo
SELECT product_name, SUM(quantity) AS quantity
FROM orders o
JOIN order_details od
USING (order_id)
JOIN product
USING (product_id)
WHERE product_category = 'Furniture' AND 
      order_date BETWEEN '2016-01-01' AND '2017-01-01'
GROUP BY product_name
ORDER BY quantity DESC;

--Which customer got the most discount in the data? (in total amount) 687
SELECT customer_id, 
       ROUND(SUM((order_discount*order_sales)/(1-order_discount))::numeric, 2) AS total_discount
FROM orders o
JOIN order_details od
USING (order_id)
JOIN customers
USING (customer_id)
GROUP BY customer_id
ORDER BY total_discount DESC;

--How widely did monthly profits vary in 2018? (-5525)
WITH "2018_profit" AS 
              (SELECT TO_CHAR(order_date,'YYYY-MM') AS month, 
                      SUM(order_profits) AS profit
               FROM orders o
               JOIN order_details od
               USING (order_id)
               WHERE order_date BETWEEN '2018-01-01' AND '2019-01-01'
               GROUP BY month)
SELECT month, profit, 
       profit - LAG(profit,1,0) OVER(ORDER BY month) AS monthly_diff
FROM "2018_profit";

--alternatively
SELECT TO_CHAR(order_date,'YYYY-MM') AS month, 
       SUM(order_profits) AS profit,
       SUM(order_profits) - LAG(SUM(order_profits),1,0) 
                            OVER(ORDER BY TO_CHAR(order_date,'YYYY-MM')) AS monthly_diff
FROM orders o
JOIN order_details od
USING (order_id)
WHERE order_date BETWEEN '2018-01-01' AND '2019-01-01'
GROUP BY month

--Which order was the highest in terms of sales 2015? CA-2015-145317
SELECT od.order_id, SUM(order_sales) AS sales
FROM orders o
JOIN order_details od
USING (order_id)
WHERE order_date BETWEEN '2015-01-01' AND '2016-01-01'
GROUP BY od.order_id
ORDER BY sales DESC
LIMIT 1;

--What was the rank of each city in the East region in 2015? Columbus
SELECT shipping_city, SUM(quantity) AS amount, 
       RANK() OVER(ORDER BY SUM(quantity) DESC)
FROM orders o
JOIN order_details od
USING (order_id)
WHERE order_date BETWEEN '2015-01-01' AND '2016-01-01'
       AND shipping_region = 'East'
GROUP BY shipping_city;

--Display customer names for customers who are in the segment ‘Consumer’ or ‘Corporate.’ How many customers are there in total? 647
SELECT customer_id, customer_name, 
       COUNT(*) OVER () AS number_of_customers
FROM customers
WHERE customer_segment IN ('Consumer','Corporate');

--Calculate the difference between the largest and smallest order quantities for product id ‘100.’ 4
SELECT MAX(quantity) AS max_quantity, MIN(quantity) AS min_quantity, 
       MAX(quantity) - MIN(quantity) AS difference
FROM order_details
WHERE product_id = 100;

--Calculate the percent of products that are within the category ‘Furniture.’ 20.54%
SELECT product_category, 
       ROUND(100*COUNT(*)/(SELECT COUNT(*) FROM product)::numeric,2) AS percentage
FROM product
WHERE product_category = 'Furniture'
group by product_category;

--alternative
SELECT ROUND(100*AVG(CASE 
              WHEN product_category = 'Furniture' THEN 1 ELSE 0 END), 2) 
              AS percentage_of_furniture
FROM product;

--Find the number of products per manufacturer.  8
SELECT product_manufacturer, COUNT(*) AS number_of_products
FROM product
GROUP BY product_manufacturer;

--Show the product_subcategory and the total number of products in the subcategory.
--Show the order from most to least products and then by product_subcategory name ascending. Paper
SELECT product_subcategory, COUNT(*) AS number_of_products
FROM product
GROUP BY product_subcategory
ORDER BY number_of_products DESC, product_subcategory;

--Show the product_id(s), the sum of quantities, where the total sum of its product quantities is greater than or equal to 100. (132)
SELECT p.product_id, SUM(quantity) AS tot_quantity
FROM order_details od
JOIN product p
USING(product_id)
GROUP BY p.product_id
HAVING SUM(quantity)>=100;

--Join all database tables into one dataset that includes all unique columns
SELECT *
FROM customers c
FULL JOIN orders o 
USING (customer_id)
FULL JOIN order_details od
USING (order_id)
FULL JOIN product p
USING (product_id);