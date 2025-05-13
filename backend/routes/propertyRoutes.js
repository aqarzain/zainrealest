// backend/routes/propertyRoutes.js

const express = require('express');
const router = express.Router();
const propertyController = require('../controllers/propertyController');

// جميع العقارات
router.get('/', propertyController.getAllProperties);

// عقار واحد حسب ID
router.get('/:id', propertyController.getPropertyById);

// إضافة عقار جديد
router.post('/', propertyController.createProperty);

// تعديل عقار
router.put('/:id', propertyController.updateProperty);

// حذف عقار
router.delete('/:id', propertyController.deleteProperty);

module.exports = router;

/*
طريقة الاستخدام:
- في index.js أضف:
  app.use('/api/properties', propertyRoutes);

- المسارات المتاحة:
  GET    /api/properties
  GET    /api/properties/:id
  POST   /api/properties
  PUT    /api/properties/:id
  DELETE /api/properties/:id
*/
