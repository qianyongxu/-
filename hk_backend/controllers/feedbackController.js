const { Feedback } = require('../models');

exports.createFeedback = async (req, res) => {
  try {
    const feedback = await Feedback.create(req.body);
    res.json(feedback);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getFeedbacks = async (req, res) => {
  try {
    const { page = 1, limit = 10, status } = req.query;
    const offset = (page - 1) * limit;
    const where = {};
    if (status) where.status = status;
    
    const { count, rows } = await Feedback.findAndCountAll({
      where,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['createdAt', 'DESC']]
    });
    res.json({ data: rows, total: count, page: parseInt(page), limit: parseInt(limit) });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.updateFeedback = async (req, res) => {
  try {
    await Feedback.update(req.body, { where: { id: req.params.id } });
    res.json({ message: 'Updated' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
