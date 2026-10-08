-- =====================================================================
-- 02 DML: INSERT, UPDATE, DELETE (CRUD = Create, Read, Update, Delete)
-- =====================================================================

-- ---------- INSERT ----------
INSERT INTO customers (first_name, last_name, email, city)
VALUES ('Henry', 'Ssali', 'henry@example.com', 'Jinja');

-- Multiple rows at once
INSERT INTO categories (name) VALUES ('Sports'), ('Garden');

-- RETURNING gives back the generated values (very useful in apps)
INSERT INTO customers (first_name, last_name, email)
VALUES ('Irene', 'Namubiru', 'irene@example.com')
RETURNING customer_id, created_at;

-- Insert from a query (tip: re-run 01_setup_sample_data.sql any time to reset the data)
CREATE TABLE customer_backup AS SELECT * FROM customers WHERE 1 = 0;  -- empty copy
INSERT INTO customer_backup SELECT * FROM customers WHERE country = 'Kenya';

-- ---------- UPSERT (insert or update on conflict) ----------
INSERT INTO customers (first_name, last_name, email, city)
VALUES ('Amina', 'Nakato', 'amina@example.com', 'Wakiso')
ON CONFLICT (email) DO UPDATE SET city = EXCLUDED.city;   -- EXCLUDED = the row you tried to insert

-- ---------- UPDATE ----------
-- ALWAYS use WHERE. Without it, EVERY row changes.
UPDATE products SET price = price * 1.10 WHERE category_id = 2;      -- 10% price rise on Books
UPDATE customers SET city = 'Kampala', country = 'Uganda' WHERE email = 'grace@example.com';
UPDATE products SET stock = stock - 1 WHERE product_id = 1 RETURNING product_id, stock;

-- UPDATE using another table
UPDATE order_items oi
SET    unit_price = p.price
FROM   products p
WHERE  oi.product_id = p.product_id AND oi.order_id = 7;

-- ---------- DELETE ----------
DELETE FROM customer_backup WHERE city = 'Nairobi';
DELETE FROM customers WHERE email = 'irene@example.com' RETURNING *;

-- TRUNCATE empties a whole table fast (cannot be filtered)
TRUNCATE TABLE customer_backup;
DROP TABLE customer_backup;

-- ---------- SAFE HABIT ----------
-- 1) Write the SELECT first:   SELECT * FROM products WHERE stock = 0;
-- 2) Check the rows are right
-- 3) Change SELECT * to DELETE / UPDATE
-- 4) For risky changes use a transaction (see file 10) so you can ROLLBACK

-- ---------- FOREIGN KEY BEHAVIOUR (defined in file 01) ----------
-- ON DELETE CASCADE   : deleting a customer deletes their orders too
-- ON DELETE SET NULL  : deleting a category sets products.category_id to NULL
-- ON DELETE RESTRICT  : blocks deleting a product that appears in order_items
-- Try it (this FAILS on purpose):
-- DELETE FROM products WHERE product_id = 1;
