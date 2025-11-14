# Ecommerce SQL Query Workbook — 200 Real Queries

This workbook contains **200 SQL queries** tailored to your ecommerce schema (Postgres 17 compatible).
Each entry includes:
- **SQL statement** ready to run against the schema included in your dumps,
- **Short explanation** of what it does and why it's useful.

Tables assumed: `categories`, `customers`, `products`, `inventory`, `orders`, `order_items`, `payments`, `cart`, `cart_items`, `reviews`, `analytics_pageviews`.

---


## 1. Get all customers
```sql
SELECT * FROM customers;
```
**Explanation:** Returns every row in `customers`. Good first check after import.

## 2. Get all products
```sql
SELECT * FROM products;
```
**Explanation:** Inspect product records and schema fields.

## 3. Get product names only
```sql
SELECT name FROM products;
```
**Explanation:** Quick list of product titles for sampling.

## 4. List all categories
```sql
SELECT * FROM categories;
```
**Explanation:** See categories and their IDs.

## 5. List products with price
```sql
SELECT product_id, name, price FROM products;
```
**Explanation:** Useful for price checks and sampling.

## 6. Sort products by price (ascending)
```sql
SELECT name, price FROM products ORDER BY price ASC;
```
**Explanation:** Find cheapest products first.

## 7. Sort products by price (descending)
```sql
SELECT name, price FROM products ORDER BY price DESC;
```
**Explanation:** Find premium/high-priced items quickly.

## 8. Limit results
```sql
SELECT * FROM products LIMIT 10;
```
**Explanation:** Inspect a small sample quickly.

## 9. Skip + Limit (pagination)
```sql
SELECT * FROM products OFFSET 10 LIMIT 10;
```
**Explanation:** Simple pagination technique.

## 10. Count total customers
```sql
SELECT COUNT(*) FROM customers;
```
**Explanation:** Verify number of customer rows imported.

## 11. Count products in each category
```sql
SELECT category_id, COUNT(*) AS total_products
FROM products
GROUP BY category_id;
```
**Explanation:** Category distribution check.

## 12. Find unique cities (if you store city) — example
```sql
SELECT DISTINCT country FROM customers;
```
**Explanation:** Shows countries of customers; adapt to `city` if present.

## 13. Get all orders
```sql
SELECT * FROM orders;
```
**Explanation:** Inspect orders table contents and timestamps.

## 14. Get orders placed today
```sql
SELECT * FROM orders
WHERE created_at::date = CURRENT_DATE;
```
**Explanation:** Daily operations check.

## 15. Find customers with email ending in gmail
```sql
SELECT * FROM customers WHERE email LIKE '%gmail.com';
```
**Explanation:** Useful for segmentation or contact filters.

## 16. Products cheaper than 500
```sql
SELECT * FROM products WHERE price < 500;
```
**Explanation:** Filter budget items.

## 17. Products between 500 and 2000
```sql
SELECT * FROM products WHERE price BETWEEN 500 AND 2000;
```
**Explanation:** Mid-range product segment.

## 18. Find out-of-stock items
```sql
SELECT p.product_id, p.name, p.stock
FROM products p
WHERE p.stock = 0;
```
**Explanation:** Inventory alert for restocking.

## 19. Get all reviews with rating > 4
```sql
SELECT * FROM reviews WHERE rating > 4;
```
**Explanation:** High-rated feedback for testimonials.

## 20. Find customers registered this month
```sql
SELECT * FROM customers
WHERE EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM CURRENT_DATE)
  AND EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM CURRENT_DATE);
```
**Explanation:** New-user acquisition monitoring.

## 21. Get products with category names
```sql
SELECT p.product_id, p.name, c.name AS category
FROM products p
JOIN categories c ON p.category_id = c.category_id;
```
**Explanation:** Human-readable product listing with category labels.

## 22. Get orders with customer names
```sql
SELECT o.order_id, c.full_name, c.email, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
```
**Explanation:** Join orders to customers for support or reporting.

## 23. Order items with product names
```sql
SELECT oi.order_id, p.name, oi.quantity, oi.price_at_purchase
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;
```
**Explanation:** See item-level details for each order.

## 24. Full order details (customer + items + product)
```sql
SELECT o.order_id, c.full_name, p.name AS product, oi.quantity, oi.price_at_purchase
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
```
**Explanation:** Comprehensive order export useful for fulfillment and audit.

## 25. Find reviews with customer names
```sql
SELECT r.review_id, r.rating, r.comment, c.full_name
FROM reviews r
JOIN customers c ON r.customer_id = c.customer_id;
```
**Explanation:** Contextualize reviews with user identity.

## 26. Inventory + product details
```sql
SELECT p.name, i.change_amount, i.reason, i.created_at
FROM inventory i
JOIN products p ON i.product_id = p.product_id
ORDER BY i.created_at DESC LIMIT 50;
```
**Explanation:** Recent inventory events and what changed.

## 27. Payments with order and customer info
```sql
SELECT pay.payment_id, pay.amount, o.order_id, c.full_name, pay.status
FROM payments pay
JOIN orders o ON pay.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id;
```
**Explanation:** Payment audit for reconciliation.

## 28. Cart with items and customer
```sql
SELECT c.cart_id, cu.full_name, p.name AS product, ci.quantity
FROM cart c
JOIN customers cu ON c.customer_id = cu.customer_id
JOIN cart_items ci ON ci.cart_id = c.cart_id
JOIN products p ON p.product_id = ci.product_id;
```
**Explanation:** Inspect cart contents for outreach or recovery emails.

## 29. Product analytics: number of pageviews
```sql
SELECT p.product_id, p.name, COUNT(a.pv_id) AS views
FROM products p
LEFT JOIN analytics_pageviews a ON p.product_id = a.product_id
GROUP BY p.product_id, p.name
ORDER BY views DESC
LIMIT 50;
```
**Explanation:** Top-viewed products for merchandising.

## 30. Orders with payment status
```sql
SELECT o.order_id, o.total_amount, pay.status AS payment_status
FROM orders o
LEFT JOIN payments pay ON pay.order_id = o.order_id;
```
**Explanation:** Shows payment state per order; may be NULL if no payment recorded.

## 31. Rank products by price
```sql
SELECT product_id, name, price,
       RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products;
```
**Explanation:** Rank products to locate top-tier items.

## 32. Dense rank for product ratings
```sql
SELECT product_id,
       AVG(rating) AS avg_rating,
       DENSE_RANK() OVER (ORDER BY AVG(rating) DESC) AS rating_rank
FROM reviews
GROUP BY product_id;
```
**Explanation:** Rank products by average rating with no gaps.

## 33. Running total of daily revenue
```sql
SELECT created_at::date AS day,
       SUM(total_amount) AS revenue,
       SUM(SUM(total_amount)) OVER (ORDER BY created_at::date) AS running_total
FROM orders
GROUP BY day
ORDER BY day;
```
**Explanation:** Cumulative revenue trend over time.

## 34. Top 5 highest-priced products per category
```sql
SELECT *
FROM (
    SELECT p.*,
           ROW_NUMBER() OVER (
               PARTITION BY category_id ORDER BY price DESC
           ) AS rn
    FROM products p
) t
WHERE rn <= 5;
```
**Explanation:** Per-category price leaders.

## 35. Customer order count with ranking
```sql
SELECT c.customer_id, c.full_name,
       COUNT(o.order_id) AS orders_count,
       RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS orders_rank
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;
```
**Explanation:** Identify frequent buyers.

## 36. Category-wise average price vs global average
```sql
SELECT c.name AS category,
       AVG(p.price) AS category_avg,
       AVG(AVG(p.price)) OVER () AS global_avg
FROM categories c
JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.name;
```
**Explanation:** Compare category price levels to overall average.

## 37. Most recent order per customer
```sql
SELECT DISTINCT ON (o.customer_id) o.customer_id, o.order_id, o.created_at
FROM orders o
ORDER BY o.customer_id, o.created_at DESC;
```
**Explanation:** Efficient per-customer latest order using DISTINCT ON (Postgres-specific).

