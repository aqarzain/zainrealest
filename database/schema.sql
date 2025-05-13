---

## **الملف الثاني: schema.sql**
### كود احترافي لإنشاء الجداول الأساسية على PostgreSQL.

```sql
-- users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    user_type VARCHAR(20) CHECK (user_type IN ('client', 'owner', 'staff')),
    password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- properties table
CREATE TABLE properties (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) CHECK (type IN ('شقة', 'فيلا', 'أرض', 'محل', 'أخرى')),
    city VARCHAR(100),
    location POINT,
    area NUMERIC(10, 2),
    price NUMERIC(12, 2),
    status VARCHAR(20) CHECK (status IN ('متاح', 'مباع', 'مؤجر')) DEFAULT 'متاح',
    images TEXT[],
    owner_id INT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- inquiries table
CREATE TABLE inquiries (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    property_id INT REFERENCES properties(id),
    message TEXT NOT NULL,
    replied BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- favorites table
CREATE TABLE favorites (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    property_id INT REFERENCES properties(id),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- bookings table
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    property_id INT REFERENCES properties(id),
    booking_type VARCHAR(20) CHECK (booking_type IN ('زيارة', 'حجز')),
    status VARCHAR(20) CHECK (status IN ('قيد المراجعة', 'تمت الموافقة', 'مرفوض')) DEFAULT 'قيد المراجعة',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
