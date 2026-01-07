const { Software } = require('../models');
const { Op } = require('sequelize');

exports.getSoftware = async (req, res) => {
  try {
    const { page = 1, limit = 10, search, status } = req.query;
    const offset = (page - 1) * limit;

    const where = {};
    if (search) where.name = { [Op.like]: `%${search}%` };
    if (status) where.status = status;

    const { count, rows } = await Software.findAndCountAll({
      where,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['created_at', 'DESC']]
    });

    res.json({
      total: count,
      page: parseInt(page),
      totalPages: Math.ceil(count / limit),
      data: rows
    });
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.createSoftware = async (req, res) => {
  try {
    const { name, logo, supported_formats, source_format } = req.body;
    const software = await Software.create({
      name,
      logo,
      supported_formats,
      source_format
    });
    res.status(201).json(software);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.updateSoftwareStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const software = await Software.findByPk(req.params.id);
    if (!software) return res.status(404).json({ message: 'Not Found' });
    
    software.status = status;
    await software.save();
    res.json(software);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.updateSoftware = async (req, res) => {
  try {
    const { name, logo, supported_formats, source_format, status } = req.body;
    const software = await Software.findByPk(req.params.id);
    if (!software) return res.status(404).json({ message: 'Not Found' });

    await software.update({
        name, logo, supported_formats, source_format, status
    });
    res.json(software);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};
