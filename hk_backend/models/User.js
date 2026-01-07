const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  openid: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false
  },
  unionid: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: true
  },
  nickname: {
    type: DataTypes.STRING
  },
  avatar: {
    type: DataTypes.STRING
  },
  type: {
    type: DataTypes.ENUM('normal', 'monthly', 'quarterly', 'annual'),
    defaultValue: 'normal'
  },
  country: DataTypes.STRING,
  province: DataTypes.STRING,
  city: DataTypes.STRING,
  district: DataTypes.STRING,
  device_model: DataTypes.STRING,
  system_version: DataTypes.STRING,
  app_version: DataTypes.STRING,
  active_status: {
    type: DataTypes.STRING, 
    // high, medium, low, lost_general, lost_serious
    defaultValue: 'high'
  },
  today_download_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  total_download_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  favorites_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  last_login_time: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  status: {
    type: DataTypes.ENUM('active', 'banned', 'restricted'),
    defaultValue: 'active'
  }
}, {
  timestamps: true,
  underscored: true,
  tableName: 'users'
});

module.exports = User;
