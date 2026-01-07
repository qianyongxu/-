const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Tag = sequelize.define('Tag', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  // Aggregated fields (updated via hooks or periodic jobs in a real app, 
  // but for simplicity we might update them when material stats change or just calculate on query)
  // Here we define them as columns for persistent storage and faster read
  exposure_sum: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  click_sum: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  download_sum: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  share_sum: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  status: {
    type: DataTypes.ENUM('on_shelf', 'off_shelf'),
    defaultValue: 'on_shelf'
  }
}, {
  timestamps: true,
  underscored: true,
  tableName: 'tags'
});

module.exports = Tag;
