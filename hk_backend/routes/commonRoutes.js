const express = require('express');
const router = express.Router();
const controller = require('../controllers/commonController');
const proxyController = require('../controllers/proxyController');
const multer = require('multer');

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

router.post('/upload', upload.single('file'), controller.upload);
router.get('/proxy', proxyController.proxyImage);

module.exports = router;
