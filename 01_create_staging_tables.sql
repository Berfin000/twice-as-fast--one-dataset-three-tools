-- ============================================================
-- Olist E-Commerce Project — Phase 1: PostgreSQL (Neon)
-- Script 01: Create staging tables
--
-- Purpose: Create empty "staging" tables where the raw Olist CSV
-- files are loaded as-is (every column as TEXT). No cleaning or
-- type conversion happens here — this is the "Extract & Load"
-- step of an ELT (Extract, Load, Transform) approach. Cleaning
-- and type casting happen later, in 03_create_cleaned_tables.sql.
-- ============================================================

CREATE TABLE staging_customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

CREATE TABLE staging_orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);

CREATE TABLE staging_order_items (
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price TEXT,
    freight_value TEXT
);

CREATE TABLE staging_order_payments (
    order_id TEXT,
    payment_sequential TEXT,
    payment_type TEXT,
    payment_installments TEXT,
    payment_value TEXT
);

CREATE TABLE staging_order_reviews (
    review_id TEXT,
    order_id TEXT,
    review_score TEXT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TEXT,
    review_answer_timestamp TEXT
);

CREATE TABLE staging_products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght TEXT,
    product_description_lenght TEXT,
    product_photos_qty TEXT,
    product_weight_g TEXT,
    product_length_cm TEXT,
    product_height_cm TEXT,
    product_width_cm TEXT
);

CREATE TABLE staging_sellers (
    seller_id TEXT,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT
);

CREATE TABLE staging_product_category_translation (
    product_category_name TEXT,
    product_category_name_english TEXT
);

CREATE TABLE staging_geolocation (
    geolocation_zip_code_prefix TEXT,
    geolocation_lat TEXT,
    geolocation_lng TEXT,
    geolocation_city TEXT,
    geolocation_state TEXT
);

-- ============================================================
-- Note on data loading:
-- The 9 CSV files were loaded into these tables using DBeaver's
-- "Import Data" wizard (right-click table -> Import Data -> CSV),
-- with one exception: olist_order_reviews_dataset.csv contains a
-- multi-line quoted field (a review comment with an embedded line
-- break), which DBeaver's CSV import wizard cannot parse correctly
-- ("Un-terminated quoted field at end of CSV line" error). That one
-- file was loaded instead with a small Python script using
-- psycopg2's copy_expert() to run PostgreSQL's native COPY command,
-- which handles multi-line quoted CSV fields correctly.
-- ============================================================
