
-- views.sql
-- Sample Views for Ecommerce Schema (Postgres 17)

-- 1. View: product_with_category
CREATE OR REPLACE VIEW product_with_category AS
SELECT 
    p.product_id,
    p.name AS product_name,
    c.name AS category_name,
    p.price,
    p.rating
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id;

-- 2. View: customer_order_summary
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT 
    cu.customer_id,
    cu.full_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
GROUP BY cu.customer_id;

-- 3. View: product_inventory_status
CREATE OR REPLACE VIEW product_inventory_status AS
SELECT
    p.product_id,
    p.name,
    i.stock,
    CASE 
        WHEN i.stock = 0 THEN 'OUT OF STOCK'
        WHEN i.stock < 10 THEN 'LOW STOCK'
        ELSE 'IN STOCK'
    END AS stock_status
FROM products p
LEFT JOIN inventory i ON i.product_id = p.product_id;

-- 4. View: top_rated_products
CREATE OR REPLACE VIEW top_rated_products AS
SELECT 
    p.product_id,
    p.name,
    p.rating
FROM products p
WHERE p.rating >= 4.5
ORDER BY p.rating DESC;

