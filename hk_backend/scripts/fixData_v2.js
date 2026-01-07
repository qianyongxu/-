const { sequelize, Material, Tag } = require('../models');

async function seedTags() {
  try {
    const materials = await Material.findAll();
    const tags = await Tag.findAll();
    
    if (tags.length === 0) {
        console.log('No tags found. Creating some...');
        await Tag.bulkCreate([
            { name: '热门', type: 'style' },
            { name: '推荐', type: 'style' },
            { name: '新手', type: 'audience' },
            { name: '古风', type: 'style' },
            { name: '二次元', type: 'style' }
        ]);
    }
    
    const allTags = await Tag.findAll();

    for (const m of materials) {
        // Assign 1-3 random tags
        const randomTags = allTags.sort(() => 0.5 - Math.random()).slice(0, Math.floor(Math.random() * 3) + 1);
        await m.setTags(randomTags);
        console.log(`Updated material ${m.id} with tags: ${randomTags.map(t => t.name).join(', ')}`);
    }

    console.log('Done!');
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

seedTags();
