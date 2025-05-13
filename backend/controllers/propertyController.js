// backend/controllers/propertyController.js

const propertyModel = require('../models/propertyModel');

// جلب جميع العقارات
exports.getAllProperties = async (req, res) => {
  try {
    const properties = await propertyModel.getAll();
    res.json(properties);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// جلب عقار واحد
exports.getPropertyById = async (req, res) => {
  try {
    const property = await propertyModel.getById(req.params.id);
    if (!property) return res.status(404).json({ message: 'العقار غير موجود' });
    res.json(property);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// إضافة عقار
exports.createProperty = async (req, res) => {
  try {
    const newProperty = await propertyModel.create(req.body);
    res.status(201).json(newProperty);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// تحديث عقار
exports.updateProperty = async (req, res) => {
  try {
    const updated = await propertyModel.update(req.params.id, req.body);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// حذف عقار
exports.deleteProperty = async (req, res) => {
  try {
    await propertyModel.remove(req.params.id);
    res.json({ message: 'تم حذف العقار' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