## 38. Rolling 7-day revenue
```sql
SELECT created_at::date AS day,
       SUM(total_amount) AS revenue,
       SUM(SUM(total_amount)) OVER (
           ORDER BY created_at::date
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) AS revenue_7_day
FROM orders
GROUP BY day
ORDER BY day;
```
**Explanation:** Seven-day moving revenue for smoothing volatility.

## 39. Pageviews ranking by customer (recent views)
```sql
SELECT customer_id, product_id, viewed_at,
       ROW_NUMBER() OVER (
           PARTITION BY customer_id ORDER BY viewed_at DESC
       ) AS recent_rank
FROM analytics_pageviews;
```
**Explanation:** Get most recent views per user for personalization.

## 40. Revenue difference between consecutive days
```sql
SELECT day,
       revenue,
       revenue - LAG(revenue) OVER (ORDER BY day) AS difference
FROM (
    SELECT created_at::date AS day,
           SUM(total_amount) AS revenue
    FROM orders
    GROUP BY day
) x;
```
**Explanation:** Day-over-day revenue delta.

## 41. Products above average price
```sql
SELECT *
FROM products
WHERE price > (SELECT AVG(price) FROM products);
```
**Explanation:** Find premium items above global mean.

## 42. Customers who spent above average
```sql
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > (SELECT AVG(total_amount) FROM orders);
```
**Explanation:** Identify higher-than-average spenders.

## 43. Products with no reviews
```sql
SELECT *
FROM products
WHERE product_id NOT IN (SELECT product_id FROM reviews);
```
**Explanation:** Products lacking feedback—candidates for review solicitation.

## 44. Customers who placed at least 5 orders
```sql
SELECT customer_id, COUNT(*) AS orders_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 5;
```
**Explanation:** Loyal customers list.

## 45. Top 10 best-selling products (by units)
```sql
SELECT p.product_id, p.name, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY units_sold DESC
LIMIT 10;
```
**Explanation:** Identify top sellers for merchandising.

## 46. Category with the highest revenue
```sql
SELECT c.name, SUM(oi.quantity * oi.price_at_purchase) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.name
ORDER BY revenue DESC
LIMIT 1;
```
**Explanation:** Which category drives most sales.

## 47. Customer last purchase amount
```sql
SELECT o.customer_id, o.total_amount
FROM orders o
WHERE (o.customer_id, o.created_at) IN (
    SELECT customer_id, MAX(created_at)
    FROM orders
    GROUP BY customer_id
);
```
**Explanation:** Last order value per customer.

## 48. Orders where total > average order value
```sql
SELECT * FROM orders WHERE total_amount > (SELECT AVG(total_amount) FROM orders);
```
**Explanation:** Large orders detection for priority handling.

## 49. Cart conversion rate (simple)
```sql
WITH carts AS (SELECT DISTINCT customer_id FROM cart)
SELECT (SELECT COUNT(DISTINCT customer_id) FROM orders) * 1.0 / (SELECT COUNT(*) FROM carts) AS conversion_rate;
```
**Explanation:** Rough conversion metric: customers with carts → customers with orders.

## 50. Monthly revenue
```sql
SELECT DATE_TRUNC('month', created_at) AS month, SUM(total_amount) AS revenue
FROM orders
GROUP BY month
ORDER BY month;
```
**Explanation:** Monthly revenue time series.


## 51. Rank products by price (window)
```sql
SELECT product_id, name, price,
       RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products;
```
**Explanation:** Rank products to locate top-tier items.

## 52. Dense rank for product ratings
```sql
SELECT product_id,
       AVG(rating) AS avg_rating,
       DENSE_RANK() OVER (ORDER BY AVG(rating) DESC) AS rating_rank
FROM reviews
GROUP BY product_id;
```
**Explanation:** Rank products by average rating with no gaps.

## 53. Running total of daily revenue
```sql
SELECT created_at::date AS day,
       SUM(total_amount) AS revenue,
       SUM(SUM(total_amount)) OVER (ORDER BY created_at::date) AS running_total
FROM orders
GROUP BY day
ORDER BY day;
```
**Explanation:** Cumulative revenue trend over time.

## 54. Top 5 highest-priced products per category
```sql
SELECT *
FROM (
    SELECT p.*,
           ROW_NUMBER() OVER (
               PARTITION BY category_id ORDER BY price DESC
           ) AS rn
    FROM products p
) t
WHERE rn <= 5;
```
**Explanation:** Per-category price leaders.

## 55. Customer order count with ranking
```sql
SELECT c.customer_id, c.full_name,
       COUNT(o.order_id) AS orders_count,
       RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS orders_rank
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;
```
**Explanation:** Identify frequent buyers.

## 56. Category-wise average price vs global average
```sql
SELECT c.name AS category,
       AVG(p.price) AS category_avg,
       AVG(AVG(p.price)) OVER () AS global_avg
FROM categories c
JOIN products p ON p.category_id = c.category_id
GROUP BY c.category_id, c.name;
```
**Explanation:** Compare category price levels to overall average.

## 57. Most recent order per customer (DISTINCT ON)
```sql
SELECT DISTINCT ON (o.customer_id) o.customer_id, o.order_id, o.created_at
FROM orders o
ORDER BY o.customer_id, o.created_at DESC;
```
**Explanation:** Efficient per-customer latest order using DISTINCT ON.

## 58. Rolling 7-day revenue
```sql
SELECT created_at::date AS day,
       SUM(total_amount) AS revenue,
       SUM(SUM(total_amount)) OVER (
           ORDER BY created_at::date
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) AS revenue_7_day
FROM orders
GROUP BY day
ORDER BY day;
```
**Explanation:** Seven-day moving revenue for smoothing volatility.

## 59. Pageviews recent ranking per customer
```sql
SELECT customer_id, product_id, viewed_at,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY viewed_at DESC) AS recent_rank
FROM analytics_pageviews;
```
**Explanation:** Recent views per user for personalization.

## 60. Revenue difference between consecutive days
```sql
SELECT day,
       revenue,
       revenue - LAG(revenue) OVER (ORDER BY day) AS difference
FROM (
    SELECT created_at::date AS day,
           SUM(total_amount) AS revenue
    FROM orders
    GROUP BY day
) x;
```
**Explanation:** Day-over-day revenue delta.

## 61. Products above average price
```sql
SELECT *
FROM products
WHERE price > (SELECT AVG(price) FROM products);
```
**Explanation:** Find premium items above global mean.

## 62. Customers who spent above average
```sql
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > (SELECT AVG(total_amount) FROM orders);
```
**Explanation:** Identify higher-than-average spenders.

## 63. Products with no reviews
```sql
SELECT *
FROM products
WHERE product_id NOT IN (SELECT product_id FROM reviews);
```
**Explanation:** Products lacking feedback—candidates for review solicitation.

## 64. Customers with at least 5 orders
```sql
SELECT customer_id, COUNT(*) AS orders_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 5;
```
**Explanation:** Loyal customers list.

## 65. Top 10 best-selling products (units)
```sql
SELECT p.product_id, p.name, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY units_sold DESC
LIMIT 10;
```
**Explanation:** Identify top sellers for merchandising.

## 66. Category with the highest revenue
```sql
SELECT c.name, SUM(oi.quantity * oi.price_at_purchase) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.name
ORDER BY revenue DESC
LIMIT 1;
```
**Explanation:** Which category drives most sales.

## 67. Customer last purchase amount
```sql
SELECT o.customer_id, o.total_amount
FROM orders o
WHERE (o.customer_id, o.created_at) IN (
    SELECT customer_id, MAX(created_at)
    FROM orders
    GROUP BY customer_id
);
```
**Explanation:** Last order value per customer.

## 68. Orders > customer's average order value
```sql
SELECT *
FROM orders o
WHERE total_amount > (
    SELECT AVG(total_amount) FROM orders WHERE customer_id = o.customer_id
);
```
**Explanation:** Detect unusually large orders per customer.

## 69. Products in cart but never purchased
```sql
SELECT DISTINCT product_id
FROM cart_items
WHERE product_id NOT IN (SELECT product_id FROM order_items);
```
**Explanation:** Items that may require conversion tactics.

## 70. Customers who viewed a product but didn't buy it
```sql
SELECT DISTINCT a.customer_id
FROM analytics_pageviews a
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.product_id = a.product_id AND o.customer_id = a.customer_id
);
```
**Explanation:** Targets for remarketing campaigns.

