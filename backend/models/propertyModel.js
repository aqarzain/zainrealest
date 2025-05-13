// backend/models/propertyModel.js

const db = require('../config/db');

// جلب جميع العقارات
exports.getAll = async () => {
  const result = await db.query('SELECT * FROM properties ORDER BY created_at DESC');
  return result.rows;
};

// جلب عقار بالـ ID
exports.getById = async (id) => {
  const result = await db.query('SELECT * FROM properties WHERE id = $1', [id]);
  return result.rows[0];
};

// إضافة عقار جديد
exports.create = async (data) => {
  const { title, description, price, location, type, image_url } = data;
  const result = await db.query(
    'INSERT INTO properties (title, description, price, location, type, image_url) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
    [title, description, price, location, type, image_url]
  );
  return result.rows[0];
};

// تحديث عقار
exports.update = async (id, data) => {
  const { title, description, price, location, type, image_url } = data;
  const result = await db.query(
    'UPDATE properties SET title = $1, description = $2, price = $3, location = $4, type = $5, image_url = $6 WHERE id = $7 RETURNING *',
    [title, description, price, location, type, image_url, id]
  );
  return result.rows[0];
};

// حذف عقار
exports.remove = async (id) => {
  await db.query('DELETE FROM properties WHERE id = $1', [id]);
};
