-- Clients (avec données adaptées pour ES)
SELECT 
    id,
    reference,
    company_name,
    first_name,
    last_name,
    email,
    phone,
    address,
    city,
    state,
    country,
    postal_code,
    type,
    status,
    CAST(credit_limit AS DECIMAL(10,2)) as credit_limit,
    tax_number,
    payment_terms,
    DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%s.000Z') as created_at,
    DATE_FORMAT(updated_at, '%Y-%m-%dT%H:%i:%s.000Z') as updated_at
FROM clients
WHERE updated_at > :last_sync_date
ORDER BY id;

-- Products
SELECT 
    id,
    reference,
    name,
    description,
    category,
    CAST(price AS DECIMAL(10,2)) as price,
    CAST(weight AS DECIMAL(10,2)) as weight,
    stock_quantity,
    minimum_stock,
    reorder_point,
    supplier_reference,
    status,
    DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%s.000Z') as created_at,
    DATE_FORMAT(updated_at, '%Y-%m-%dT%H:%i:%s.000Z') as updated_at
FROM products
WHERE updated_at > :last_sync_date
ORDER BY id;

-- Warehouses
SELECT 
    id,
    code,
    name,
    address,
    city,
    state,
    country,
    postal_code,
    phone,
    email,
    capacity,
    type,
    status,
    DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%s.000Z') as created_at,
    DATE_FORMAT(updated_at, '%Y-%m-%dT%H:%i:%s.000Z') as updated_at
FROM warehouses
WHERE updated_at > :last_sync_date
ORDER BY id;

-- Shipments
SELECT 
    id,
    tracking_number,
    origin_warehouse_id,
    destination_warehouse_id,
    client_id,
    DATE_FORMAT(order_date, '%Y-%m-%dT%H:%i:%s.000Z') as order_date,
    DATE_FORMAT(shipping_date, '%Y-%m-%dT%H:%i:%s.000Z') as shipping_date,
    DATE_FORMAT(expected_delivery_date, '%Y-%m-%dT%H:%i:%s.000Z') as expected_delivery_date,
    DATE_FORMAT(actual_delivery_date, '%Y-%m-%dT%H:%i:%s.000Z') as actual_delivery_date,
    status,
    shipping_method,
    CAST(shipping_cost AS DECIMAL(10,2)) as shipping_cost,
    priority,
    notes,
    DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%s.000Z') as created_at,
    DATE_FORMAT(updated_at, '%Y-%m-%dT%H:%i:%s.000Z') as updated_at
FROM shipments
WHERE updated_at > :last_sync_date
ORDER BY id;

-- Shipment Items
SELECT 
    id,
    shipment_id,
    product_id,
    quantity,
    CAST(unit_price AS DECIMAL(10,2)) as unit_price,
    DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%s.000Z') as created_at,
    DATE_FORMAT(updated_at, '%Y-%m-%dT%H:%i:%s.000Z') as updated_at
FROM shipment_items
WHERE updated_at > :last_sync_date
ORDER BY id;
