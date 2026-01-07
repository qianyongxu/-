require('dotenv').config();
const COS = require('cos-nodejs-sdk-v5');
const axios = require('axios');

const cos = new COS({
  SecretId: process.env.COS_SECRET_ID,
  SecretKey: process.env.COS_SECRET_KEY,
});

const bucket = process.env.COS_BUCKET;
const region = process.env.COS_REGION;
const key = 'test_access.txt';

async function run() {
  console.log(`Testing COS: Bucket=${bucket}, Region=${region}`);
  
  // 1. Upload
  console.log('1. Uploading file...');
  try {
    await new Promise((resolve, reject) => {
        cos.putObject({
            Bucket: bucket,
            Region: region,
            Key: key,
            Body: 'Hello World via Script',
        }, (err, data) => {
            if (err) reject(err);
            else resolve(data);
        });
    });
    console.log('Upload success.');
  } catch (err) {
    console.error('Upload failed:', err);
    return;
  }

  // 2. Construct URL
  let url;
  try {
      url = await new Promise((resolve, reject) => {
          cos.getObjectUrl({
              Bucket: bucket,
              Region: region,
              Key: key,
              Sign: false, // Unsigned! To test Public Read.
          }, (err, data) => {
              if (err) reject(err);
              else resolve(data.Url);
          });
      });
      console.log('Generated URL (Unsigned):', url);
  } catch (err) {
      console.error('GetUrl failed:', err);
      return;
  }

  // 3. Fetch
  console.log('2. Fetching URL...');
  try {
      const res = await axios.get(url);
      console.log('Fetch success! Status:', res.status);
      console.log('Data:', res.data);
  } catch (err) {
      console.error('Fetch failed:', err.message);
      if (err.response) {
          console.error('Status:', err.response.status);
          console.error('Data:', err.response.data);
      }
  }
}

run();
