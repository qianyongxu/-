const axios = require('axios');
const { User } = require('../models');
const jwt = require('jsonwebtoken');

exports.wechatLogin = async (req, res) => {
  // Support both Mini Program (code) and App (code) flows
  // For App Login: client sends code (from fluwx) -> backend exchanges for access_token -> getUserInfo
  // For Mini Program: client sends code -> backend exchanges for session_key (jscode2session)
  
  const { code, userInfo, access_token, openid: appOpenId, type } = req.body;

  try {
    let finalOpenId;
    let finalUnionId;
    let wxUserInfo = {};

    if (type === 'app' && code) {
        // App Flow: Exchange code for access_token
        const appId = process.env.WX_APP_ID;
        const secret = process.env.WX_APP_SECRET;
        const tokenUrl = `https://api.weixin.qq.com/sns/oauth2/access_token?appid=${appId}&secret=${secret}&code=${code}&grant_type=authorization_code`;
        
        const tokenRes = await axios.get(tokenUrl);
        const { access_token: at, openid, unionid, errcode, errmsg } = tokenRes.data;

        if (errcode) {
             return res.status(400).json({ message: `WeChat App Login Error: ${errmsg}` });
        }

        // Get User Info
        const userUrl = `https://api.weixin.qq.com/sns/userinfo?access_token=${at}&openid=${openid}`;
        const userRes = await axios.get(userUrl);
        
        if (userRes.data.errcode) {
             return res.status(400).json({ message: `WeChat User Info Error: ${userRes.data.errmsg}` });
        }

        finalOpenId = openid;
        finalUnionId = unionid || userRes.data.unionid;
        wxUserInfo = {
            nickName: userRes.data.nickname,
            avatarUrl: userRes.data.headimgurl,
            province: userRes.data.province,
            city: userRes.data.city,
            country: userRes.data.country
        };

    } else if (code) {
        // Mini Program Flow (Default)
        const appId = process.env.WX_MINI_APP_ID || process.env.WX_APP_ID;
        const secret = process.env.WX_MINI_APP_SECRET || process.env.WX_APP_SECRET;
        const url = `https://api.weixin.qq.com/sns/jscode2session?appid=${appId}&secret=${secret}&js_code=${code}&grant_type=authorization_code`;

        const response = await axios.get(url);
        const { openid, unionid, errcode, errmsg } = response.data;

        if (errcode) {
            return res.status(400).json({ message: `WeChat Mini Error: ${errmsg}` });
        }
        finalOpenId = openid;
        finalUnionId = unionid;
        // For Mini Program, userInfo is usually passed from client (getUserProfile)
        wxUserInfo = userInfo || {};
    } else if (access_token && appOpenId) {
        // Legacy App Flow (if client handled token exchange)
        // ... (keep existing logic if needed, or deprecate)
        // For now, let's keep it simple and assume code flow is preferred
        return res.status(400).json({ message: 'Please use code based login' });
    } else {
        return res.status(400).json({ message: 'Missing code' });
    }

    // Find or Create User
    let user;
    if (finalUnionId) {
        user = await User.findOne({ where: { unionid: finalUnionId } });
    } 
    if (!user) {
        user = await User.findOne({ where: { openid: finalOpenId } });
    }

    if (!user) {
      // Register
      user = await User.create({
        openid: finalOpenId,
        unionid: finalUnionId,
        nickname: wxUserInfo.nickName || 'WeChat User',
        avatar: wxUserInfo.avatarUrl || '',
        country: wxUserInfo.country,
        province: wxUserInfo.province,
        city: wxUserInfo.city,
        device_model: req.body.deviceInfo?.model,
        system_version: req.body.deviceInfo?.system,
        app_version: req.body.deviceInfo?.version,
        last_login_time: new Date()
      });
    } else {
        // Update info
        user.last_login_time = new Date();
        if (wxUserInfo.nickName || wxUserInfo.avatarUrl) {
            user.nickname = wxUserInfo.nickName || user.nickname;
            user.avatar = wxUserInfo.avatarUrl || user.avatar;
        }
        // Update device info
        if (req.body.deviceInfo) {
            user.device_model = req.body.deviceInfo.model || user.device_model;
            user.system_version = req.body.deviceInfo.system || user.system_version;
            user.app_version = req.body.deviceInfo.version || user.app_version;
        }
        // Update unionid
        if (finalUnionId && !user.unionid) {
            user.unionid = finalUnionId;
        }
        await user.save();
    }


    // Generate Token
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'hk_secret_key', { expiresIn: '30d' });

    res.json({ 
        token, 
        user: {
            id: user.id,
            nickname: user.nickname,
            avatar: user.avatar,
            type: user.type
        }
    });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};
