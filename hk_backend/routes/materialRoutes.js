const express = require('express');
const router = express.Router();
const controller = require('../controllers/materialController');

router.get('/', controller.getMaterials);
router.post('/', controller.createMaterial);
router.get('/:id', controller.getMaterial);
router.post('/:id/download', controller.downloadMaterial);
router.patch('/:id/status', controller.updateMaterialStatus);
router.put('/:id', controller.updateMaterial);

module.exports = router;
