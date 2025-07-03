/*
The taste of the world cafe has just debuted a new menu at the start of the year, and I have been 
asked to dig into the customer data to see:
1. Which menu items are doing well versus which are not.
2. What the top customers seem to like better.

Objective: digging into two tables: menu items and order details in order to
1. Explore the menu items table to get an idea of what's going on with the new menu.
2. Explore the order details table to get an idea of the data that has been collected on all 
the customer transactions.
3. Use both the tables together to better understand how customers are reacting to the new menu.
*/

# OBJECTIVE 1: EXPLORE THE ITEMS TABLE
USE restaurant_db;

-- 1. View the menu_items table.
SELECT *
FROM menu_items;

-- 2. Fine the number of items on the menu.
SELECT COUNT(*)
FROM menu_items;
-- There are 32 items on the menu.

-- 3. What are the least and most expensive items on the menu?
# Least expensive
SELECT * 
FROM menu_items
ORDER BY price;
-- Least expensive item is Edamame which is 5 dollars.

# Most expensive
SELECT *
FROM menu_items
ORDER BY price DESC;
-- Most expensive item is Shrimp Scampi which is 19.95 dollars.

-- 4. How many Italian dishes are on the menu?
SELECT COUNT(*)
FROM menu_items
WHERE category = 'Italian';  # We are filtering the data using 'WHERE' clause.
-- There are 9 Italian dishes.

# Least expensive Italian dish
SELECT *
FROM menu_items
WHERE category = 'Italian'
ORDER BY price;
-- The least expensive Italian dish is Spaghetti which is 14.50 dollars.

# Most expensive Italian dish
SELECT *
FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC;
-- The most expensive Italian dish is Shrimp Scampi which is 19.95 dollars.

-- 5. How many dishes are in each category?
SELECT category, COUNT(menu_item_id) AS num_dishes
FROM menu_items
GROUP BY category;

# Note: whenever we do a GROUP BY (whatever we put in GROUP BY) it also has to be present in the SELECT statement.
# Also, we have to decide how we want to aggreggate all of the these rows. So, for each category, we want to know
# how many dishes (or rows) there are within the category.
-- American: 6, Asian: 8, Mexican: 9 and Italian: 9.

-- 6. What is the average dish price within each category?
SELECT category, AVG(price) AS avg_price
FROM menu_items
GROUP BY category;
-- Italian dishes are most expensive whereas American dishes are affordable.

-- -------------------------------------------------------------------------------------------------------------------

# OBJECTIVE 2: EXPLORE THE ORDERS TABLE

-- 7. View the order_details table
SELECT *
FROM order_details;
# PRIMARY KEY: unique identifier of our table is order_details_id.

-- 8. What is the date range of the table?
SELECT * 
FROM order_details
ORDER BY order_date;
-- Lowest order date: 1st January 2023 and Highest order date: 31st March 2023.

# Another way to look at the date range of the table:
SELECT MIN(order_date), MAX(order_date)
FROM order_details;
# This also gives us the full date range of our table.

-- 9. How many orders were made within this date range?
# To find the number of orders, we can't just count the number of rows in order_id column, we have to find to find
# the number of unique orders that were made
SELECT COUNT(DISTINCT order_id) 
FROM order_details;
-- There were 5370 unique orders that were made.

-- 10. How many items were ordered within this date range?
SELECT COUNT(*)
FROM order_details;
-- There were 12234 orders ordered within this date range.

-- 11. Which orders had the most number of items?
SELECT order_id, COUNT(item_id) AS num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items DESC
LIMIT 1;
-- Order_id 330 had most number of items with 14 dishes.

-- 12. How many orders has more than 12 items?
SELECT COUNT(*)
FROM
	(SELECT order_id, COUNT(item_id) AS num_items
	FROM order_details
	GROUP BY order_id
	HAVING num_items > 12) AS num_orders;
# HAVING clause allows you to filter on aggregations from your GROUP BY
# So, there were 20 orders that had more than 12 items. We were ble to do that using the GROUP BY and then adding on 
# a HAVING clause to filter that and then creating a sub-query off of that and wrtiting a COUNT around that sub-query
# to count the number of rows.
-- There were 20 orders that had more than 12 items.

-- -------------------------------------------------------------------------------------------------------------------

# OBJECTIVE 3: ANALYZE CUSTOMER BEHAVIOUR

-- 13. Combine the menu_items and order_details tables into a single table
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id;
# We are joining order_details with the menu_items. Typically, when we are joining two tables the first thing we should
# list is the transaction table (typically be details about everything that has happened or every sale that's happened)
# menu_items is the look up table because that table doesn't have information about every transaction instead it has 
# details about each menu item.
# After that, we need to specify what we need to join on, which means what are fields that the two tables have in
# common. The reason why we did a left join is because we want to keep all the rows in order_details table and just
# add on all the details in the menu_items table.

-- 14. What were the least and most ordered items? What categories were they in?
SELECT item_name, category, COUNT(order_details_id) AS num_purchases
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
GROUP BY item_name, category
ORDER BY num_purchases;
-- The Chicken Tacos in Mexican was least ordered and Hamburger in Americanis most ordered item.

-- 15. What were the top 5 orders that spent the most money?
SELECT order_id, SUM(price) AS total_spent
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
GROUP BY order_id
ORDER BY total_spent DESC
LIMIT 5;
-- The order ids are: 440, 2075, 1957, 330, 2675.

-- 16. View the details of the highest spend order. What insights can you gather?
SELECT category, COUNT(item_id) as num_items
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id = 440
GROUP BY category;
-- The highest spent order bought a lot of Italian items and not so many of the rest.
-- So, even though the Italian dishes weren't the most popular items on the menu, it looks like highest spent order
-- has alot of Italian food so maybe that is something that we should be keeping on the menu.

-- 17. View the details of the top 5 highest spend orders. What insights do you gather?
SELECT category, COUNT(item_id) as num_items
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY category;
-- We can see that the top 5 highest spent orders are ordering more Italian food, than all the other types of food.

# Let's also separate this out for each specific order
SELECT order_id, category, COUNT(item_id) as num_items
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY order_id, category;
-- So, the insight that we have gathered here is that we should keep the expensive Italian dishes on the menu because
-- people seem to be ordering them alot, especially from the highest spent customers.