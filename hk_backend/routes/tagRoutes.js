const express = require('express');
const router = express.Router();
const controller = require('../controllers/tagController');

router.get('/', controller.getTags);
router.post('/', controller.createTag);
router.patch('/:id/status', controller.updateTagStatus);

module.exports = router;
