// GET /api/companies/:company_id/alerts/low-stock

const express = require('express');
const router  = express.Router();
const db      = require('../db');

router.get('/api/companies/:company_id/alerts/low-stock', async (req, res) => {
  const { company_id } = req.params;

  if (isNaN(company_id)) {
    return res.status(400).json({ error: 'company_id must be a valid number' });
  }

  try {
    const query = `
      SELECT
        p.id                    AS product_id,
        p.name                  AS product_name,
        p.sku,
        p.low_stock_threshold   AS threshold,
        w.id                    AS warehouse_id,
        w.name                  AS warehouse_name,
        i.quantity              AS current_stock,
        s.id                    AS supplier_id,
        s.name                  AS supplier_name,
        s.contact_email,

        COALESCE(
          SUM(CASE WHEN ih.change_quantity < 0
              THEN ABS(ih.change_quantity) ELSE 0 END) / 30.0,
        0) AS avg_daily_sales

      FROM products p
      JOIN inventory i
        ON i.product_id = p.id
      JOIN warehouses w
        ON w.id = i.warehouse_id
      LEFT JOIN product_suppliers ps
        ON ps.product_id = p.id
      LEFT JOIN suppliers s
        ON s.id = ps.supplier_id
      LEFT JOIN inventory_history ih
        ON ih.inventory_id = i.id
       AND ih.changed_at >= NOW() - INTERVAL 30 DAY

      WHERE
        w.company_id = ?
        AND i.quantity < p.low_stock_threshold

      GROUP BY
        p.id, p.name, p.sku, p.low_stock_threshold,
        w.id, w.name, i.quantity,
        s.id, s.name, s.contact_email

      HAVING avg_daily_sales > 0
    `;

    const rows = await db.query(query, [company_id]);

    if (rows.length === 0) {
      return res.status(200).json({ alerts: [], total_alerts: 0 });
    }

    const alerts = rows.map(row => {
      const avgSales = parseFloat(row.avg_daily_sales);

      const daysUntilStockout = avgSales > 0
        ? Math.floor(row.current_stock / avgSales)
        : null;

      return {
        product_id:          row.product_id,
        product_name:        row.product_name,
        sku:                 row.sku,
        warehouse_id:        row.warehouse_id,
        warehouse_name:      row.warehouse_name,
        current_stock:       row.current_stock,
        threshold:           row.threshold,
        days_until_stockout: daysUntilStockout,
        supplier: row.supplier_id ? {
          id:            row.supplier_id,
          name:          row.supplier_name,
          contact_email: row.contact_email
        } : null
      };
    });

    return res.status(200).json({
      alerts,
      total_alerts: alerts.length
    });

  } catch (err) {
    console.error('Error in low-stock alert endpoint:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;