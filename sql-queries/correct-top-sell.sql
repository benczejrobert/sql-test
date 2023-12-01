WITH sub AS ( -- refer to the totalmonthly quantity as `sub` to have cleaner queries
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
    (sub.month,sub.total_quantity) IN -- force rows integrity, because just applying max on the monthly groups from `sub` will mix some product ids with wrong quantities 
    -- I read that this is an issue with SQL that was fixed in newer versions
		( SELECT sub.month, MAX(sub.total_quantity)
		  FROM sub
		  GROUP BY sub.month
		) 
	) main
 INNER JOIN sales_db.products pp ON main.s_product_id = pp.product_id;

