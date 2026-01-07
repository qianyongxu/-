const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Feedback = sequelize.define('Feedback', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  user_id: { type: DataTypes.INTEGER, allowNull: true },
  content: { type: DataTypes.TEXT, allowNull: false },
  contact: { type: DataTypes.STRING, allowNull: true },
  images: { type: DataTypes.JSON, allowNull: true }, // Array of URLs
  status: { type: DataTypes.ENUM('pending', 'processed'), defaultValue: 'pending' }
}, {
  tableName: 'feedbacks',
  timestamps: true
});

module.exports = Feedback;
