
    -- This trigger could also be done to just forbid this action and warn the seller (like a constraint)
    -- to update the old record or to insert a different unit price (i.e. the prior one).
DELIMITER //
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
    
        -- If a prior row exists, update the unit_price of the currently inserted row
        IF prior_unit_price IS NOT NULL THEN
            SET NEW.unit_price = prior_unit_price;
        END IF;
    END;
// 
DELIMITER;