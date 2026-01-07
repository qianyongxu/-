#!/bin/bash

# 1. Backend Setup
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

COS_SECRET_ID=AKIDoUzHMFwSmtnV09LKApJagbKqCLH2avcJ
COS_SECRET_KEY=Yu3ygBUaVFm8IEx8MZmqGqMgrsjQ2Ws8
COS_BUCKET=hk-1301306766
COS_REGION=ap-guangzhou
COS_DOMAIN=https://hk-1301306766.cos.ap-guangzhou.myqcloud.com
EOL

# Restart Backend
pm2 restart hk_backend 2>/dev/null || pm2 start index.js --name "hk_backend"

# 2. Nginx Setup
echo "Configuring Nginx..."
mkdir -p /etc/nginx/certs

# Generate dummy certs if not exist to prevent Nginx start failure (User should replace these)
if [ ! -f /etc/nginx/certs/hk.xbjy123.com_bundle.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/hk.xbjy123.com.key -out /etc/nginx/certs/hk.xbjy123.com_bundle.crt -subj "/C=CN/ST=State/L=City/O=Organization/CN=hk.xbjy123.com"
fi

cat > /etc/nginx/sites-available/hk << EOL
server {
    listen 80;
    server_name hk.xbjy123.com 49.233.207.97;
    return 301 https://hk.xbjy123.com\$request_uri;
}

server {
    listen 443 ssl;
    server_name hk.xbjy123.com;

    ssl_certificate /etc/nginx/certs/hk.xbjy123.com_bundle.crt;
    ssl_certificate_key /etc/nginx/certs/hk.xbjy123.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Admin Panel (CRM)
    location /crm {
        alias /var/www/hk_admin;
        index index.html;
        try_files \$uri \$uri/ /crm/index.html;
    }

    # API Proxy
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    # Static Files (Legal Docs)
    location / {
        root /var/www/hk_backend/public;
        try_files \$uri \$uri/ =404;
    }
}
EOL


# Apply Nginx Config
ln -sf /etc/nginx/sites-available/hk /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

echo "Deployment Update Complete!"
echo "IMPORTANT: Please upload your SSL certificates to /etc/nginx/certs/"
echo "  - /etc/nginx/certs/hk.xbjy123.com_bundle.crt"
echo "  - /etc/nginx/certs/hk.xbjy123.com.key"
echo "Then run: systemctl restart nginx"
echo "Admin Panel: https://hk.xbjy123.com/crm/"
