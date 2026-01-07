const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Software = sequelize.define('Software', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  logo: {
    type: DataTypes.STRING
  },
  supported_formats: {
    type: DataTypes.STRING, // e.g., "psd,ai"
    comment: 'Comma separated formats'
  },
  source_format: {
    type: DataTypes.STRING
  },
  status: {
    type: DataTypes.ENUM('on_shelf', 'off_shelf'),
    defaultValue: 'on_shelf'
  }
}, {
  timestamps: true,
  underscored: true,
  tableName: 'software'
});

module.exports = Software;
