const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Material = sequelize.define('Material', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  file_url: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  preview_url: {
    type: DataTypes.TEXT
  },
  file_size: {
    type: DataTypes.INTEGER, // in bytes
    defaultValue: 0
  },
  category: {
    type: DataTypes.STRING
  },
  type: {
    type: DataTypes.ENUM('normal', 'member'),
    defaultValue: 'normal'
  },
  exposure_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  click_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  download_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  share_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  click_rate: {
    type: DataTypes.VIRTUAL,
    get() {
      const exposure = this.getDataValue('exposure_count') || 0;
      const click = this.getDataValue('click_count') || 0;
      if (!exposure) return '0%';
      return ((click / exposure) * 100).toFixed(2) + '%';
    }
  },
  download_rate: {
    type: DataTypes.VIRTUAL,
    get() {
      const click = this.getDataValue('click_count') || 0;
      const download = this.getDataValue('download_count') || 0;
      if (!click) return '0%';
      return ((download / click) * 100).toFixed(2) + '%';
    }
  },
  status: {
    type: DataTypes.ENUM('on_shelf', 'off_shelf'),
    defaultValue: 'on_shelf'
  },
  // Virtual fields for rates
  click_rate: {
    type: DataTypes.VIRTUAL,
    get() {
      const exposure = this.getDataValue('exposure_count') || 0;
      const click = this.getDataValue('click_count') || 0;
      if (exposure === 0) return 0;
      return parseFloat((click / exposure).toFixed(4));
    }
  },
  download_rate: {
    type: DataTypes.VIRTUAL,
    get() {
      const click = this.getDataValue('click_count') || 0;
      const download = this.getDataValue('download_count') || 0;
      if (click === 0) return 0;
      return parseFloat((download / click).toFixed(4));
    }
  }
}, {
  timestamps: true,
  underscored: true,
  tableName: 'materials'
});

module.exports = Material;
