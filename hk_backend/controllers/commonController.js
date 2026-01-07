const { uploadFile } = require('../services/ossService');

exports.upload = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const url = await uploadFile(req.file.buffer, req.file.originalname);
    res.json({ url });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Upload failed' });
  }
};