## 71. Best review per customer (highest rating)
```sql
SELECT r.*
FROM reviews r
WHERE (r.customer_id, r.rating) IN (
    SELECT customer_id, MAX(rating) FROM reviews GROUP BY customer_id
);
```
**Explanation:** Each customer's top-rated review (may be multiple if tie).

## 72. Customers who only bought electronics (example)
```sql
SELECT customer_id FROM (
  SELECT o.customer_id, array_agg(DISTINCT p.category_id) AS cats
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  JOIN products p ON p.product_id = oi.product_id
  GROUP BY o.customer_id
) t
WHERE array_length(cats,1) = 1 AND cats[1] = (SELECT category_id FROM categories WHERE name='Electronics' LIMIT 1);
```
**Explanation:** Identifies customers whose purchases belong to a single category.

## 73. Least purchased product per category
```sql
SELECT category, product_id, qty FROM (
  SELECT c.name AS category, p.product_id, COALESCE(SUM(oi.quantity),0) AS qty,
         ROW_NUMBER() OVER (PARTITION BY c.category_id ORDER BY COALESCE(SUM(oi.quantity),0)) AS rn
  FROM categories c
  JOIN products p ON p.category_id = c.category_id
  LEFT JOIN order_items oi ON p.product_id = oi.product_id
  GROUP BY c.name, c.category_id, p.product_id
) t WHERE rn = 1;
```
**Explanation:** Find lowest-moving SKU per category.

## 74. Product with highest total reviews
```sql
SELECT product_id FROM reviews GROUP BY product_id ORDER BY COUNT(*) DESC LIMIT 1;
```
**Explanation:** Most-reviewed product ID.

## 75. Customer with highest avg review rating (min reviews threshold)
```sql
SELECT customer_id, AVG(rating) AS avg_rating FROM reviews GROUP BY customer_id HAVING COUNT(*)>=5 ORDER BY avg_rating DESC LIMIT 1;
```
**Explanation:** Top reviewer by average (trusted reviewer).

## 76. Revenue per category
```sql
SELECT c.name AS category, SUM(oi.quantity * oi.price_at_purchase) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.name;
```
**Explanation:** Category-level revenue insights.

## 77. Most active customers (pageviews)
```sql
SELECT customer_id, COUNT(*) AS views FROM analytics_pageviews GROUP BY customer_id ORDER BY views DESC LIMIT 50;
```
**Explanation:** Power users or heavy browsers.

## 78. Average payment amount per status
```sql
SELECT status, AVG(amount) AS avg_amount FROM payments GROUP BY status;
```
**Explanation:** Compare amounts across payment outcomes.

## 79. Percentage of orders refunded
```sql
SELECT (COUNT(*) FILTER (WHERE status='refunded')::float * 100) / NULLIF(COUNT(*),0) AS refund_percentage FROM payments;
```
**Explanation:** Refund rate KPI.

## 80. Items sold per product
```sql
SELECT product_id, SUM(quantity) AS total_sold FROM order_items GROUP BY product_id ORDER BY total_sold DESC;
```
**Explanation:** Units sold per SKU.

## 81. Revenue by hour of day
```sql
SELECT EXTRACT(HOUR FROM created_at) AS hour, SUM(total_amount) FROM orders GROUP BY hour ORDER BY hour;
```
**Explanation:** Peak ordering hours.

## 82. Find repeat purchasers (>=2 orders)
```sql
SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(*)>=2;
```
**Explanation:** Repeat purchase metric.

## 83. Average review rating per product
```sql
SELECT product_id, AVG(rating) AS avg_rating FROM reviews GROUP BY product_id;
```
**Explanation:** Product sentiment metric.

## 84. Stock value per category (requires inventory quantity)
```sql
SELECT c.name, SUM(i.change_amount * p.price) AS estimated_stock_value FROM inventory i JOIN products p ON i.product_id = p.product_id JOIN categories c ON p.category_id = c.category_id GROUP BY c.name;
```
**Explanation:** Approximate capital tied in stock per category.

## 85. Order count per payment method
```sql
SELECT method, COUNT(*) FROM payments GROUP BY method;
```
**Explanation:** Payment channel distribution.

## 86. Find abandoned carts (no orders from same customer)
```sql
SELECT c.cart_id, c.customer_id FROM cart c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
```
**Explanation:** Candidates for cart recovery emails.

## 87. Month-over-month revenue growth
```sql
SELECT month, revenue, revenue - LAG(revenue) OVER (ORDER BY month) AS growth FROM (SELECT DATE_TRUNC('month', created_at) AS month, SUM(total_amount) AS revenue FROM orders GROUP BY month) t ORDER BY month;
```
**Explanation:** Revenue growth trend.

## 88. Products viewed > 100 times
```sql
SELECT product_id, COUNT(*) AS views FROM analytics_pageviews GROUP BY product_id HAVING COUNT(*)>100;
```
**Explanation:** Highly viewed products.

## 89. Payment success rate
```sql
SELECT (COUNT(*) FILTER (WHERE status='success')::float * 100)/NULLIF(COUNT(*),0) AS success_percentage FROM payments;
```
**Explanation:** Payment reliability metric.

## 90. Customer with most items purchased
```sql
SELECT o.customer_id, SUM(oi.quantity) AS total_items FROM orders o JOIN order_items oi ON o.order_id = oi.order_id GROUP BY o.customer_id ORDER BY total_items DESC LIMIT 1;
```
**Explanation:** Biggest customer by volume.

## 91. Recursive CTE: category tree skeleton (requires parent_id)
```sql
WITH RECURSIVE cat_tree AS (
  SELECT category_id, name, parent_id, 1 AS depth FROM categories WHERE parent_id IS NULL
  UNION ALL
  SELECT c.category_id, c.name, c.parent_id, ct.depth + 1 FROM categories c JOIN cat_tree ct ON c.parent_id = ct.category_id
)
SELECT * FROM cat_tree;
```
**Explanation:** Traverse hierarchical categories if `parent_id` exists.

## 92. Flag unusually high single-order amounts (fraud)
```sql
SELECT o.order_id, o.customer_id, o.total_amount FROM orders o WHERE o.total_amount > (SELECT AVG(total_amount) + 3*STDDEV(total_amount) FROM orders) ORDER BY total_amount DESC;
```
**Explanation:** Simple anomaly detection using mean+3σ.

## 93. Customers with many failed payments recently
```sql
SELECT o.customer_id, COUNT(*) AS failed_count FROM payments p JOIN orders o ON p.order_id = o.order_id WHERE p.status='failed' AND p.paid_at > NOW() - INTERVAL '30 days' GROUP BY o.customer_id HAVING COUNT(*)>=3;
```
**Explanation:** Potential fraud or payment issues.

## 94. Products frequently bought together (pairs)
```sql
WITH pairs AS (SELECT oi1.product_id AS p1, oi2.product_id AS p2, COUNT(*) AS cnt FROM order_items oi1 JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id <> oi2.product_id GROUP BY oi1.product_id, oi2.product_id) SELECT p1, p2, cnt FROM pairs ORDER BY cnt DESC LIMIT 50;
```
**Explanation:** Market-basket insights.

## 95. Top co-purchases for a product
```sql
SELECT p2.product_id, p2.name, SUM(oi2.quantity) AS sold_together FROM order_items oi1 JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id <> oi2.product_id JOIN products p2 ON p2.product_id = oi2.product_id WHERE oi1.product_id = :product_id GROUP BY p2.product_id, p2.name ORDER BY sold_together DESC LIMIT 10;
```
**Explanation:** Cross-sell candidates for a given product.

## 96. Customer lifetime value (LTV)
```sql
SELECT o.customer_id, COUNT(DISTINCT o.order_id) AS orders, SUM(o.total_amount) AS lifetime_value, MAX(o.created_at) AS last_order FROM orders o GROUP BY o.customer_id ORDER BY lifetime_value DESC LIMIT 50;
```
**Explanation:** Basic LTV metrics.

