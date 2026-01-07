const { sequelize, Software, Tag } = require('../models');

const softwareData = [
  { name: '画世界Pro', supported_formats: 'hsj,psd,jpg,png', source_format: 'hsj', logo: 'https://via.placeholder.com/100?text=HSJ' },
  { name: 'CLIP STUDIO PAINT', supported_formats: 'clip,lip,psd,psb,bmp,jpg,png,tif,tga,pdf', source_format: 'clip', logo: 'https://via.placeholder.com/100?text=CSP' },
  { name: 'MediBang Paint', supported_formats: 'mdp,jpg,png,bmp,psd,tif,webp', source_format: 'mdp', logo: 'https://via.placeholder.com/100?text=MediBang' },
  { name: 'SketchBook', supported_formats: 'tiff,bmp,gif,jpeg,png,psd', source_format: 'tiff', logo: 'https://via.placeholder.com/100?text=SketchBook' },
  { name: 'ArtFlow', supported_formats: 'png,jpg,psd', source_format: 'png', logo: 'https://via.placeholder.com/100?text=ArtFlow' },
  { name: 'Procreate', supported_formats: 'procreate,psd,jpeg,png,tiff,gif,pdf,mp4,hevc,obj,usd', source_format: 'procreate', logo: 'https://via.placeholder.com/100?text=Procreate' },
  { name: 'Adobe Photoshop', supported_formats: 'psd,psb,bmp,gif,eps,jpeg,iff,jps,pcx,pdf,raw,pxr,png,sct,tga,tiff,vda,icb,vst', source_format: 'psd', logo: 'https://via.placeholder.com/100?text=PS' },
  { name: 'Krita', supported_formats: 'kra,ora,psd,xcf,jpg,png,tiff,gif,bmp,webp,ico,tga,ppm,pgm,pbm,xbm,svg', source_format: 'kra', logo: 'https://via.placeholder.com/100?text=Krita' },
  { name: 'Infinite Painter', supported_formats: 'pntr,psd,jpg,png,zip', source_format: 'pntr', logo: 'https://via.placeholder.com/100?text=Infinite' },
  { name: 'Paint Tool SAI', supported_formats: 'sai,sai2,psd,bmp,jpg,png,tga', source_format: 'sai', logo: 'https://via.placeholder.com/100?text=SAI' },
  { name: 'Corel Painter', supported_formats: 'rif,psd,tif,bmp,jpg,png,gif,eps', source_format: 'rif', logo: 'https://via.placeholder.com/100?text=Painter' },
  { name: 'Inkscape', supported_formats: 'svg,svgz,pdf,png,ps,eps,emf,wmf,ccx,cdt,cgm,cmx', source_format: 'svg', logo: 'https://via.placeholder.com/100?text=Inkscape' },
  { name: 'HK Paint', supported_formats: 'hk,psd,png,jpg', source_format: 'hk', logo: 'https://via.placeholder.com/100?text=HK' },
];

const tagData = [
  // User provided
  '水彩', '古风', '厚涂', '国风', '二次元', '漫画', '日系', 'Q版', '鸭风', '头像', '人像', '赛璐璐',
  // Procreate & Others related
  '笔刷', 'Brush', '线稿', 'Lineart', '色卡', 'Palette', '字体', 'Font', '纹理', 'Texture',
  '油画', 'Oil Painting', '素描', 'Sketch', '水墨', 'Ink', '霓虹', 'Neon', '发光', 'Glow',
  '复古', 'Retro', '可爱', 'Cute', '写实', 'Realistic', '风景', 'Landscape', '人物', 'Character',
  '植物', 'Plant', '动物', 'Animal', '建筑', 'Architecture', '装饰', 'Decoration', '图案', 'Pattern'
];

async function seed() {
  try {
    await sequelize.sync(); // Ensure tables exist

    console.log('Seeding Software...');
    for (const soft of softwareData) {
      await Software.findOrCreate({
        where: { name: soft.name },
        defaults: soft
      });
    }

    console.log('Seeding Tags...');
    for (const tagName of tagData) {
      await Tag.findOrCreate({
        where: { name: tagName },
        defaults: { name: tagName }
      });
    }

    console.log('Seeding completed successfully.');
    process.exit(0);
  } catch (error) {
    console.error('Seeding failed:', error);
    process.exit(1);
  }
}

seed();
