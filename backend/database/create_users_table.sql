-- backend/database/create_users_table.sql

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user', -- ممكن تكون admin أو user
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