## 97. Churn detection (no orders in 180 days but previously active)
```sql
WITH last_order AS (SELECT customer_id, MAX(created_at) AS last_order FROM orders GROUP BY customer_id) SELECT c.customer_id, c.full_name, lo.last_order FROM customers c JOIN last_order lo ON c.customer_id = lo.customer_id WHERE lo.last_order < NOW() - INTERVAL '180 days' AND lo.last_order > NOW() - INTERVAL '2 years';
```
**Explanation:** Win-back target segmentation.

## 98. Query JSON attributes: rating >=4
```sql
SELECT product_id, name, attributes FROM products WHERE (attributes->>'rating')::int >= 4;
```
**Explanation:** Filter products by JSON-stored rating.

## 99. Setup full-text search tsvector (one-time)
```sql
ALTER TABLE products ADD COLUMN IF NOT EXISTS tsv tsvector;
UPDATE products SET tsv = to_tsvector(coalesce(name,'') || ' ' || coalesce(attributes->>'color',''));
CREATE INDEX IF NOT EXISTS idx_products_tsv ON products USING GIN(tsv);
```
**Explanation:** Prepare full-text search index for product search.

## 100. Full-text search query example
```sql
SELECT product_id, name FROM products WHERE tsv @@ plainto_tsquery('smartphone OR laptop') LIMIT 50;
```
**Explanation:** Textual search across product text and attributes.


## 101. Recursive CTE — category hierarchy (template)
```sql
WITH RECURSIVE cat_tree AS (
  SELECT category_id, name, NULL::INT AS parent_id, 1 AS depth
  FROM categories
  WHERE category_id = 1
  UNION ALL
  SELECT c.category_id, c.name, ct.category_id, ct.depth + 1
  FROM categories c
  JOIN cat_tree ct ON c.category_id = ct.category_id
)
SELECT * FROM cat_tree;
```
**Explanation:** Template for category trees (adjust if you have `parent_id`).

## 102. Flag unusually high single-order amounts (fraud)
```sql
SELECT o.order_id, o.customer_id, o.total_amount
FROM orders o
WHERE o.total_amount > (
  SELECT AVG(total_amount) + 3 * STDDEV(total_amount) FROM orders
)
ORDER BY total_amount DESC;
```
**Explanation:** Outlier detection for manual review.

## 103. Customers with many failed payments recently
```sql
SELECT o.customer_id, COUNT(*) AS failed_count
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE p.status = 'failed' AND p.paid_at > NOW() - INTERVAL '30 days'
GROUP BY o.customer_id
HAVING COUNT(*) >= 3
ORDER BY failed_count DESC;
```
**Explanation:** Detect problematic accounts.

## 104. Products frequently bought together (basic)
```sql
WITH pairs AS (
  SELECT oi1.product_id AS p1, oi2.product_id AS p2, COUNT(*) AS cnt
  FROM order_items oi1
  JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id <> oi2.product_id
  GROUP BY oi1.product_id, oi2.product_id
)
SELECT p1, p2, cnt
FROM pairs
ORDER BY cnt DESC
LIMIT 50;
```
**Explanation:** Market-basket analysis for cross-sell.

## 105. Personalized top co-purchases for a product_id
```sql
SELECT p2.product_id, p2.name, SUM(oi2.quantity) AS sold_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id <> oi2.product_id
JOIN products p2 ON p2.product_id = oi2.product_id
WHERE oi1.product_id = :product_id
GROUP BY p2.product_id, p2.name
ORDER BY sold_together DESC
LIMIT 10;
```
**Explanation:** Best cross-sell candidates for a product.

## 106. LTV (lifetime value) estimate per customer
```sql
SELECT o.customer_id,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(o.total_amount) AS lifetime_value,
       AVG(o.total_amount) AS avg_order_value,
       MAX(o.created_at) AS last_order
FROM orders o
GROUP BY o.customer_id
ORDER BY lifetime_value DESC
LIMIT 50;
```
**Explanation:** LTV metrics for high-value customers.

## 107. Churn detection: inactive customers
```sql
WITH last_order AS (
  SELECT customer_id, MAX(created_at) AS last_order
  FROM orders
  GROUP BY customer_id
)
SELECT c.customer_id, c.full_name, lo.last_order
FROM customers c
JOIN last_order lo ON c.customer_id = lo.customer_id
WHERE lo.last_order < NOW() - INTERVAL '180 days'
  AND lo.last_order > NOW() - INTERVAL '2 years';
```
**Explanation:** Winback candidates.

## 108. Product detail search in JSON attributes
```sql
SELECT product_id, name, attributes
FROM products
WHERE (attributes->>'rating')::int >= 4;
```
**Explanation:** Filter by JSON-stored rating key.

## 109. Full-text search setup (tsvector)
```sql
ALTER TABLE products ADD COLUMN tsv tsvector;
UPDATE products SET tsv = to_tsvector(coalesce(name,'') || ' ' || coalesce(attributes->>'color',''));
CREATE INDEX idx_products_tsv ON products USING GIN(tsv);
```
**Explanation:** Prepare product full-text search.

## 110. Full-text search query example
```sql
SELECT product_id, name
FROM products
WHERE tsv @@ plainto_tsquery('smartphone OR laptop')
LIMIT 50;
```
**Explanation:** Search product names and attributes.

## 111. Recommend highly rated products (simple)
```sql
SELECT p.product_id, p.name, AVG(r.rating) AS avg_rating, COUNT(r.review_id) AS review_count
FROM reviews r
JOIN products p ON p.product_id = r.product_id
GROUP BY p.product_id, p.name
HAVING COUNT(r.review_id) >= 5
ORDER BY avg_rating DESC, review_count DESC
LIMIT 20;
```
**Explanation:** Recommend well-reviewed products with sufficient sample size.

## 112. Detect duplicate customers by email
```sql
SELECT email, COUNT(*) AS cnt FROM customers GROUP BY email HAVING COUNT(*) > 1;
```
**Explanation:** Data hygiene check.

## 113. Merge-suspect accounts (same phone)
```sql
SELECT phone, array_agg(customer_id) AS ids, array_agg(email) AS emails
FROM customers
WHERE phone IS NOT NULL
GROUP BY phone
HAVING COUNT(DISTINCT email) > 1;
```
**Explanation:** Detect multiple accounts tied to one phone number.

## 114. Materialized view: daily_sales creation
```sql
CREATE MATERIALIZED VIEW mv_daily_sales AS
SELECT date_trunc('day', created_at) AS day,
       SUM(total_amount) AS revenue,
       COUNT(*) AS orders_count
FROM orders
GROUP BY 1;
```
**Explanation:** Precompute day-level metrics for dashboards.

## 115. Refresh materialized view concurrently
```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales;
```
**Explanation:** Update materialized view without blocking reads (requires unique index).

## 116. EXPLAIN ANALYZE example
```sql
EXPLAIN ANALYZE
SELECT p.product_id, p.name, SUM(oi.quantity) AS sold
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY sold DESC
LIMIT 10;
```
**Explanation:** Profile query to optimize indexes.

## 117. Partial index for out-of-stock items
```sql
CREATE INDEX idx_products_out_of_stock ON products(product_id) WHERE stock = 0;
```
**Explanation:** Speeds up out-of-stock checks.

## 118. Partition example for analytics (month)
```sql
-- Example only; creating partitions requires parent table declaration.
CREATE TABLE analytics_pageviews_y2025 PARTITION OF analytics_pageviews
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
```
**Explanation:** Partition time-series data to improve performance.

## 119. Heatmap: product views by hour
```sql
SELECT product_id, EXTRACT(HOUR FROM viewed_at) AS hour, COUNT(*) AS views
FROM analytics_pageviews
GROUP BY product_id, hour
ORDER BY product_id, hour;
```
**Explanation:** Peak hours per product.

## 120. Retention cohort by first purchase month
```sql
WITH first_order AS (
  SELECT customer_id, DATE_TRUNC('month', MIN(created_at)) AS cohort_month
  FROM orders
  GROUP BY customer_id
)
SELECT cohort_month, COUNT(*) AS new_customers
FROM first_order
GROUP BY cohort_month
ORDER BY cohort_month;
```
**Explanation:** Acquire cohorts by month.

## 121. Average time from order to payment
```sql
SELECT AVG(p.paid_at - o.created_at) AS avg_payment_delay
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE p.paid_at IS NOT NULL;
```
**Explanation:** Payment latency metric.

