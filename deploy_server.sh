#!/bin/bash

# 1. Install Dependencies (Node.js, PM2, Nginx, MySQL Client)
echo "Updating system and installing dependencies..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get update
apt-get install -y nodejs nginx unzip mysql-server

npm install -g pm2

# 2. Setup Database
echo "Configuring Database..."
# Check if MySQL is running
service mysql start

# Create Database if not exists
mysql -u root -pXiaobai0217 -e "CREATE DATABASE IF NOT EXISTS hk_db;"

# 3. Backend Setup
echo "Setting up Backend..."
cd /var/www/hk_backend
npm install --production

# Update .env for production
cat > .env << EOL
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASS=Xiaobai0217
DB_NAME=hk_db
DB_DIALECT=mysql

WX_APP_ID=wx7d9cb886ea434628
WX_APP_SECRET=39bc087b1bbce68b42cc9361c6852f8a

COS_SECRET_ID=AKIDHUTCesNa3FvCDzcnunUy7LI3Y7RWvAgv
COS_SECRET_KEY=YOUR_COS_KEY_HERE_PLEASE_UPDATE
COS_BUCKET=hk-1301306766
COS_REGION=ap-guangzhou
COS_DOMAIN=https://hk-1301306766.cos.ap-guangzhou.myqcloud.com
EOL

# Seed Data
node scripts/seedData.js

# Start with PM2
pm2 delete hk_backend 2>/dev/null || true
pm2 start index.js --name "hk_backend"
pm2 save

# 4. Nginx Setup
echo "Configuring Nginx..."
cat > /etc/nginx/sites-available/hk << EOL
server {
    listen 80;
    server_name hk.xbjy123.com 49.233.207.97;

    root /var/www/hk_admin;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

ln -sf /etc/nginx/sites-available/hk /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

echo "Deployment Complete!"
