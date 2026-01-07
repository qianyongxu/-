const { User, Material } = require('../models');
const { Op } = require('sequelize');

exports.getMe = async (req, res) => {
    try {
        // userId is extracted from JWT token middleware (req.user.id)
        // Or if using basic ID passing for now:
        let userId = req.user ? req.user.id : null;
        
        // Fallback for current simple implementation if no auth middleware
        if (!userId && req.headers.authorization) {
            // parsing "Bearer jwt_token_USERID" as simulated in frontend
            const token = req.headers.authorization.split(' ')[1];
            if (token.startsWith('jwt_token_')) {
                userId = token.replace('jwt_token_', '');
            }
        }

        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const user = await User.findByPk(userId);
        if (!user) return res.status(404).json({ message: 'User not found' });

        res.json({ user });
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.toggleFavorite = async (req, res) => {
    try {
        const { userId, materialId } = req.body;
        const user = await User.findByPk(userId);
        const material = await Material.findByPk(materialId);

        if (!user || !material) return res.status(404).json({ message: 'User or Material not found' });

        const hasFavorited = await user.hasFavorite(material);
        if (hasFavorited) {
            await user.removeFavorite(material);
            user.favorites_count = Math.max(0, (user.favorites_count || 0) - 1);
            await user.save();
            return res.json({ isFavorite: false });
        } else {
            await user.addFavorite(material);
            user.favorites_count = (user.favorites_count || 0) + 1;
            await user.save();
            return res.json({ isFavorite: true });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.checkFavorite = async (req, res) => {
    try {
        const { userId } = req.query;
        const { materialId } = req.params;
        
        const user = await User.findByPk(userId);
        const material = await Material.findByPk(materialId);

        if (!user || !material) return res.json({ isFavorite: false });

        const isFavorite = await user.hasFavorite(material);
        res.json({ isFavorite });
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.getFavorites = async (req, res) => {
    try {
        const { id } = req.params; // userId
        const user = await User.findByPk(id, {
            include: [{
                model: Material,
                as: 'Favorites',
                through: { attributes: [] }
            }]
        });

        if (!user) return res.status(404).json({ message: 'User not found' });

        res.json({ data: user.Favorites });
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.getUsers = async (req, res) => {
  try {
    const { page = 1, limit = 10, search, type, active_status, device_model, system_version, app_version, country, province, city, district } = req.query;
    const offset = (page - 1) * limit;

    const where = {};
    if (search) where.nickname = { [Op.like]: `%${search}%` };
    if (type) where.type = type;
    if (active_status) where.active_status = active_status;
    if (device_model) where.device_model = { [Op.like]: `%${device_model}%` };
    if (system_version) where.system_version = { [Op.like]: `%${system_version}%` };
    if (app_version) where.app_version = { [Op.like]: `%${app_version}%` };
    if (country) where.country = country;
    if (province) where.province = province;
    if (city) where.city = city;
    if (district) where.district = district;

    const { count, rows } = await User.findAndCountAll({
      where,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['created_at', 'DESC']]
    });

    res.json({
      total: count,
      page: parseInt(page),
      totalPages: Math.ceil(count / limit),
      data: rows
    });
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.getUser = async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ message: 'Not Found' });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.updateUserStatus = async (req, res) => {
  try {
    const { status } = req.body; // active, banned, restricted
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ message: 'Not Found' });
    
    user.status = status;
    await user.save();
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};