## 122. Orders with mismatched totals vs items sum
```sql
SELECT o.order_id, o.total_amount, SUM(oi.quantity * oi.price_at_purchase) AS items_sum
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
HAVING ROUND(o.total_amount::numeric,2) <> ROUND(SUM(oi.quantity * oi.price_at_purchase),2)
LIMIT 50;
```
**Explanation:** Data integrity check for order totals.

## 123. Slow-moving inventory (low sales, high stock)
```sql
SELECT p.product_id, p.name, p.stock, COALESCE(SUM(oi.quantity),0) AS sold_last_year
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN orders o ON o.order_id = oi.order_id AND o.created_at > NOW() - INTERVAL '1 year'
GROUP BY p.product_id, p.name, p.stock
HAVING COALESCE(SUM(oi.quantity),0) < 10 AND p.stock > 50
ORDER BY p.stock DESC;
```
**Explanation:** Identify clearance candidates.

## 124. Rule-based churn scoring
```sql
SELECT c.customer_id, c.full_name,
       COALESCE(o.orders_count,0) AS orders_count,
       COALESCE(latest.last_order, '1970-01-01') AS last_order,
       CASE
         WHEN COALESCE(o.orders_count,0) = 0 THEN 'high_risk'
         WHEN latest.last_order < NOW() - INTERVAL '180 days' THEN 'medium_risk'
         ELSE 'low_risk'
       END AS churn_risk
FROM customers c
LEFT JOIN (
  SELECT customer_id, COUNT(*) AS orders_count FROM orders GROUP BY customer_id
) o ON o.customer_id = c.customer_id
LEFT JOIN (
  SELECT customer_id, MAX(created_at) AS last_order FROM orders GROUP BY customer_id
) latest ON latest.customer_id = c.customer_id;
```
**Explanation:** Simple churn segmentation.

## 125. Top N products per month (example pattern)
```sql
SELECT month, product_id, product_name, revenue, RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS rank_in_month
FROM (
  SELECT DATE_TRUNC('month', o.created_at) AS month,
         oi.product_id,
         p.name AS product_name,
         SUM(oi.quantity * oi.price_at_purchase) AS revenue
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  JOIN products p ON p.product_id = oi.product_id
  GROUP BY month, oi.product_id, p.name
) t;
```
**Explanation:** Monthly top products; add WHERE clause or LIMIT as needed.

## 126. Composite index for order_items speed
```sql
CREATE INDEX idx_order_items_product_order ON order_items(product_id, order_id);
```
**Explanation:** Speeds grouping and joins on these columns.

## 127. Sample estimate using TABLESAMPLE
```sql
SELECT COUNT(*) * (1.0 / 0.01)::bigint AS approx_count FROM analytics_pageviews TABLESAMPLE SYSTEM (1);
```
**Explanation:** Approximate counts via sampling for very large tables.

## 128. JSONB filter: products color = 'Red'
```sql
SELECT product_id, name FROM products WHERE attributes->>'color' = 'Red';
```
**Explanation:** Query JSONB attributes directly.

## 129. Deduct stock transactionally (example)
```sql
BEGIN;
UPDATE products SET stock = stock - 2 WHERE product_id = 123 AND stock >= 2;
INSERT INTO inventory (product_id, change_amount, reason) VALUES (123, -2, 'sale');
COMMIT;
```
**Explanation:** Safe stock decrement and logging.

## 130. Stored function: average rating
```sql
CREATE OR REPLACE FUNCTION fn_avg_rating(p_product_id INT) RETURNS NUMERIC AS $$
DECLARE avg_r NUMERIC;
BEGIN
  SELECT AVG(rating)::numeric INTO avg_r FROM reviews WHERE product_id = p_product_id;
  RETURN COALESCE(avg_r,0);
END;
$$ LANGUAGE plpgsql;
```
**Explanation:** Reusable function to fetch average rating.

## 131. Use stored function for top-rated products
```sql
SELECT product_id, name, fn_avg_rating(product_id) AS avg_rating FROM products ORDER BY avg_rating DESC LIMIT 20;
```
**Explanation:** Use encapsulated logic in queries.

## 132. Detect refund abuse pattern
```sql
SELECT o.customer_id, COUNT(*) AS refunded_count FROM payments p JOIN orders o ON p.order_id = o.order_id WHERE p.status='refunded' AND p.paid_at > NOW() - INTERVAL '180 days' GROUP BY o.customer_id HAVING COUNT(*)>=3;
```
**Explanation:** Monitor abuse or frequent returns.

## 133. Orders without payments
```sql
SELECT o.order_id, o.customer_id, o.total_amount FROM orders o LEFT JOIN payments p ON p.order_id = o.order_id WHERE p.payment_id IS NULL;
```
**Explanation:** Operational alert for unpaid orders.

## 134. Average items per order
```sql
SELECT AVG(items_count) AS avg_items FROM (SELECT order_id, COUNT(*) AS items_count FROM order_items GROUP BY order_id) t;
```
**Explanation:** Basket size metric.

## 135. Top paying customers by payment method
```sql
SELECT p.method, o.customer_id, SUM(p.amount) AS total_paid FROM payments p JOIN orders o ON p.order_id = o.order_id GROUP BY p.method, o.customer_id ORDER BY p.method, total_paid DESC;
```
**Explanation:** Understand big spenders per payment channel.

## 136. Price change detection (requires price history)
```sql
SELECT product_id, MIN(price) AS min_price, MAX(price) AS max_price FROM products GROUP BY product_id HAVING MAX(price) <> MIN(price);
```
**Explanation:** Detect price churn when history exists.

## 137. RFM features via window/aggregation
```sql
WITH cust_stats AS (SELECT customer_id, MAX(created_at) AS last_order, COUNT(*) AS frequency, SUM(total_amount) AS monetary FROM orders GROUP BY customer_id) SELECT customer_id, NOW() - last_order AS recency, frequency, monetary FROM cust_stats ORDER BY monetary DESC LIMIT 100;
```
**Explanation:** RFM segmentation basis.

## 138. Index for orders.created_at
```sql
CREATE INDEX idx_orders_created_at ON orders(created_at);
```
**Explanation:** Speed up time-based analytics.

## 139. Find products missing JSON keys
```sql
SELECT product_id FROM products WHERE NOT (attributes ? 'color') OR NOT (attributes ? 'rating') LIMIT 50;
```
**Explanation:** Data quality check for required JSON attributes.

## 140. Weekly active users (WAU)
```sql
SELECT date_trunc('week', viewed_at) AS week, COUNT(DISTINCT customer_id) AS wau FROM analytics_pageviews GROUP BY week ORDER BY week;
```
**Explanation:** Engagement metric.

## 141. Collaborative-filtering style recommendation (co-view)
```sql
WITH user_product AS (SELECT DISTINCT customer_id, product_id FROM analytics_pageviews) SELECT up2.product_id, COUNT(*) AS score FROM user_product up1 JOIN user_product up2 ON up1.customer_id = up2.customer_id AND up1.product_id <> up2.product_id WHERE up1.product_id = :product_id GROUP BY up2.product_id ORDER BY score DESC LIMIT 20;
```
**Explanation:** Recommend items co-viewed by same users.

## 142. Delete stale carts older than 90 days (maintenance)
```sql
DELETE FROM cart WHERE updated_at < NOW() - INTERVAL '90 days';
```
**Explanation:** Housekeeping to free space.

## 143. Monthly refunds summary
```sql
SELECT DATE_TRUNC('month', p.paid_at) AS month, COUNT(*) FILTER (WHERE p.status='refunded') AS refunds FROM payments p GROUP BY month ORDER BY month;
```
**Explanation:** Track refund trends.

## 144. Customers buying high-margin items (approx)
```sql
SELECT o.customer_id, SUM(oi.quantity * oi.price_at_purchase * 0.3) AS est_margin FROM order_items oi JOIN orders o ON o.order_id = oi.order_id GROUP BY o.customer_id ORDER BY est_margin DESC LIMIT 50;
```
**Explanation:** Rough estimate of profitable customers.

