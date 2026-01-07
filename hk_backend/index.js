const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const { sequelize } = require('./models');

const materialRoutes = require('./routes/materialRoutes');
const userRoutes = require('./routes/userRoutes');
const commonRoutes = require('./routes/commonRoutes');
const authRoutes = require('./routes/authRoutes');
const tagRoutes = require('./routes/tagRoutes');
const softwareRoutes = require('./routes/softwareRoutes');
const filterRoutes = require('./routes/filterRoutes');
const feedbackRoutes = require('./routes/feedbackRoutes');
const helpGuideRoutes = require('./routes/helpGuideRoutes');
const marketingPopupRoutes = require('./routes/marketingPopupRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public')); // Serve static files (legal docs)

// Routes
app.use('/api/materials', materialRoutes);
app.use('/api/users', userRoutes);
app.use('/api/common', commonRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/tags', tagRoutes);
app.use('/api/software', softwareRoutes);
app.use('/api/filters', filterRoutes);
app.use('/api/feedback', feedbackRoutes);
app.use('/api/help-guides', helpGuideRoutes);
app.use('/api/marketing-popups', marketingPopupRoutes);

// Sync Database and Start Server
sequelize.sync({ alter: true }) // use { force: true } to drop and recreate tables if needed for UUID change
  .then(() => {
    console.log('Database synced');
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('Failed to sync database:', err);
  });
