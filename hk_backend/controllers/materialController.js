const { Material, Tag, Software, MaterialFile } = require('../models');
const { Op } = require('sequelize');

exports.getMaterials = async (req, res) => {
  try {
    const { page = 1, limit = 10, search, type, category, tag_id, software_id, status, date_from, date_to } = req.query;
    const offset = (page - 1) * limit;

    const where = {};
    if (search) where.title = { [Op.like]: `%${search}%` };
    if (type) where.type = type;
    if (category) where.category = category;
    if (status) where.status = status;
    if (date_from && date_to) {
      where.created_at = { [Op.between]: [new Date(date_from), new Date(date_to)] };
    }

    const include = [
      { model: Software, as: 'Softwares' },
      { model: Tag, as: 'Tags' },
      { model: MaterialFile, as: 'Files' }
    ];

    if (tag_id) {
       include[1].where = { id: tag_id };
    }
    
    if (software_id) {
        include[0].where = { id: software_id };
    }

    const { count, rows } = await Material.findAndCountAll({
      where,
      include,
      distinct: true, // Important for counts with includes
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
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.createMaterial = async (req, res) => {
  try {
    const { title, category, type, software_ids, tags, files } = req.body;
    // files is an array of { name, url, format, size, preview_url }
    // Single file legacy fields:
    const { file_url, preview_url, file_size } = req.body; 

    const material = await Material.create({
      title,
      category,
      type,
      // software_id is removed
      file_url: file_url || (files && files.length > 0 ? files[0].url : ''),
      preview_url: preview_url || (files && files.length > 0 ? files[0].preview_url : ''),
      file_size: file_size || 0,
      status: 'on_shelf'
    });

    if (tags && tags.length > 0) {
      const tagInstances = [];
      for (const tag of tags) {
        if (typeof tag === 'string') {
          const [tagInstance] = await Tag.findOrCreate({ 
            where: { name: tag },
            defaults: { type: 'general' }
          });
          tagInstances.push(tagInstance);
        } else if (typeof tag === 'number') {
           const tagInstance = await Tag.findByPk(tag);
           if (tagInstance) tagInstances.push(tagInstance);
        }
      }
      if (tagInstances.length > 0) {
        await material.setTags(tagInstances);
      }
    }
    
    if (software_ids && software_ids.length > 0) {
        await material.setSoftwares(software_ids);
    }

    if (files && files.length > 0) {
        const fileInstances = files.map(f => ({
            ...f,
            material_id: material.id
        }));
        await MaterialFile.bulkCreate(fileInstances);
    }

    res.status(201).json(material);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.getMaterial = async (req, res) => {
  try {
    const material = await Material.findByPk(req.params.id, {
      include: [
          { model: Software, as: 'Softwares' },
          { model: Tag, as: 'Tags' },
          { model: MaterialFile, as: 'Files' }
      ]
    });
    if (!material) return res.status(404).json({ message: 'Not Found' });
    res.json(material);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.downloadMaterial = async (req, res) => {
  try {
    const material = await Material.findByPk(req.params.id);
    if (!material) return res.status(404).json({ message: 'Not Found' });

    // Increment download count
    material.download_count = (material.download_count || 0) + 1;
    await material.save();

    // Increment user download count if userId is provided
    if (req.body.userId) {
        const { User } = require('../models');
        const user = await User.findByPk(req.body.userId);
        if (user) {
            user.total_download_count = (user.total_download_count || 0) + 1;
            await user.save();
        }
    }

    res.json({ success: true, downloads: material.download_count });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.updateMaterialStatus = async (req, res) => {
  try {
    const { status } = req.body; // on_shelf, off_shelf
    const material = await Material.findByPk(req.params.id);
    if (!material) return res.status(404).json({ message: 'Not Found' });
    
    material.status = status;
    await material.save();
    res.json(material);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.updateMaterial = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, category, type, software_ids, tags, files, preview_url, file_url, file_size } = req.body;
    
    const material = await Material.findByPk(id);
    if (!material) return res.status(404).json({ message: 'Not Found' });

    // Update basic fields
    if (title) material.title = title;
    if (category) material.category = category;
    if (type) material.type = type;
    if (preview_url) material.preview_url = preview_url;
    if (file_url) material.file_url = file_url;
    // file_size might be 0, so check undefined
    if (file_size !== undefined) material.file_size = file_size;
    
    await material.save();

    // Update Tags
    if (tags) {
        const tagInstances = [];
        for (const tag of tags) {
            if (typeof tag === 'string') {
                const [tagInstance] = await Tag.findOrCreate({ where: { name: tag }, defaults: { type: 'general' } });
                tagInstances.push(tagInstance);
            } else if (typeof tag === 'number') {
                const tagInstance = await Tag.findByPk(tag);
                if (tagInstance) tagInstances.push(tagInstance);
            }
        }
        await material.setTags(tagInstances);
    }

    // Update Softwares
    if (software_ids) {
        await material.setSoftwares(software_ids);
    }

    // Update Files
    if (files && files.length > 0) {
        // Delete old files
        await MaterialFile.destroy({ where: { material_id: id } });
        // Create new
        const fileInstances = files.map(f => ({ ...f, material_id: id }));
        await MaterialFile.bulkCreate(fileInstances);
    }

    res.json(material);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};