## 145. Materialized view: top products
```sql
CREATE MATERIALIZED VIEW mv_top_products AS SELECT p.product_id, p.name, SUM(oi.quantity * oi.price_at_purchase) AS revenue FROM order_items oi JOIN products p ON p.product_id = oi.product_id GROUP BY p.product_id, p.name ORDER BY revenue DESC LIMIT 100;
```
**Explanation:** Precompute best-sellers for dashboarding.

## 146. JOIN LATERAL: top review per product
```sql
SELECT p.product_id, p.name, r.* FROM products p LEFT JOIN LATERAL (SELECT * FROM reviews r WHERE r.product_id = p.product_id ORDER BY rating DESC LIMIT 1) r ON true;
```
**Explanation:** Fetch best review per product efficiently.

## 147. Detect sudden spike in product views
```sql
WITH daily_views AS (SELECT product_id, DATE_TRUNC('day', viewed_at) AS day, COUNT(*) AS views FROM analytics_pageviews GROUP BY product_id, day), agg AS (SELECT product_id, AVG(views) AS avg_views, STDDEV(views) AS sd_views FROM daily_views GROUP BY product_id) SELECT dv.product_id, dv.day, dv.views FROM daily_views dv JOIN agg ON dv.product_id = agg.product_id WHERE dv.views > agg.avg_views + 4 * COALESCE(agg.sd_views,0) ORDER BY dv.views DESC;
```
**Explanation:** Flag anomalous view spikes.

## 148. Audit trigger schema example
```sql
CREATE TABLE IF NOT EXISTS audit_log (id BIGSERIAL PRIMARY KEY, table_name TEXT, operation TEXT, row_data JSONB, changed_at TIMESTAMP DEFAULT NOW());
CREATE OR REPLACE FUNCTION fn_audit_orders() RETURNS TRIGGER AS $$ BEGIN INSERT INTO audit_log(table_name, operation, row_to_json(NEW)); RETURN NEW; END; $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_audit_orders AFTER INSERT ON orders FOR EACH ROW EXECUTE FUNCTION fn_audit_orders();
```
**Explanation:** Auditing pattern for inserts.

## 149. Top referrers by pageviews (if referrer stored)
```sql
SELECT referrer, COUNT(*) AS views FROM analytics_pageviews GROUP BY referrer ORDER BY views DESC LIMIT 20;
```
**Explanation:** Marketing insight on traffic sources.

## 150. Export product report to CSV (server-side)
```sql
COPY (SELECT p.product_id, p.name, c.name AS category, p.price, p.stock FROM products p JOIN categories c ON p.category_id = c.category_id) TO '/var/lib/postgresql/product_report.csv' WITH CSV HEADER;
```
**Explanation:** Fast server-side export (needs filesystem access).


## 151. List top 10 customers by lifetime value (LTV)
```sql
SELECT c.customer_id, c.full_name, SUM(o.total_amount) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY lifetime_value DESC
LIMIT 10;
```
**Explanation:** Identifies high-value customers for loyalty programs.

## 152. Compute repeat purchase rate
```sql
WITH cust_orders AS (SELECT customer_id, COUNT(*) AS cnt FROM orders GROUP BY customer_id)
SELECT 100.0 * SUM(CASE WHEN cnt > 1 THEN 1 ELSE 0 END) / COUNT(*) AS repeat_rate FROM cust_orders;
```
**Explanation:** Percentage of customers who ordered more than once.

## 153. Median order value using percentile_cont
```sql
SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY total_amount) AS median_order_value FROM orders;
```
**Explanation:** Robust central tendency for skewed revenue.

## 154. Find products with highest revenue per unit (price * units sold)
```sql
SELECT p.product_id, p.name, SUM(oi.quantity * oi.price_at_purchase) AS revenue FROM order_items oi JOIN products p ON p.product_id = oi.product_id GROUP BY p.product_id, p.name ORDER BY revenue DESC LIMIT 20;
```
**Explanation:** Revenue leaders across SKUs.

## 155. Calculate average days between customer orders
```sql
WITH ord AS (SELECT customer_id, created_at, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at) rn FROM orders), diffs AS (SELECT o1.customer_id, EXTRACT(EPOCH FROM (o2.created_at - o1.created_at))/86400 AS days_diff FROM ord o1 JOIN ord o2 ON o1.customer_id = o2.customer_id AND o2.rn = o1.rn + 1) SELECT AVG(days_diff) AS avg_days_between_orders FROM diffs;
```
**Explanation:** Understand purchase cadence.

## 156. Top 5 products by conversion (views → purchases)
```sql
WITH views AS (SELECT product_id, COUNT(*) AS v FROM analytics_pageviews GROUP BY product_id), purchases AS (SELECT product_id, SUM(quantity) AS bought FROM order_items GROUP BY product_id) SELECT v.product_id, v.v, COALESCE(b.bought,0) AS bought, COALESCE(b.bought,0)::float / v.v AS conversion FROM views v LEFT JOIN purchases b ON v.product_id = b.product_id ORDER BY conversion DESC NULLS LAST LIMIT 5;
```
**Explanation:** Measures product-level conversion efficiency.

## 157. Cohort retention table (customers by month who returned next month)
```sql
WITH first_month AS (SELECT customer_id, DATE_TRUNC('month', MIN(created_at)) AS cohort_month FROM orders GROUP BY customer_id), orders_month AS (SELECT customer_id, DATE_TRUNC('month', created_at) AS order_month FROM orders) SELECT f.cohort_month, o.order_month, COUNT(DISTINCT o.customer_id) AS active_customers FROM first_month f JOIN orders_month o ON f.customer_id = o.customer_id GROUP BY f.cohort_month, o.order_month ORDER BY f.cohort_month, o.order_month;
```
**Explanation:** Cohort retention matrix foundation.

## 158. Identify customers who repeatedly buy the same product
```sql
SELECT oi.product_id, o.customer_id, COUNT(DISTINCT o.order_id) AS times_bought FROM order_items oi JOIN orders o ON oi.order_id = o.order_id GROUP BY oi.product_id, o.customer_id HAVING COUNT(DISTINCT o.order_id) > 1 ORDER BY times_bought DESC LIMIT 50;
```
**Explanation:** Loyal product customers; candidates for subscriptions.

## 159. Weighted rating (Bayesian average) to rank products more fairly
```sql
WITH stats AS (SELECT product_id, AVG(rating) AS avg_rating, COUNT(*) AS cnt FROM reviews GROUP BY product_id), global AS (SELECT AVG(avg_rating) AS C, SUM(cnt) AS m FROM stats) SELECT s.product_id, ( (global.C * 10) + (s.avg_rating * s.cnt) ) / (10 + s.cnt) AS bayesian_score FROM stats s, global ORDER BY bayesian_score DESC LIMIT 20;
```
**Explanation:** Reduces bias of low-sample high ratings (use m=10 as prior sample size).

## 160. Find products frequently returned (requires returns data in payments or orders)
```sql
-- If you track returns via payments.status='refunded' join order_items to refunded payments
SELECT oi.product_id, COUNT(*) AS return_count FROM order_items oi JOIN payments p ON p.order_id = oi.order_id WHERE p.status='refunded' GROUP BY oi.product_id ORDER BY return_count DESC LIMIT 50;
```
**Explanation:** Identify problematic SKUs with high returns.

## 161. Build a simple customer segmentation (RFM buckets)
```sql
WITH rfm AS (SELECT customer_id, EXTRACT(DAY FROM NOW() - MAX(created_at)) AS recency, COUNT(*) AS frequency, SUM(total_amount) AS monetary FROM orders GROUP BY customer_id) SELECT customer_id, recency, frequency, monetary, CASE WHEN monetary > 10000 THEN 'high' WHEN monetary > 5000 THEN 'medium' ELSE 'low' END AS monetary_bucket FROM rfm ORDER BY monetary DESC LIMIT 100;
```
**Explanation:** Quick segmentation for marketing.

## 162. Find products with price drops more than X percent (requires price history)
```sql
-- Placeholder: If you have product_price_history table, compare last two entries per product
SELECT product_id FROM product_price_history WHERE ...;
```
**Explanation:** Requires price history table; useful for promotions.

