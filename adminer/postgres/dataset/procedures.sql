
-- procedures.sql
-- Sample Stored Procedures for Ecommerce Schema (Postgres 17)

-- 1. Procedure: update_inventory_after_order
CREATE OR REPLACE FUNCTION update_inventory_after_order(in_order_id BIGINT)
RETURNS VOID AS $$
BEGIN
    UPDATE inventory i
    SET stock = stock - oi.quantity
    FROM order_items oi
    WHERE oi.order_id = in_order_id
    AND oi.product_id = i.product_id;
END;
$$ LANGUAGE plpgsql;


-- 2. Procedure: add_product_review
CREATE OR REPLACE FUNCTION add_product_review(
    in_customer_id BIGINT,
    in_product_id BIGINT,
    in_rating INT,
    in_review_text TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO reviews (customer_id, product_id, rating, review_text, review_date)
    VALUES (in_customer_id, in_product_id, in_rating, in_review_text, NOW());

    -- Update product rating
    UPDATE products p
    SET rating = (
        SELECT ROUND(AVG(r.rating), 2)
        FROM reviews r
        WHERE r.product_id = in_product_id
    )
    WHERE p.product_id = in_product_id;
END;
$$ LANGUAGE plpgsql;


-- 3. Procedure: record_pageview
CREATE OR REPLACE FUNCTION record_pageview(
    in_customer_id BIGINT,
    in_product_id BIGINT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO analytics_pageviews (customer_id, product_id, viewed_at)
    VALUES (in_customer_id, in_product_id, NOW());
END;
$$ LANGUAGE plpgsql;


-- 4. Procedure: create_order_with_items
CREATE OR REPLACE FUNCTION create_order_with_items(
    in_customer_id BIGINT,
    in_total_amount NUMERIC,
    in_items JSON
)
RETURNS BIGINT AS $$
DECLARE
    new_order_id BIGINT;
    item JSON;
BEGIN
    -- Create order
    INSERT INTO orders(customer_id, total_amount, created_at)
    VALUES (in_customer_id, in_total_amount, NOW())
    RETURNING order_id INTO new_order_id;

    -- Insert order items (expects JSON array of objects: [{product_id, quantity, price}])
    FOR item IN SELECT * FROM json_array_elements(in_items)
    LOOP
        INSERT INTO order_items(order_id, product_id, quantity, price)
        VALUES (
            new_order_id,
            (item->>'product_id')::BIGINT,
            (item->>'quantity')::INT,
            (item->>'price')::NUMERIC
        );
    END LOOP;

    -- Update inventory
    PERFORM update_inventory_after_order(new_order_id);

    RETURN new_order_id;
END;
$$ LANGUAGE plpgsql;

