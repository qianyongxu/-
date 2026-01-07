const express = require('express');
const router = express.Router();
const controller = require('../controllers/softwareController');

router.get('/', controller.getSoftware);
router.post('/', controller.createSoftware);
router.put('/:id', controller.updateSoftware);
router.patch('/:id/status', controller.updateSoftwareStatus);

module.exports = router;
