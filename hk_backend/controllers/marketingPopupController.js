const { MarketingPopup } = require('../models');
const { Op } = require('sequelize');

exports.getActivePopup = async (req, res) => {
  try {
    const now = new Date();
    // Logic to find best popup (e.g. latest active)
    const popup = await MarketingPopup.findOne({
      where: {
        status: 'active',
        [Op.or]: [
            { start_time: null },
            { start_time: { [Op.lte]: now } }
        ],
        [Op.or]: [
            { end_time: null },
            { end_time: { [Op.gte]: now } }
        ]
      },
      order: [['createdAt', 'DESC']]
    });
    res.json(popup);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getPopups = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;
    const { count, rows } = await MarketingPopup.findAndCountAll({
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['createdAt', 'DESC']]
    });
    res.json({ data: rows, total: count, page: parseInt(page), limit: parseInt(limit) });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createPopup = async (req, res) => {
  try {
    const popup = await MarketingPopup.create(req.body);
    res.json(popup);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.updatePopup = async (req, res) => {
  try {
    await MarketingPopup.update(req.body, { where: { id: req.params.id } });
    res.json({ message: 'Updated' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.deletePopup = async (req, res) => {
  try {
    await MarketingPopup.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
