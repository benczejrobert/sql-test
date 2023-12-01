 -- TODO checkif I can subtract 1 just from the year and make the interval [2022-2023) not (2022.08 - 2023.08)
-- top selling product in terms of quanity



SELECT 
						ss.s_product_id,
						YEAR(ss.sale_date) AS year,
						MONTH(ss.sale_date) AS month,
						SUM(ss.quantity) AS total_quantity
					FROM 
						sales_db.sales ss
					WHERE 
						year(ss.sale_date) = '2022'
						-- ss.sale_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
					GROUP BY 
						year, month, ss.s_product_id;

	with sub as (                
					SELECT 
						ss.s_product_id,
						YEAR(ss.sale_date) AS year,
						MONTH(ss.sale_date) AS month,
						SUM(ss.quantity) AS total_quantity
					FROM 
						sales_db.sales ss
					WHERE 
						year(ss.sale_date) = '2022'
						-- ss.sale_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
					GROUP BY 
						year, month, ss.s_product_id
	) 

SELECT main.month, main.quantity, pp.product_name, pp.product_id
FROM 
( 
SELECT sub.s_product_id,
                    sub.year,
                    sub.month,
                    MAX(sub.total_quantity) AS quantity
	FROM -- Get the total monthly quantities for each product id in sales during the last year.
sub
GROUP BY sub.year, sub.month
) main 
inner JOIN sales_db.products pp ON main.s_product_id = pp.product_id;


	with sub as (                
					SELECT 
						ss.s_product_id,
						YEAR(ss.sale_date) AS year,
						MONTH(ss.sale_date) AS month,
						SUM(ss.quantity) AS total_quantity
					FROM 
						sales_db.sales ss
					WHERE 
						year(ss.sale_date) = '2022'
						-- ss.sale_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
					GROUP BY 
						year, month, ss.s_product_id
	) 

SELECT main.month, main.quantity, pp.product_name, pp.product_id
FROM sub inner join -- find the max monthly quantity
( 
SELECT sub.s_product_id,
                    sub.year,
                    sub.month,
                    MAX(sub.total_quantity) AS quantity
	FROM -- Get the total monthly quantities for each product id in sales during the last year.
sub
GROUP BY sub.year, sub.month
) main on sub.s_product_id = main.s_product_id and sub.total_quantity = main.quantity and sub.month = main.month
inner JOIN sales_db.products pp ON main.s_product_id = pp.product_id; -- sub.s_product_id = main.s_product_id filters out product id 2 which should have been 1. this does not ensure correct grouping




SELECT a.id, a.rev, a.contents
FROM YourTable a
INNER JOIN (
    SELECT id, MAX(rev) rev
    FROM YourTable
    GROUP BY id
) b ON a.id = b.id AND a.rev = b.rev;