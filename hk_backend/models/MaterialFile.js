const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MaterialFile = sequelize.define('MaterialFile', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  material_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  url: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  format: {
    type: DataTypes.STRING
  },
  size: {
    type: DataTypes.STRING // e.g., "5.2MB"
  },
  preview_url: {
    type: DataTypes.TEXT
  }
}, {
  timestamps: true,
  underscored: true,
  tableName: 'material_files'
});

module.exports = MaterialFile;
