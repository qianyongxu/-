const express = require('express');
const router = express.Router();
const controller = require('../controllers/userController');

router.get('/me', controller.getMe);
router.post('/favorites/toggle', controller.toggleFavorite);
router.get('/favorites/:materialId', controller.checkFavorite);
router.get('/:id/favorites', controller.getFavorites);

router.get('/', controller.getUsers);
router.get('/:id', controller.getUser);
router.patch('/:id/status', controller.updateUserStatus);

module.exports = router;
