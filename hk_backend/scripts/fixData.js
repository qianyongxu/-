const { sequelize, Software } = require('../models');

async function fixData() {
  try {
    await sequelize.sync(); 
    const softwares = await Software.findAll();
    for (const s of softwares) {
      if (s.iconUrl && s.iconUrl.includes('via.placeholder.com')) {
        // Replace with a reliable source or empty string. 
        // Using a solid color image service or just clearing it.
        // Let's use a reliable simple service or just clear it to avoid errors.
        // Or use a data URI for a simple placeholder? No, too long.
        // Let's just set it to empty string or a default icon if frontend handles it.
        // Frontend code: render: (text) => text ? <img ... /> : '-'
        // So empty string is safe.
        s.iconUrl = ''; 
        await s.save();
        console.log(`Updated ${s.name}`);
      }
    }
    console.log('Data fix completed.');
    process.exit(0);
  } catch (error) {
    console.error('Fix failed:', error);
    process.exit(1);
  }
}

fixData();
