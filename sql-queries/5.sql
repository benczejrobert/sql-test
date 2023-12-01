select * 
from sales_db.sales
order by sales.s_product_id asc;

SELECT 
						ss.s_product_id,
						-- YEAR(ss.sale_date) AS year,
						MONTH(ss.sale_date) AS month,
						SUM(ss.quantity) AS total_quantity
					FROM 
						sales_db.sales ss
					WHERE 
						ss.sale_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
					GROUP BY 
						month, ss.s_product_id;
                        
                        
                        
-- TRY THIS https://stackoverflow.com/questions/7745609/sql-select-only-rows-with-max-value-on-a-column
SELECT 
                    -- sub.year,
                    sub.s_product_id,
                    sub.month,
                    MAX(sub.total_quantity) AS quantity
                    
	FROM -- Get the total monthly quantities for each product id in sales during the last year.
	(                
					SELECT 
						ss.s_product_id,
						-- YEAR(ss.sale_date) AS year,
						MONTH(ss.sale_date) AS month,
						SUM(ss.quantity) AS total_quantity
					FROM 
						sales_db.sales ss
					WHERE 
						ss.sale_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
					GROUP BY 
						month, ss.s_product_id
	) sub
GROUP BY sub.month;
-- having sub.s_product_id = ss.s_product_id ;