/*
    ملف schema.sql الرئيسي لمشروع "عقار زين"
    يحتوي على جميع تعريفات الجداول، الفهارس، الدوال المخزنة، والبيانات الأساسية
*/

-- ############ قسم إنشاء الجداول الأساسية ############ --

-- جدول الأدوار
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(20) UNIQUE NOT NULL
);

-- جدول قنوات التواصل
CREATE TABLE IF NOT EXISTS communication_channels (
    id SERIAL PRIMARY KEY,
    channel_name VARCHAR(20) UNIQUE NOT NULL
);

-- جدول تصنيفات العقارات
CREATE TABLE IF NOT EXISTS property_categories (
    id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    type_name VARCHAR(50) UNIQUE NOT NULL,
    attributes_schema JSONB NOT NULL
);

-- جدول المستخدمين
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role_id INTEGER NOT NULL REFERENCES roles(id),
    password_hash VARCHAR(255) NOT NULL,
    description TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول العقارات الرئيسي
CREATE TABLE IF NOT EXISTS properties (
    id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    category_id INTEGER NOT NULL REFERENCES property_categories(id),
    price NUMERIC(15,2) NOT NULL CHECK (price >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('available', 'rented', 'sold', 'pending')),
    owner_id INTEGER NOT NULL REFERENCES users(id),
    total_area NUMERIC(10,2),
    plot_area NUMERIC(10,2),
    bedrooms SMALLINT CHECK (bedrooms >= 0),
    bathrooms SMALLINT CHECK (bathrooms >= 0),
    floors SMALLINT CHECK (floors >= 0),
    year_built SMALLINT,
    condition VARCHAR(20) CHECK (condition IN ('new', 'renovated', 'needs_renovation')),
    amenities JSONB,
    technical_specs JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ############ الجداول المرتبطة بالعقارات ############ --

-- جدول صور العقارات
CREATE TABLE IF NOT EXISTS property_images (
    id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL REFERENCES properties(id),
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول العناوين
CREATE TABLE IF NOT EXISTS addresses (
    id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL REFERENCES properties(id),
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    street VARCHAR(100),
    building_number VARCHAR(20),
    floor VARCHAR(10),
    notes TEXT
);

-- ############ جداول المعاملات ############ --

-- جدول العقود
CREATE TABLE IF NOT EXISTS contracts (
    id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL REFERENCES properties(id),
    user_id INTEGER NOT NULL REFERENCES users(id),
    contract_type VARCHAR(10) NOT NULL CHECK (contract_type IN ('sale', 'rent')),
    start_date DATE NOT NULL,
    end_date DATE CHECK ((contract_type = 'rent' AND end_date > start_date) OR contract_type = 'sale'),
    amount NUMERIC(15,2) NOT NULL CHECK (amount >= 0),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'partial')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول الرسائل
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL REFERENCES properties(id),
    user_id INTEGER NOT NULL REFERENCES users(id),
    channel_id INTEGER NOT NULL REFERENCES communication_channels(id),
    content TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'failed')),
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- ############ جداول العقارات المتخصصة ############ --

-- جدول الوحدات السكنية
CREATE TABLE IF NOT EXISTS residential_properties (
    property_id INTEGER PRIMARY KEY REFERENCES properties(id),
    kitchen_type VARCHAR(50),
    living_rooms SMALLINT,
    has_garage BOOLEAN,
    has_garden BOOLEAN,
    garden_area NUMERIC(10,2)
);

-- جدول الأراضي
CREATE TABLE IF NOT EXISTS land_properties (
    property_id INTEGER PRIMARY KEY REFERENCES properties(id),
    zoning_type VARCHAR(50) NOT NULL,
    terrain_type VARCHAR(50),
    has_utilities BOOLEAN
);

-- جدول العقارات التجارية
CREATE TABLE IF NOT EXISTS commercial_properties (
    property_id INTEGER PRIMARY KEY REFERENCES properties(id),
    business_license_number VARCHAR(100),
    max_capacity INTEGER,
    parking_spaces INTEGER
);

