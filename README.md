# 02: INSERT, UPDATE, DELETE (CRUD)

A PostgreSQL practice script covering data manipulation (DML) on the `shop_db` database: adding, changing, and removing rows. It builds directly on the tables and sample data from `01_setup_sample_data.sql`.

## Contents

| File | Purpose |
|------|---------|
| `02_insert_update_delete.sql` | Worked examples of `INSERT`, upsert, `UPDATE`, `DELETE`, and `TRUNCATE`, with notes on safe habits and foreign key behaviour |

## Before You Start

Run `01_setup_sample_data.sql` first so the tables exist and contain the sample data.

```bash
psql -U postgres -d shop_db -f 01_setup_sample_data.sql
psql -U postgres -d shop_db -f 02_insert_update_delete.sql
```

## What Each Section Does

### INSERT
| Statement | Effect |
|-----------|--------|
| Single-row insert | Adds customer Henry Ssali (Jinja) |
| Multi-row insert | Adds two categories, `Sports` and `Garden`, in one statement |
| `INSERT ... RETURNING` | Adds customer Irene Namubiru and returns her generated `customer_id` and `created_at` |
| `CREATE TABLE ... AS SELECT ... WHERE 1 = 0` | Creates `customer_backup` as an empty copy of `customers` (the false condition copies the columns but no rows) |
| `INSERT ... SELECT` | Copies the Kenyan customers (David and Esther) into `customer_backup` |

### UPSERT
Tries to insert Amina Nakato again. Because `email` is unique, the insert conflicts, and `ON CONFLICT (email) DO UPDATE` changes her city to `Wakiso` instead. `EXCLUDED` refers to the row that was attempted.

### UPDATE
| Statement | Effect |
|-----------|--------|
| `price * 1.10 WHERE category_id = 2` | 10% price rise on all Books (SQL Made Easy and Python Crash Course) |
| Update Grace's record | Sets her city to Kampala (she had a `NULL` city) |
| `stock = stock - 1 ... RETURNING` | Reduces the Wireless Mouse stock by 1 and shows the new value |
| `UPDATE ... FROM` | Sets `unit_price` on order 7's items to the current product price, using values from the `products` table |

### DELETE and TRUNCATE
| Statement | Effect |
|-----------|--------|
| `DELETE FROM customer_backup WHERE city = 'Nairobi'` | Removes the two backed-up Nairobi customers |
| `DELETE ... RETURNING *` | Deletes Irene and shows the deleted row |
| `TRUNCATE TABLE customer_backup` | Empties the table in one fast step (cannot use `WHERE`) |
| `DROP TABLE customer_backup` | Removes the temporary table entirely |

## Key Habits Taught

1. **Always use `WHERE` with `UPDATE` and `DELETE`.** Without it, every row changes.
2. **Write the `SELECT` first.** Check the rows are the ones you expect, then change `SELECT *` into `UPDATE` or `DELETE`.
3. **Use transactions for risky changes** so you can `ROLLBACK` (covered in file 10).
4. **Use `RETURNING`** to see what was inserted, updated, or deleted without a second query.

## Foreign Key Behaviour (from file 01)

| Rule | Result |
|------|--------|
| `ON DELETE CASCADE` | Deleting a customer also deletes their orders |
| `ON DELETE SET NULL` | Deleting a category sets `products.category_id` to `NULL` |
| `ON DELETE RESTRICT` | Blocks deleting a product that appears in `order_items` |

The script ends with a commented-out `DELETE FROM products WHERE product_id = 1;`. Uncomment it to see the `RESTRICT` rule fail on purpose, because the Wireless Mouse appears in existing orders.

## Notes

- **Don't re-run this file on its own.** The second run fails on the unique `email` and category `name` constraints, and the price rise would be applied again on top of the first one. To reset, re-run `01_setup_sample_data.sql`, which drops and rebuilds all the tables.
- If the script stops partway through, `customer_backup` may be left behind. Remove it with `DROP TABLE IF EXISTS customer_backup;`.
- The `UPDATE ... FROM` on order 7 won't visibly change anything with the original data, because that order's unit prices already match the current product prices. It shows the syntax, and would matter after a price change.
- `CREATE TABLE ... AS` copies column names and types, but **not** constraints, defaults, or the identity setting, so `customer_backup` is a plain table.
