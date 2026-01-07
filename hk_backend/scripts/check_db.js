const { Material } = require('../models');

async function run() {
  try {
    const m = await Material.findOne({ order: [['created_at', 'DESC']] });
    if (m) {
        console.log('Latest Material ID:', m.id);
        console.log('Title:', m.title);
        console.log('Preview URL:', m.preview_url);
    } else {
        console.log('No materials found.');
    }
  } catch (e) {
      console.error(e);
  }
}

run();
