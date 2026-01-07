const express = require('express');
const router = express.Router();
const controller = require('../controllers/helpGuideController');

router.get('/', controller.getHelpGuides); // Public
router.get('/admin', controller.getAllHelpGuides); // Admin
router.post('/', controller.createHelpGuide); // Admin
router.put('/:id', controller.updateHelpGuide); // Admin
router.delete('/:id', controller.deleteHelpGuide); // Admin

module.exports = router;
