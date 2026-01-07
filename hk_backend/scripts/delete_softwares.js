const { Software } = require('../models');
const { Op } = require('sequelize');

async function run() {
  const names = [
    'MediBang Paint', 
    'SketchBook', 
    'ArtFlow', 
    'Krita', 
    'Infinite Painter', 
    'Inkscape', 
    'HK Paint'
  ];
  
  console.log('Deleting softwares:', names);

  try {
    const count = await Software.destroy({
      where: {
        name: { [Op.in]: names }
      }
    });
    console.log(`Successfully deleted ${count} softwares.`);
    process.exit(0);
  } catch (error) {
    console.error('Error deleting softwares:', error);
    process.exit(1);
  }
}

run();
