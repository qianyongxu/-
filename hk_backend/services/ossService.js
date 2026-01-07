const COS = require('cos-nodejs-sdk-v5');
require('dotenv').config();

const cos = new COS({
  SecretId: process.env.COS_SECRET_ID,
  SecretKey: process.env.COS_SECRET_KEY,
});

// const { v4: uuidv4 } = require('uuid');
const crypto = require('crypto');

const uploadFile = async (fileBuffer, originalName, folder = 'uploads') => {
  return new Promise((resolve, reject) => {
    // Generate a unique short filename: timestamp_uuid(8chars).ext
    const ext = originalName.split('.').pop().toLowerCase();
    // Use crypto.randomBytes for a short random string instead of uuid
    const randomStr = crypto.randomBytes(4).toString('hex');
    const shortName = `${Date.now()}_${randomStr}.${ext}`;
    
    cos.putObject({
      Bucket: process.env.COS_BUCKET,
      Region: process.env.COS_REGION,
      Key: `${folder}/${shortName}`,
      Body: fileBuffer,
    }, function(err, data) {
      if (err) {
        reject(err);
      } else {
        // Construct the URL manually or use the Location from data
        // Ensure protocol is https
        let url = data.Location;
        if (!url.startsWith('http')) {
             url = `https://${url}`;
        }
        resolve(url);
      }
    });
  });
};

module.exports = {
  uploadFile
};
