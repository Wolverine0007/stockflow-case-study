CREATE TABLE companies (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(255) NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouses (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    company_id  INT NOT NULL,
    name        VARCHAR(255) NOT NULL,
    location    VARCHAR(255),
    FOREIGN KEY (company_id) REFERENCES companies(id)
);

CREATE TABLE products (
    id                  INT PRIMARY KEY AUTO_INCREMENT,
    company_id          INT NOT NULL,
    name                VARCHAR(255) NOT NULL,
    sku                 VARCHAR(100) NOT NULL UNIQUE,
    price               DECIMAL(10, 2) NOT NULL,
    product_type        VARCHAR(50) DEFAULT 'single',
    low_stock_threshold INT DEFAULT 10,
    FOREIGN KEY (company_id) REFERENCES companies(id)
);

CREATE TABLE inventory (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    product_id    INT NOT NULL,
    warehouse_id  INT NOT NULL,
    quantity      INT NOT NULL DEFAULT 0,
    UNIQUE (product_id, warehouse_id),
    FOREIGN KEY (product_id)   REFERENCES products(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

CREATE TABLE inventory_history (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    inventory_id    INT NOT NULL,
    change_quantity INT NOT NULL,
    reason          VARCHAR(255),
    changed_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES inventory(id)
);

CREATE TABLE suppliers (
    id             INT PRIMARY KEY AUTO_INCREMENT,
    name           VARCHAR(255) NOT NULL,
    contact_email  VARCHAR(255),
    phone          VARCHAR(50)
);

CREATE TABLE product_suppliers (
    id           INT PRIMARY KEY AUTO_INCREMENT,
    product_id   INT NOT NULL,
    supplier_id  INT NOT NULL,
    FOREIGN KEY (product_id)  REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

CREATE TABLE bundle_items (
    id                 INT PRIMARY KEY AUTO_INCREMENT,
    bundle_product_id  INT NOT NULL,
    child_product_id   INT NOT NULL,
    quantity           INT NOT NULL DEFAULT 1,
    FOREIGN KEY (bundle_product_id) REFERENCES products(id),
    FOREIGN KEY (child_product_id)  REFERENCES products(id)
);

CREATE INDEX idx_inventory_product   ON inventory(product_id);
CREATE INDEX idx_inventory_warehouse ON inventory(warehouse_id);
CREATE INDEX idx_history_changed_at  ON inventory_history(changed_at);