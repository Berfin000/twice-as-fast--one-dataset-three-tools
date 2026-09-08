-- ============================================================
-- Olist E-Commerce Project — Phase 1: PostgreSQL (Neon)
-- Script 03: Create cleaned tables
--
-- Purpose: Transform the raw "staging_*" tables (everything TEXT)
-- into properly typed, validated "cleaned_*" tables. This is the
-- "Transform" step of the ELT approach. Every table was first
-- checked for: duplicate keys, NULL/empty values, invalid
-- formats (non-numeric text in numeric columns, bad timestamps),
-- and inconsistent value lengths, before deciding on data types
-- and constraints below.
-- ============================================================

-- ---------- customers ----------
-- No type conversion needed (all columns stay TEXT: IDs and the
-- zip code prefix are identifiers, not numbers to do math on).
-- customer_id verified unique -> safe as PRIMARY KEY.
CREATE TABLE cleaned_customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT NOT NULL,
    customer_zip_code_prefix TEXT NOT NULL,
    customer_city TEXT NOT NULL,
    customer_state TEXT NOT NULL
);

INSERT INTO cleaned_customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state
FROM staging_customers;

-- ---------- sellers ----------
CREATE TABLE cleaned_sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix TEXT NOT NULL,
    seller_city TEXT NOT NULL,
    seller_state TEXT NOT NULL
);

INSERT INTO cleaned_sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state
FROM staging_sellers;

-- ---------- product category translation ----------
CREATE TABLE cleaned_product_category_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT NOT NULL
);

INSERT INTO cleaned_product_category_translation (product_category_name, product_category_name_english)
SELECT product_category_name, product_category_name_english
FROM staging_product_category_translation;

-- ---------- products ----------
-- 610 rows have empty category/name-length/description-length/photos-qty
-- (a real, known gap in the dataset — these products were never fully
-- described), and 2 rows are missing physical dimensions. These columns
-- are left nullable rather than NOT NULL. NULLIF converts the empty
-- string ('') found in staging into a real NULL before casting to
-- INTEGER (an empty string cannot be cast directly).
-- Column names "lenght" (a typo in the original dataset) are corrected
-- to "length" here.
CREATE TABLE cleaned_products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

INSERT INTO cleaned_products (
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    product_id,
    NULLIF(product_category_name, ''),
    NULLIF(product_name_lenght, '')::INTEGER,
    NULLIF(product_description_lenght, '')::INTEGER,
    NULLIF(product_photos_qty, '')::INTEGER,
    NULLIF(product_weight_g, '')::INTEGER,
    NULLIF(product_length_cm, '')::INTEGER,
    NULLIF(product_height_cm, '')::INTEGER,
    NULLIF(product_width_cm, '')::INTEGER
FROM staging_products;

-- ---------- orders ----------
-- order_approved_at / order_delivered_carrier_date / order_delivered_customer_date
-- are legitimately missing for some orders (e.g. canceled or not-yet-delivered
-- orders), so they stay nullable. customer_id has a FOREIGN KEY to
-- cleaned_customers to enforce referential integrity between the two tables.
CREATE TABLE cleaned_orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL REFERENCES cleaned_customers(customer_id),
    order_status TEXT NOT NULL,
    order_purchase_timestamp TIMESTAMP NOT NULL,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP NOT NULL
);

INSERT INTO cleaned_orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::TIMESTAMP,
    NULLIF(order_approved_at, '')::TIMESTAMP,
    NULLIF(order_delivered_carrier_date, '')::TIMESTAMP,
    NULLIF(order_delivered_customer_date, '')::TIMESTAMP,
    order_estimated_delivery_date::TIMESTAMP
FROM staging_orders;

-- ---------- order items ----------
-- order_id alone is not unique (multiple items per order), so the
-- primary key is the composite (order_id, order_item_id).
CREATE TABLE cleaned_order_items (
    order_id TEXT NOT NULL REFERENCES cleaned_orders(order_id),
    order_item_id INTEGER NOT NULL,
    product_id TEXT NOT NULL REFERENCES cleaned_products(product_id),
    seller_id TEXT NOT NULL REFERENCES cleaned_sellers(seller_id),
    shipping_limit_date TIMESTAMP NOT NULL,
    price NUMERIC NOT NULL,
    freight_value NUMERIC NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);

INSERT INTO cleaned_order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
SELECT
    order_id,
    order_item_id::INTEGER,
    product_id,
    seller_id,
    shipping_limit_date::TIMESTAMP,
    price::NUMERIC,
    freight_value::NUMERIC
FROM staging_order_items;

-- ---------- order payments ----------
-- Same idea as order_items: an order can have multiple payments,
-- so the composite key is (order_id, payment_sequential).
CREATE TABLE cleaned_order_payments (
    order_id TEXT NOT NULL REFERENCES cleaned_orders(order_id),
    payment_sequential INTEGER NOT NULL,
    payment_type TEXT NOT NULL,
    payment_installments INTEGER NOT NULL,
    payment_value NUMERIC NOT NULL,
    PRIMARY KEY (order_id, payment_sequential)
);

INSERT INTO cleaned_order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    order_id,
    payment_sequential::INTEGER,
    payment_type,
    payment_installments::INTEGER,
    payment_value::NUMERIC
FROM staging_order_payments;

-- ---------- order reviews ----------
-- review_id alone is NOT unique in this dataset (98,410 distinct
-- review_id values across 99,224 rows), but (review_id, order_id)
-- together is unique, so that pair is the composite primary key.
-- review_comment_title / review_comment_message are legitimately
-- often empty (a customer can rate without writing a comment).
CREATE TABLE cleaned_order_reviews (
    review_id TEXT NOT NULL,
    order_id TEXT NOT NULL REFERENCES cleaned_orders(order_id),
    review_score INTEGER NOT NULL,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP NOT NULL,
    review_answer_timestamp TIMESTAMP NOT NULL,
    PRIMARY KEY (review_id, order_id)
);

INSERT INTO cleaned_order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    review_id,
    order_id,
    review_score::INTEGER,
    NULLIF(review_comment_title, ''),
    NULLIF(review_comment_message, ''),
    review_creation_date::TIMESTAMP,
    review_answer_timestamp::TIMESTAMP
FROM staging_order_reviews;

-- ---------- geolocation ----------
-- This is a reference table with no natural single-row identifier,
-- and it contains many fully duplicated rows (1,000,163 raw rows vs.
-- 738,332 distinct rows). SELECT DISTINCT removes exact duplicates;
-- no PRIMARY KEY is defined since repeated zip codes are expected.
CREATE TABLE cleaned_geolocation (
    geolocation_zip_code_prefix TEXT NOT NULL,
    geolocation_lat NUMERIC NOT NULL,
    geolocation_lng NUMERIC NOT NULL,
    geolocation_city TEXT NOT NULL,
    geolocation_state TEXT NOT NULL
);

INSERT INTO cleaned_geolocation (
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
SELECT DISTINCT
    geolocation_zip_code_prefix,
    geolocation_lat::NUMERIC,
    geolocation_lng::NUMERIC,
    geolocation_city,
    geolocation_state
FROM staging_geolocation;
