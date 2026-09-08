-- ============================================================
-- Olist E-Commerce Project — Phase 1: PostgreSQL (Neon)
-- Script 02: Verify staging data
--
-- Purpose: Confirm that every staging table was loaded with the
-- correct number of rows before moving on to cleaning.
-- Expected row counts (from the original Kaggle CSV files):
--   staging_customers                      99,441
--   staging_orders                         99,441
--   staging_order_items                   112,650
--   staging_order_payments                103,886
--   staging_order_reviews                   99,224
--   staging_products                        32,951
--   staging_sellers                          3,095
--   staging_product_category_translation        71
--   staging_geolocation                  1,000,163
-- ============================================================

SELECT 'staging_customers' AS table_name, COUNT(*) FROM staging_customers
UNION ALL SELECT 'staging_orders', COUNT(*) FROM staging_orders
UNION ALL SELECT 'staging_order_items', COUNT(*) FROM staging_order_items
UNION ALL SELECT 'staging_order_payments', COUNT(*) FROM staging_order_payments
UNION ALL SELECT 'staging_order_reviews', COUNT(*) FROM staging_order_reviews
UNION ALL SELECT 'staging_products', COUNT(*) FROM staging_products
UNION ALL SELECT 'staging_sellers', COUNT(*) FROM staging_sellers
UNION ALL SELECT 'staging_product_category_translation', COUNT(*) FROM staging_product_category_translation
UNION ALL SELECT 'staging_geolocation', COUNT(*) FROM staging_geolocation;
