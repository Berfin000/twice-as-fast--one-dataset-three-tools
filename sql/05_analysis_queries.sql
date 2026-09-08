-- ============================================================
-- Olist E-Commerce Project — Phase 1: PostgreSQL (Neon)
-- Script 05: Analysis queries
--
-- Purpose: Answer real business questions using the cleaned
-- tables, demonstrating JOINs, subqueries, aggregation, HAVING,
-- CTEs and a window function.
-- ============================================================

-- ------------------------------------------------------------
-- Q1: Which are the top 10 best-selling product categories
--     (by number of items sold)?
-- ------------------------------------------------------------
SELECT
    pct.product_category_name_english AS category,
    COUNT(*) AS items_sold
FROM cleaned_order_items oi
JOIN cleaned_products p ON oi.product_id = p.product_id
JOIN cleaned_product_category_translation pct ON p.product_category_name = pct.product_category_name
GROUP BY pct.product_category_name_english
ORDER BY items_sold DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q2: What is the average delivery time (in days), by customer
--     state? (Orders that have not yet been delivered are
--     excluded, since a delivery time cannot be computed for them.)
-- ------------------------------------------------------------
SELECT
    c.customer_state,
    ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))) / 86400, 1) AS avg_delivery_days,
    COUNT(*) AS total_orders
FROM cleaned_orders o
JOIN cleaned_customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;


-- ------------------------------------------------------------
-- Q3: Which customers spent more than the average payment value
--     (top 10 by total amount spent)?
-- ------------------------------------------------------------
SELECT
    c.customer_unique_id,
    SUM(op.payment_value) AS total_spent
FROM cleaned_orders o
JOIN cleaned_customers c ON o.customer_id = c.customer_id
JOIN cleaned_order_payments op ON o.order_id = op.order_id
GROUP BY c.customer_unique_id
HAVING SUM(op.payment_value) > (
    SELECT AVG(payment_value) FROM cleaned_order_payments
)
ORDER BY total_spent DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q4: What is the month-over-month revenue trend?
--     Note: the last two months in the dataset (2018-09 and
--     2018-10) show a sharp drop — this is a known data cutoff
--     in the Olist dataset (near-empty months), not an actual
--     collapse in sales.
-- ------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        SUM(op.payment_value) AS revenue
    FROM cleaned_orders o
    JOIN cleaned_order_payments op ON o.order_id = op.order_id
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS previous_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100,
        1
    ) AS pct_change
FROM monthly_revenue
ORDER BY month;
