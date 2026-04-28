# StockFlow – Backend Engineering Case Study

Submitted by: Sanket Banate

## Structure

| File | Description |
|------|-------------|
| `create_product.py` | Part 1 – Fixed Flask endpoint for creating products |
| `schema.sql` | Part 2 – Database schema design |
| `low_stock_alerts.js` | Part 3 – Low stock alert API (Node.js/Express) |

## Part 1 – Bugs Fixed
1. Missing field validation (KeyError crash)
2. SKU uniqueness check
3. Two commits merged into one atomic transaction
4. Negative price/quantity validation
5. Optional initial_quantity handled with .get()
6. Correct 201 status code on creation

## Part 2 – Schema Design
Full relational schema with companies, warehouses, products,
inventory, inventory_history, suppliers, and bundle support.

## Part 3 – Low Stock Alerts
GET /api/companies/:company_id/alerts/low-stock
Returns products below threshold with supplier info and days until stockout.
