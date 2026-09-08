-- ============================================================
-- Olist E-Commerce Project — Phase 1: PostgreSQL (Neon)
-- Script 04: Verify cleaned data
--
-- Purpose: Confirm every cleaned table has the expected number of
-- rows after cleaning/type conversion.
-- Expected row counts:
--   cleaned_customers                      99,441
--   cleaned_sellers                         3,095
--   cleaned_product_category_translation       71
--   cleaned_products                       32,951
--   cleaned_orders                         99,441
--   cleaned_order_items                   112,650
--   cleaned_order_payments                103,886
--   cleaned_order_reviews                   99,224
--   cleaned_geolocation                   738,332  (deduplicated from 1,000,163 raw rows)
-- ============================================================

SELECT 'cleaned_customers' AS table_name, COUNT(*) FROM cleaned_customers
UNION ALL SELECT 'cleaned_sellers', COUNT(*) FROM cleaned_sellers
UNION ALL SELECT 'cleaned_product_category_translation', COUNT(*) FROM cleaned_product_category_translation
UNION ALL SELECT 'cleaned_products', COUNT(*) FROM cleaned_products
UNION ALL SELECT 'cleaned_orders', COUNT(*) FROM cleaned_orders
UNION ALL SELECT 'cleaned_order_items', COUNT(*) FROM cleaned_order_items
UNION ALL SELECT 'cleaned_order_payments', COUNT(*) FROM cleaned_order_payments
UNION ALL SELECT 'cleaned_order_reviews', COUNT(*) FROM cleaned_order_reviews
UNION ALL SELECT 'cleaned_geolocation', COUNT(*) FROM cleaned_geolocation;
