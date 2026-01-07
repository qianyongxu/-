const express = require('express');
const router = express.Router();
const controller = require('../controllers/marketingPopupController');

router.get('/active', controller.getActivePopup); // Public
router.get('/', controller.getPopups); // Admin
router.post('/', controller.createPopup); // Admin
router.put('/:id', controller.updatePopup); // Admin
router.delete('/:id', controller.deletePopup); // Admin

module.exports = router;
