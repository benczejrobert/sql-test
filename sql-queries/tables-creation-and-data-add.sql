create database sales_db;
drop database sales_db;

use sales_db;
-- customers, products, sales



INSERT INTO sales_db.products(product_name,category)
VALUES (`b`, `b`) ;

select * from sales_db.products ;

CREATE TABLE sales_db.products (
	product_id INT PRIMARY KEY NOT NULL auto_increment,
	product_name VARCHAR (255) NOT NULL,
	category VARCHAR (255) NOT NULL
);

CREATE TABLE sales_db.customers (
	customer_id INT PRIMARY KEY,
	full_name VARCHAR (255) NOT NULL,
	country VARCHAR (255) NOT NULL
);

CREATE TABLE sales_db.sales (
sale_id INT PRIMARY KEY NOT NULL auto_increment,
unit_price FLOAT NOT NULL,
quantity FLOAT NOT NULL, -- float because some products can be sold in kg
sale_date DATE NOT NULL,
	FOREIGN KEY (s_customer_id) 
        REFERENCES sales_db.customers (customer_id) 
        ON UPDATE CASCADE,
	FOREIGN KEY (s_product_id) 
        REFERENCES sales_db.products (product_id) 
        ON UPDATE CASCADE
); -- TODO maybe add a trigger or a stored procedure that runs every time data is inserted into sales to calculate a new column, sale_value (unit_price * quantity) 
-- sales should not be deleted on cascade for accounting purposes, 
-- so even if a client deleted their account, their personal data
--  is no longer available in this 

-- unit price should be in products to respect normalization and avoid possible inconsistencies 
-- (i.e. product with ID = 1 to have 2 different prices in the same day)

-- quantity should be in sales because it is sale-dependant

-- TODO checkif join is faster than select from ... select (e.g. i want to select the customers that are in the top 10% revenue thingy, I can select + aggregate on the sales without a join and then select in select OR I can join and filter)

select * from sales_db.sales;

SELECT p.category, SUM(s.unit_price * s.quantity) AS total_revenue -- total revenue per categ
FROM sales_db.sales s
JOIN sales_db.products p ON s.s_product_id = p.product_id
WHERE s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY p.category;

SELECT *
FROM sales_db.sales
WHERE sale_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);