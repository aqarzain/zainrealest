CREATE TABLE IF NOT EXISTS properties (
    id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    price NUMERIC(12, 2) NOT NULL,
    area FLOAT,
    location_id INT REFERENCES locations(id) ON DELETE SET NULL,
    location VARCHAR(255),
    owner_name VARCHAR(100),
    owner_phone VARCHAR(20),
    user_id INTEGER REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
