const sequelize = require('../config/database');
const User = require('./User');
const Material = require('./Material');
const Tag = require('./Tag');
const Software = require('./Software');

const MaterialFile = require('./MaterialFile');
const Feedback = require('./Feedback');
const HelpGuide = require('./HelpGuide');
const MarketingPopup = require('./MarketingPopup');

// Relationships
// Software.hasMany(Material, { foreignKey: 'software_id' });
// Material.belongsTo(Software, { foreignKey: 'software_id' });

Material.belongsToMany(Software, { through: 'MaterialSoftwares', as: 'Softwares' });
Software.belongsToMany(Material, { through: 'MaterialSoftwares', as: 'Materials' });

Material.belongsToMany(Tag, { through: 'MaterialTags', as: 'Tags' });
Tag.belongsToMany(Material, { through: 'MaterialTags', as: 'Materials' });

Material.hasMany(MaterialFile, { as: 'Files', foreignKey: 'material_id' });
MaterialFile.belongsTo(Material, { foreignKey: 'material_id' });

User.belongsToMany(Material, { through: 'UserFavorites', as: 'Favorites' });
Material.belongsToMany(User, { through: 'UserFavorites', as: 'FavoritedBy' });

module.exports = {
  sequelize,
  User,
  Material,
  Tag,
  Software,
  MaterialFile,
  Feedback,
  HelpGuide,
  MarketingPopup
};
