const { Tag, Material } = require('../models');
const { Op } = require('sequelize');

exports.getTags = async (req, res) => {
  try {
    const { page = 1, limit = 10, search, status } = req.query;
    const offset = (page - 1) * limit;

    const where = {};
    if (search) where.name = { [Op.like]: `%${search}%` };
    if (status) where.status = status;

    // In a real scenario, we might want to aggregate counts on the fly if not stored
    // For now we assume they are stored/updated
    
    const { count, rows } = await Tag.findAndCountAll({
      where,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['created_at', 'DESC']],
      // Include count of associated materials
      // attributes: {
      //   include: [
      //     [sequelize.fn('COUNT', sequelize.col('Materials.id')), 'material_count']
      //   ]
      // },
      // include: [{ model: Material, attributes: [] }],
      // group: ['Tag.id']
    });

    res.json({
      total: count,
      page: parseInt(page),
      totalPages: Math.ceil(count / limit),
      data: rows
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.createTag = async (req, res) => {
  try {
    const { name, materials } = req.body;
    const tag = await Tag.create({ name });
    
    if (materials && materials.length > 0) {
      await tag.setMaterials(materials);
    }
    
    res.status(201).json(tag);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.updateTagStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const tag = await Tag.findByPk(req.params.id);
    if (!tag) return res.status(404).json({ message: 'Not Found' });
    
    tag.status = status;
    await tag.save();
    res.json(tag);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};
