const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MarketingPopup = sequelize.define('MarketingPopup', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  title: { type: DataTypes.STRING, allowNull: false },
  image_url: { type: DataTypes.STRING, allowNull: false },
  target_url: { type: DataTypes.STRING, allowNull: true }, // Deep link or Web URL
  target_user_type: { type: DataTypes.ENUM('all', 'vip', 'free'), defaultValue: 'all' },
  start_time: { type: DataTypes.DATE, allowNull: true },
  end_time: { type: DataTypes.DATE, allowNull: true },
  status: { type: DataTypes.ENUM('active', 'inactive'), defaultValue: 'active' },
  frequency: { type: DataTypes.ENUM('once', 'daily', 'always'), defaultValue: 'daily' }
}, {
  tableName: 'marketing_popups',
  timestamps: true
});

module.exports = MarketingPopup;