-- جدول السمات المخصصة
CREATE TABLE IF NOT EXISTS property_attributes (
    id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL REFERENCES properties(id),
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value TEXT NOT NULL,
    attribute_type VARCHAR(20) NOT NULL CHECK (attribute_type IN ('number', 'text', 'boolean'))
);

-- ############ الفهارس ############ --
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties(price);
CREATE INDEX IF NOT EXISTS idx_addresses_city ON addresses(city);
CREATE INDEX IF NOT EXISTS idx_contracts_dates ON contracts(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_properties_bedrooms ON properties(bedrooms);
CREATE INDEX IF NOT EXISTS idx_properties_condition ON properties(condition);
CREATE INDEX IF NOT EXISTS idx_properties_amenities ON properties USING GIN (amenities);
CREATE INDEX IF NOT EXISTS idx_properties_area_range ON properties(total_area, plot_area);

-- ############ الدوال والزناد (Triggers) ############ --
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- زناد تحديث المستخدمين
CREATE TRIGGER update_users_modtime
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- زناد تحديث العقارات
CREATE TRIGGER update_properties_modtime
BEFORE UPDATE ON properties
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- دالة التحقق من السمات المطلوبة
CREATE OR REPLACE FUNCTION validate_property_attributes()
RETURNS TRIGGER AS $$
DECLARE
    required_attrs TEXT[];
BEGIN
    SELECT ARRAY(SELECT jsonb_array_elements_text(attributes_schema->'required'))
    INTO required_attrs
    FROM property_categories
    WHERE id = NEW.category_id;

    IF NOT (SELECT NEW.technical_specs ?| required_attrs) THEN
        RAISE EXCEPTION 'السمات المطلوبة مفقودة: %', required_attrs;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_property_attributes
BEFORE INSERT OR UPDATE ON properties
FOR EACH ROW EXECUTE FUNCTION validate_property_attributes();

-- ############ البيانات الأساسية ############ --
INSERT INTO roles (role_name) VALUES 
('عميل'), ('وسيط'), ('مسؤول')
ON CONFLICT (role_name) DO NOTHING;

INSERT INTO communication_channels (channel_name) VALUES 
('whatsapp'), ('sms'), ('email'), ('in_app')
ON CONFLICT (channel_name) DO NOTHING;

INSERT INTO property_categories 
(category_name, type_name, attributes_schema) 
VALUES
('سكني', 'شقة', '{"required": ["غرف_النوم", "الحمامات"], "optional": ["بلكونة", "أثاث"]}'),
('سكني', 'فيلا', '{"required": ["غرف_النوم", "مساحة_الحديقة"], "optional": ["مسبح", "منزل_ضيف"]}'),
('تجاري', 'مكتب', '{"required": ["ترخيص_تجاري"], "optional": ["منطقة_استقبال"]}'),
('أرض', 'زراعية', '{"required": ["المساحة_الإجمالية"], "optional": ["مصدر_مياه"]}')
ON CONFLICT (type_name) DO NOTHING;

-- ############ تعليقات إرشادية ############ --
COMMENT ON TABLE properties IS 'الجدول الرئيسي لجميع العقارات مع البيانات المشتركة';
COMMENT ON COLUMN properties.technical_specs IS 'يحتوي على المواصفات الفنية المحددة حسب كل نوع عقار';
COMMENT ON INDEX idx_properties_amenities IS 'فهرس لتحسين البحث في وسائل الراحة باستخدام مشغلات JSONB';

/*
    تعليمات التنفيذ:
    1. احفظ هذا الملف كـ schema.sql
    2. نفذ الكود باستخدام:
       psql -U username -d dbname -f schema.sql
    3. للتراجع عن جميع التغييرات (في حالة الاختبار):
       DROP SCHEMA public CASCADE;
       CREATE SCHEMA public;
*/