const { HelpGuide } = require('../models');

exports.getHelpGuides = async (req, res) => {
  try {
    const guides = await HelpGuide.findAll({
      where: { is_active: true },
      order: [['sort_order', 'ASC']]
    });
    res.json(guides);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getAllHelpGuides = async (req, res) => { // Admin
  try {
    const guides = await HelpGuide.findAll({
      order: [['sort_order', 'ASC']]
    });
    res.json(guides);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createHelpGuide = async (req, res) => {
  try {
    const guide = await HelpGuide.create(req.body);
    res.json(guide);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.updateHelpGuide = async (req, res) => {
  try {
    await HelpGuide.update(req.body, { where: { id: req.params.id } });
    res.json({ message: 'Updated' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.deleteHelpGuide = async (req, res) => {
  try {
    await HelpGuide.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
