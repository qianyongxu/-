const express = require('express');
const router = express.Router();
const controller = require('../controllers/feedbackController');

router.post('/', controller.createFeedback);
router.get('/', controller.getFeedbacks); // Admin
router.put('/:id', controller.updateFeedback); // Admin

module.exports = router;
