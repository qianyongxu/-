const { User, sequelize } = require('../models');

exports.getFilterOptions = async (req, res) => {
  try {
    const deviceModels = await User.findAll({
      attributes: [[sequelize.fn('DISTINCT', sequelize.col('device_model')), 'value']],
      where: sequelize.where(sequelize.col('device_model'), 'IS NOT', null)
    });
    
    const systemVersions = await User.findAll({
      attributes: [[sequelize.fn('DISTINCT', sequelize.col('system_version')), 'value']],
      where: sequelize.where(sequelize.col('system_version'), 'IS NOT', null)
    });
    
    const appVersions = await User.findAll({
      attributes: [[sequelize.fn('DISTINCT', sequelize.col('app_version')), 'value']],
      where: sequelize.where(sequelize.col('app_version'), 'IS NOT', null)
    });

    res.json({
      device_models: deviceModels.map(i => i.get('value')).filter(Boolean),
      system_versions: systemVersions.map(i => i.get('value')).filter(Boolean),
      app_versions: appVersions.map(i => i.get('value')).filter(Boolean)
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};
