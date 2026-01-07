const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const HelpGuide = sequelize.define('HelpGuide', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  title: { type: DataTypes.STRING, allowNull: false },
  content: { type: DataTypes.TEXT, allowNull: false }, // HTML or Text
  category: { type: DataTypes.STRING, allowNull: true },
  sort_order: { type: DataTypes.INTEGER, defaultValue: 0 },
  is_active: { type: DataTypes.BOOLEAN, defaultValue: true }
}, {
  tableName: 'help_guides',
  timestamps: true
});

module.exports = HelpGuide;
