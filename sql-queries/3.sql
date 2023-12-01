SELECT 
    main.year,
    main.month,
    p.product_name,
    main.max_quantity AS total_quantity
FROM 
    (
        -- Subquery from Step 2
        SELECT 
            year, month, MAX(total_quantity) AS max_quantity
        FROM 
            (
                -- Subquery from Step 1
                SELECT 
                    YEAR(ss.sale_date) AS year,
                    MONTH(ss.sale_date) AS month,
                    ss.product_id,
                   -- pp.product_name,
                    SUM(ss.quantity) AS total_quantity
                FROM 
                    sales_db.sales ss
--                JOIN 
--                    sales_db.products pp ON ss.s_product_id = pp.product_id
                WHERE 
                    ss.sale_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
                GROUP BY 
                    year, month, ss.product_id,
            ) sub
        GROUP BY 
            year, month
    ) main
JOIN 
    (
        -- Subquery from Step 1
        SELECT 
            YEAR(ss.sale_date) AS year,
            MONTH(ss.sale_date) AS month,
            pp.product_name,
            SUM(ss.quantity) AS total_quantity
        FROM 
            sales_db.sales ss
        JOIN 
            sales_db.products pp ON ss.s_product_id = pp.product_id
        WHERE 
            ss.sale_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 YEAR) AND CURDATE()
        GROUP BY 
            year, month, pp.product_name
    ) subquery
ON 
    main.year = subquery.year
    AND main.month = subquery.month
    AND main.max_quantity = subquery.total_quantity
JOIN 
    sales_db.products p ON subquery.product_name = p.product_name