## 163. Show customers who used multiple payment methods
```sql
SELECT o.customer_id, array_agg(DISTINCT p.method) AS methods FROM payments p JOIN orders o ON p.order_id = o.order_id GROUP BY o.customer_id HAVING COUNT(DISTINCT p.method) > 1;
```
**Explanation:** Payment behavior diversity.

## 164. Average checkout abandonment time (cart -> order)
```sql
-- Needs timestamps for cart creation; approximate if cart.updated_at exists
SELECT AVG( (o.created_at - c.updated_at) ) AS avg_time_to_purchase FROM cart c JOIN orders o ON c.customer_id = o.customer_id WHERE o.created_at > c.updated_at;
```
**Explanation:** How long users take from adding to cart to placing order.

## 165. Products with the fastest sell-through (stock to sold ratio over time)
```sql
SELECT p.product_id, p.name, SUM(oi.quantity) AS sold, p.stock, SUM(oi.quantity)::float / NULLIF(p.stock,0) AS sell_through FROM order_items oi JOIN products p ON p.product_id = oi.product_id GROUP BY p.product_id, p.name, p.stock ORDER BY sell_through DESC NULLS LAST LIMIT 20;
```
**Explanation:** Identify quick-selling SKUs.

## 166. Customers with highest average order value (min orders threshold)
```sql
SELECT o.customer_id, AVG(o.total_amount) AS avg_order_value FROM orders o GROUP BY o.customer_id HAVING COUNT(*) >= 3 ORDER BY avg_order_value DESC LIMIT 50;
```
**Explanation:** High AOV customers for VIP targeting.

## 167. Find sessions with many pageviews but no purchase (engagement without conversion)
```sql
SELECT a.customer_id, COUNT(*) AS views FROM analytics_pageviews a LEFT JOIN orders o ON a.customer_id = o.customer_id WHERE o.order_id IS NULL GROUP BY a.customer_id HAVING COUNT(*) > 50;
```
**Explanation:** High-engagement but no conversion — retargeting candidates.

## 168. Identify cross-sell pairs using lift metric
```sql
WITH pair_counts AS (SELECT oi1.product_id AS p1, oi2.product_id AS p2, COUNT(*) AS cnt FROM order_items oi1 JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id <> oi2.product_id GROUP BY oi1.product_id, oi2.product_id), totals AS (SELECT product_id, SUM(quantity) AS total FROM order_items GROUP BY product_id) SELECT pc.p1, pc.p2, pc.cnt::float / NULLIF(t1.total,0) / (t2.total::float / (SELECT SUM(total) FROM totals)) AS lift FROM pair_counts pc JOIN totals t1 ON pc.p1 = t1.product_id JOIN totals t2 ON pc.p2 = t2.product_id ORDER BY lift DESC LIMIT 50;
```
**Explanation:** Lift >1 suggests stronger association than random.

## 169. Backfill missing average rating into products table (if you store it)
```sql
UPDATE products p SET attributes = jsonb_set(coalesce(p.attributes,'{}'::jsonb), '{avg_rating}', to_jsonb(sub.avg)) FROM (SELECT product_id, ROUND(AVG(rating)::numeric,2) AS avg FROM reviews GROUP BY product_id) sub WHERE p.product_id = sub.product_id;
```
**Explanation:** Store computed metrics into product JSON for fast read.

## 170. Detect bots by extremely high pageviews from single IP (if IP stored)
```sql
SELECT ip_address, COUNT(*) AS hits FROM analytics_pageviews WHERE viewed_at > NOW() - INTERVAL '7 days' GROUP BY ip_address HAVING COUNT(*) > 10000;
```
**Explanation:** Flag suspicious traffic sources.

## 171. Create an index for JSONB key access (rating)
```sql
CREATE INDEX idx_products_attrs_rating ON products ((attributes->>'rating'));
```
**Explanation:** Speeds WHERE (attributes->>'rating') queries (note: expression index).

## 172. Find top products with rising month-over-month sales (trend detection)
```sql
WITH monthly AS (SELECT product_id, DATE_TRUNC('month', o.created_at) AS mth, SUM(oi.quantity * oi.price_at_purchase) AS revenue FROM order_items oi JOIN orders o ON oi.order_id = o.order_id GROUP BY product_id, mth), trends AS (SELECT product_id, (MAX(revenue) - MIN(revenue)) / NULLIF(MIN(revenue),0) AS growth FROM monthly GROUP BY product_id) SELECT t.product_id, p.name, t.growth FROM trends t JOIN products p ON p.product_id = t.product_id ORDER BY growth DESC LIMIT 20;
```
**Explanation:** Find fast-growing SKUs.

## 173. Use EXPLAIN to compare two query versions (exercise)
```sql
EXPLAIN ANALYZE SELECT p.product_id, SUM(oi.quantity) FROM order_items oi JOIN products p ON p.product_id = oi.product_id GROUP BY p.product_id;
```
**Explanation:** Learn query planner behavior — try alternative joins/indexes and compare.

## 174. Create GIN index on attributes for multi-key JSONB search
```sql
CREATE INDEX idx_products_attrs_gin ON products USING GIN (attributes);
```
**Explanation:** Improves complex JSONB queries (existence and containment).

## 175. De-duplicate customers by keeping earliest account per email (example)
```sql
WITH ranked AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY email ORDER BY created_at) AS rn FROM customers) DELETE FROM customers WHERE customer_id IN (SELECT customer_id FROM ranked WHERE rn > 1);
```
**Explanation:** Cleanup duplicates keeping first created account.

## 176. Find products with inconsistent pricing across order_items vs products table
```sql
SELECT DISTINCT oi.product_id FROM order_items oi LEFT JOIN products p ON p.product_id = oi.product_id WHERE oi.price_at_purchase <> p.price LIMIT 50;
```
**Explanation:** Spot pricing discrepancies for reconciliation.

## 177. Batch update: mark old carts as archived (example flag column required)
```sql
-- If cart has a status column, update it; otherwise add column first.
ALTER TABLE cart ADD COLUMN IF NOT EXISTS status TEXT;
UPDATE cart SET status='archived' WHERE updated_at < NOW() - INTERVAL '180 days';
```
**Explanation:** Batch maintenance for cart lifecycle.

## 178. Use window to compute recency rank for customers
```sql
SELECT customer_id, last_order, RANK() OVER (ORDER BY last_order DESC) AS recency_rank FROM (SELECT customer_id, MAX(created_at) AS last_order FROM orders GROUP BY customer_id) t;
```
**Explanation:** Rank customers by recency for prioritization.

## 179. Find top suppliers if you had supplier table (example pattern)
```sql
-- Placeholder: requires suppliers and product_supplier tables
SELECT supplier_id, SUM(oi.quantity * oi.price_at_purchase) AS revenue FROM order_items oi JOIN products p ON p.product_id = oi.product_id JOIN product_supplier ps ON ps.product_id = p.product_id GROUP BY supplier_id ORDER BY revenue DESC LIMIT 20;
```
**Explanation:** Vendor performance metric (requires schema extension).

## 180. Create function to refund a payment (transactional example)
```sql
CREATE OR REPLACE FUNCTION fn_refund_payment(p_payment_id INT) RETURNS VOID AS $$ BEGIN UPDATE payments SET status='refunded' WHERE payment_id = p_payment_id; INSERT INTO audit_log(table_name, operation, row_data) VALUES ('payments','refund', row_to_json((SELECT * FROM payments WHERE payment_id = p_payment_id))); END; $$ LANGUAGE plpgsql;
```
**Explanation:** Encapsulate refund logic with auditing.

## 181. Compute average sessions per user (pageviews per customer)
```sql
SELECT AVG(cnt) FROM (SELECT customer_id, COUNT(*) AS cnt FROM analytics_pageviews GROUP BY customer_id) t;
```
**Explanation:** Average engagement per user.

## 182. Find customers with repeated failed payment + refund patterns (fraud risk)
```sql
SELECT o.customer_id, SUM(CASE WHEN p.status='failed' THEN 1 ELSE 0 END) AS failed_count, SUM(CASE WHEN p.status='refunded' THEN 1 ELSE 0 END) AS refunded_count FROM payments p JOIN orders o ON p.order_id = o.order_id GROUP BY o.customer_id HAVING SUM(CASE WHEN p.status='refunded' THEN 1 ELSE 0 END) > 2 ORDER BY refunded_count DESC;
```
**Explanation:** Detect suspicious billing behavior.

