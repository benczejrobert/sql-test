import mysql.connector
import numpy as np
from mysql.connector import Error
import matplotlib.pyplot as plt
print(matplotlib.__version__)

# Create the tables with the requested columns.
# Create an additional trigger because the sales table contains redundancies
# - the data model is not in its highest normal form, it could be better normalized if the unit price would be in the
# products table. However, this approach does not allow for price modification (e.g. inflation).

# This is because, if the price would change in the product dimension table, it would also affect the prices of the
# previous transactions in the sales fact table.

table_queries = [
    """
    CREATE TABLE sales_db.products (
	product_id BIGINT PRIMARY KEY NOT NULL auto_increment,
	product_name VARCHAR (255) NOT NULL,
	category VARCHAR (255) NOT NULL
    );
    """,

    """
    CREATE TABLE sales_db.customers (
	customer_id BIGINT PRIMARY KEY,
	full_name VARCHAR (255) NOT NULL,
	country VARCHAR (255) NOT NULL
    );
    """,
    """
    CREATE TABLE sales_db.sales (
    sale_id BIGINT PRIMARY KEY NOT NULL auto_increment,
    unit_price FLOAT NOT NULL,
    quantity FLOAT NOT NULL, -- float because some products can be sold in kg
    sale_date DATE NOT NULL,
    s_customer_id BIGINT,
        FOREIGN KEY (s_customer_id) 
            REFERENCES sales_db.customers (customer_id) 
            ON UPDATE CASCADE,
    s_product_id BIGINT,
        FOREIGN KEY (s_product_id) 
            REFERENCES sales_db.products (product_id) 
            ON UPDATE CASCADE
    );
    """,

    ## -- This trigger could also be done to just forbid this action and warn the seller (like a constraint)
    ## -- to update the old record or to insert a different unit price (i.e. the prior one).


    ## Current implementation: If a prior row exists, update the unit_price of the currently inserted row
    """    
    CREATE TRIGGER update_unit_price_trigger
    BEFORE INSERT ON sales_db.sales
    FOR EACH ROW
    BEGIN
        DECLARE prior_unit_price FLOAT;
        
        -- Find the prior row with the same product_id and sale_date
        SELECT unit_price INTO prior_unit_price
        FROM sales_db.sales
        WHERE s_product_id = NEW.s_product_id
          AND sale_date = NEW.sale_date
        ORDER BY sale_id DESC
        LIMIT 1;
        IF prior_unit_price IS NOT NULL THEN
            SET NEW.unit_price = prior_unit_price;
        END IF;
    END;
    """
]

questions_queries = [
    # -- last 365 days can be done by where condition: ss.sale_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
    ["Total revenue per category:\n",
     """
    SELECT p.category, SUM(s.unit_price * s.quantity) AS total_revenue -- total revenue per category
    FROM sales_db.sales s
    JOIN sales_db.products p ON s.s_product_id = p.product_id
    WHERE year(s.sale_date) = '2022'
    GROUP BY p.category;
    """],
    # (1st query) refer to the total monthly quantity as `sub` to have cleaner queries
    # (2nd query) force rows integrity, because just applying max on the monthly groups from `sub` will
    # mix some product ids with wrong quantities- I read that this is an issue with SQL that was fixed in newer versions
    ["Monthly top-selling products:\n","""
    WITH sub AS (
    SELECT 
        ss.s_product_id,
        YEAR(ss.sale_date) AS year,
        MONTH(ss.sale_date) AS month,
        SUM(ss.quantity) AS total_quantity
    FROM 
        sales_db.sales ss
    WHERE 
        YEAR(ss.sale_date) = '2022' -- last year, not last 365 days
    GROUP BY 
        year, month, ss.s_product_id
    )
    
    select * from 
        (SELECT * 
        FROM sub 
        WHERE 
        (sub.month,sub.total_quantity) IN 
            ( SELECT sub.month, MAX(sub.total_quantity)
              FROM sub
              GROUP BY sub.month
            ) 
        ) main
     INNER JOIN sales_db.products pp ON main.s_product_id = pp.product_id;

    """],

    # -- return the customers that generate more revenue than 90% of all the customers from year 2022
    ["Top 10 percentile customers in terms of revenue:\n",""" 
        select                  
                sub.revenue,
                sub.percentile,
                cc.customer_id,
                cc.full_name
                from 
                    (
                    SELECT 				
                            ss.s_customer_id,
                            sum(ss.unit_price * ss.quantity) revenue,
                            year(ss.sale_date) yr,
                            PERCENT_RANK() OVER(
                            ORDER BY sum(ss.unit_price * ss.quantity) desc) * 100 AS percentile
                        FROM 
                            sales_db.sales ss
                        where year(ss.sale_date) = '2022'
                        GROUP BY ss.s_customer_id
                    ) sub
        inner join sales_db.customers cc on sub.s_customer_id = cc.customer_id
        where percentile < 10;
    """]
]

# These functions dynamically create queries to insert data into the tables of the database.

def insert_into_products(param_product_name,param_category):
    query = f"""
    INSERT INTO `sales_db`.`products` (`product_name`, `category`) 
    VALUES ('{param_product_name}', '{param_category}');
    """
    return query

def insert_into_customers(customer_id,full_name,country):
    query = f"""
    INSERT INTO `sales_db`.`customers` (`customer_id`, `full_name`, `country`)
     VALUES ('{customer_id}', '{full_name}', '{country}');
    """
    return query

def insert_into_sales(unit_price,quantity,sale_date,s_customer_id,s_product_id):
    query = f"""
    INSERT INTO `sales_db`.`sales` (`unit_price`, `quantity`, `sale_date`, `s_customer_id`, `s_product_id`) 
    VALUES ('{unit_price}', '{quantity}', '{sale_date}', '{s_customer_id}', '{s_product_id}');
    """
    return query


