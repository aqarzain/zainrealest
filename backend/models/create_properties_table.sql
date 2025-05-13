-- backend/database/create_properties_table.sql

CREATE TABLE IF NOT EXISTS properties (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(12, 2) NOT NULL,
    location VARCHAR(255) NOT NULL,
    type VARCHAR(100), -- مثال: شقة، فيلا، أرض
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
