const express = require('express');
const router = express.Router();
const controller = require('../controllers/filterController');

router.get('/options', controller.getFilterOptions);

module.exports = router;
