-- select sale id
-- select customer id
-- select qty
-- unit price

-- top 10% in generating revenue in 2022 - is it their sum is above 90% of all the revenue?
-- or is it that they bring more revenue than 90% of clients? - e varianta asta ca prima varianta ar insemna sa aduca unii 90k si altii sa aduca restu de 10k - not feasible


-- https://www.sqlshack.com/calculate-sql-percentile-using-the-sql-server-percent_rank-function/
select                  
						sub.revenue,
                        sub.percentile,
                        cc.customer_id,
                        cc.full_name
                        from 
							(
							SELECT 				
													-- ss.sale_id,
													ss.s_customer_id,
                                                    sum(ss.unit_price * ss.quantity) revenue,
                                                    year(ss.sale_date) yr,
                                                    PERCENT_RANK() OVER(
													ORDER BY sum(ss.unit_price * ss.quantity) desc) * 100 AS percentile
												FROM 
													sales_db.sales ss
												-- where year(ss.sale_date) = '2022'
                                                GROUP BY ss.s_customer_id
							) sub
inner join sales_db.customers cc on sub.s_customer_id = cc.customer_id
where percentile < 10;



SELECT 				
													-- ss.sale_id,
													ss.s_customer_id,
                                                    sum(ss.unit_price * ss.quantity) revenue,
                                                    year(ss.sale_date) yr,
                                                    PERCENT_RANK() OVER(
													ORDER BY sum(ss.unit_price * ss.quantity) desc) AS percentile
												FROM 
													sales_db.sales ss
												where year(ss.sale_date) = '2022'
                                                GROUP BY ss.s_customer_id;


select                       
						sub.s_customer_id,
						sub.revenue,
                        PERCENT_RANK() OVER(
                        ORDER BY sub.revenue desc) AS percentile
                        from 
							(
							SELECT 				
													-- ss.sale_id,
													sum(ss.unit_price * ss.quantity) revenue,
													ss.s_customer_id,
                                                    year(ss.sale_date) yr
												FROM 
													sales_db.sales ss
												where year(ss.sale_date) = '2022'
                                                GROUP BY ss.s_customer_id
							) sub 