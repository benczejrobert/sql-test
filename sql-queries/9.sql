WITH sub AS (                
    SELECT 
        ss.s_product_id,
        YEAR(ss.sale_date) AS year,
        MONTH(ss.sale_date) AS month,
        SUM(ss.quantity) AS total_quantity
    FROM 
        sales_db.sales ss
    WHERE 
        YEAR(ss.sale_date) = '2022'
    GROUP BY 
        year, month, ss.s_product_id
)

SELECT 
    main.month, 
    main.quantity, 
    pp.product_name, 
    pp.product_id
FROM 
    ( 
    SELECT 
        sub.s_product_id,
        sub.year,
        sub.month,
        MAX(sub.total_quantity) AS quantity
    FROM sub
    GROUP BY sub.year, sub.month
    ) main 
INNER JOIN sales_db.products pp ON main.s_product_id = pp.product_id;
