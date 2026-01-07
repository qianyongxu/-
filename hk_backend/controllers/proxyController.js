const axios = require('axios');

exports.proxyImage = async (req, res) => {
    const { url } = req.query;
    if (!url) return res.status(400).send('No URL provided');
    
    try {
        const response = await axios({
            url,
            method: 'GET',
            responseType: 'stream',
            headers: {
                'Referer': 'https://hk.xbjy123.com',
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
        });
        
        res.set('Content-Type', response.headers['content-type']);
        res.set('Cache-Control', 'public, max-age=31536000'); // Cache for 1 year
        response.data.pipe(res);
    } catch (error) {
        console.error('Proxy Error:', error.message);
        res.status(500).send('Proxy Error');
    }
};