## 183. Estimate customer acquisition cost if you have marketing spend table (pattern)
```sql
-- Requires marketing_spend table; placeholder query pattern
SELECT campaign, SUM(spend)/SUM(new_customers) AS cac FROM marketing_spend JOIN (SELECT campaign, COUNT(DISTINCT customer_id) AS new_customers FROM customers WHERE created_at BETWEEN ... GROUP BY campaign) c ON c.campaign = marketing_spend.campaign GROUP BY campaign;
```
**Explanation:** CAC calculation requires marketing data.

## 184. Compute gross margin per order (requires cost data)
```sql
-- Placeholder: assumes product cost is stored as cost column
SELECT o.order_id, SUM(oi.quantity * (oi.price_at_purchase - p.cost)) AS gross_margin FROM order_items oi JOIN products p ON p.product_id = oi.product_id JOIN orders o ON o.order_id = oi.order_id GROUP BY o.order_id ORDER BY gross_margin DESC LIMIT 50;
```
**Explanation:** Profitability per order if cost exists.

## 185. Build a summary table for daily KPIs (materialized view)
```sql
CREATE MATERIALIZED VIEW mv_daily_kpis AS SELECT date_trunc('day', created_at) AS day, COUNT(DISTINCT (SELECT order_id FROM orders WHERE created_at::date = date_trunc('day', created_at))) AS orders_count, SUM(total_amount) AS revenue FROM orders GROUP BY day;
```
**Explanation:** Daily KPIs precomputed for dashboards.

## 186. Find products frequently added to cart but not purchased
```sql
SELECT ci.product_id, COUNT(*) AS added_count, COALESCE(SUM(oi.quantity),0) AS bought_count FROM cart_items ci LEFT JOIN order_items oi ON ci.product_id = oi.product_id GROUP BY ci.product_id HAVING COALESCE(SUM(oi.quantity),0) = 0 ORDER BY added_count DESC LIMIT 50;
```
**Explanation:** Products with high interest but low conversion.

## 187. Find average delivery time if you have shipped_at and delivered_at
```sql
SELECT AVG(delivered_at - shipped_at) AS avg_delivery_time FROM shipping WHERE delivered_at IS NOT NULL;
```
**Explanation:** Shipping performance metric (requires shipping table).

## 188. Create trigger to auto-generate invoice number after order insert
```sql
CREATE OR REPLACE FUNCTION fn_generate_invoice_number() RETURNS TRIGGER AS $$ DECLARE inv TEXT; BEGIN inv := CONCAT('INV-', TO_CHAR(NOW(),'YYYYMMDD'), '-', NEW.order_id); INSERT INTO invoices(order_id, invoice_number, total_amount, issued_at) VALUES (NEW.order_id, inv, NEW.total_amount, NOW()); RETURN NEW; END; $$ LANGUAGE plpgsql; CREATE TRIGGER trg_create_invoice AFTER INSERT ON orders FOR EACH ROW EXECUTE FUNCTION fn_generate_invoice_number();
```
**Explanation:** Automates invoice creation post-order.

## 189. Detect products with many negative reviews (rating <=2)
```sql
SELECT product_id, COUNT(*) AS neg_count FROM reviews WHERE rating <= 2 GROUP BY product_id ORDER BY neg_count DESC LIMIT 50;
```
**Explanation:** Quality/fulfillment issues signaling products to investigate.

## 190. Compute product elasticity approximation (price vs demand) (advanced)
```sql
-- Requires time series of price and quantity sold; placeholder pattern
SELECT product_id, CORR(price, quantity_sold) FROM price_demand_table GROUP BY product_id HAVING COUNT(*)>5;
```
**Explanation:** Correlation between price and demand (needs historical price/demand table).

## 191. Find customers who browse similar products before purchase (session path)
```sql
-- Complex, requires session_id or timestamp windows; rough example
SELECT pv.customer_id, array_agg(DISTINCT pv.product_id) AS products_viewed FROM analytics_pageviews pv JOIN orders o ON pv.customer_id = o.customer_id WHERE pv.viewed_at < o.created_at AND pv.viewed_at > o.created_at - INTERVAL '1 day' GROUP BY pv.customer_id;
```
**Explanation:** Understand pre-purchase browsing behavior.

## 192. Compute moving average of daily revenue (14-day)
```sql
SELECT day, revenue, AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) AS ma_14 FROM (SELECT created_at::date AS day, SUM(total_amount) AS revenue FROM orders GROUP BY day) t ORDER BY day;
```
**Explanation:** Smooth revenue trends for forecasting.

## 193. Top 10 products by gross margin (requires cost)
```sql
-- Placeholder: if p.cost exists
SELECT p.product_id, p.name, SUM((oi.price_at_purchase - p.cost) * oi.quantity) AS gross_margin FROM order_items oi JOIN products p ON p.product_id = oi.product_id GROUP BY p.product_id, p.name ORDER BY gross_margin DESC LIMIT 10;
```
**Explanation:** Top margin-generating products (needs cost data).

## 194. Calculate net revenue after refunds
```sql
SELECT SUM(amount) FILTER (WHERE status='success') - SUM(amount) FILTER (WHERE status='refunded') AS net_revenue FROM payments;
```
**Explanation:** Quick net revenue calculation from payments table.

## 195. Identify time-to-first-purchase per cohort
```sql
WITH first_visit AS (SELECT customer_id, MIN(viewed_at) AS first_visit FROM analytics_pageviews GROUP BY customer_id), first_order AS (SELECT customer_id, MIN(created_at) AS first_order FROM orders GROUP BY customer_id) SELECT fv.customer_id, fv.first_visit, fo.first_order, (fo.first_order - fv.first_visit) AS time_to_first_purchase FROM first_visit fv LEFT JOIN first_order fo ON fv.customer_id = fo.customer_id;
```
**Explanation:** Measures acquisition funnel speed.

## 196. Build a summary table for top customers (materialized)
```sql
CREATE MATERIALIZED VIEW mv_top_customers AS SELECT c.customer_id, c.full_name, SUM(o.total_amount) AS lifetime_value, COUNT(o.order_id) AS orders_count FROM customers c JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id, c.full_name ORDER BY lifetime_value DESC LIMIT 100;
```
**Explanation:** Fast access to top customer metrics.

## 197. Detect price outliers per category (z-score)
```sql
WITH stats AS (SELECT category_id, AVG(price) AS mean_p, STDDEV(price) AS sd_p FROM products GROUP BY category_id) SELECT p.product_id, p.name, (p.price - s.mean_p)/NULLIF(s.sd_p,0) AS z FROM products p JOIN stats s ON p.category_id = s.category_id WHERE ABS((p.price - s.mean_p)/NULLIF(s.sd_p,0)) > 3;
```
**Explanation:** Flag anomalous prices within category.

## 198. Create function to refresh analytics materialized views
```sql
CREATE OR REPLACE FUNCTION fn_refresh_analytics() RETURNS VOID AS $$ BEGIN REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales; REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_products; END; $$ LANGUAGE plpgsql;
```
**Explanation:** Helper to refresh multiple MV's in one call.

## 199. Export customer emails for marketing (CSV)
```sql
COPY (SELECT email FROM customers WHERE email IS NOT NULL) TO '/var/lib/postgresql/customer_emails.csv' WITH CSV HEADER;
```
**Explanation:** Server-side export for marketing use (requires filesystem permissions).

## 200. Practice exercise — optimize slow query: explain + index suggestion
```sql
-- Step 1: run explain analyze on the slow query (example)
EXPLAIN ANALYZE SELECT p.product_id, p.name, SUM(oi.quantity) FROM order_items oi JOIN products p ON p.product_id = oi.product_id GROUP BY p.product_id, p.name ORDER BY SUM(oi.quantity) DESC LIMIT 10;

-- Step 2: If sequential scan noted on order_items, create an index:
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Step 3: Re-run EXPLAIN ANALYZE and compare.
```
**Explanation:** Hands-on optimization exercise to learn query tuning.
