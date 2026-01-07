#!/bin/bash

# 1. Kill Rogue Node Processes
echo "Killing rogue Node processes..."
# Find PID of process listening on 3000
PID=$(lsof -t -i:3000)
if [ -n "$PID" ]; then
    kill -9 $PID
fi
# Also stop all PM2 processes to be safe
pm2 kill

# 2. Start Correct Backend
echo "Starting Backend..."
cd /var/www/hk_backend
pm2 start index.js --name "hk_backend"
pm2 save

# 3. Update Nginx Config (Add Redirect for Root)
echo "Updating Nginx..."
cat > /etc/nginx/conf.d/hk.conf << EOL
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

    # Redirect root to /crm
    location = / {
        return 301 /crm/;
    }

    # Admin Panel (CRM)
    location /crm {
        alias /var/www/hk_admin/crm;
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

    # Legal Docs
    location /privacy.html {
        root /var/www/hk_backend/public;
    }
    location /service.html {
        root /var/www/hk_backend/public;
    }
}
EOL

# 4. Permissions
chown -R www-data:www-data /var/www/hk_admin
chmod -R 755 /var/www/hk_admin

# 5. Restart Nginx
nginx -t && systemctl restart nginx

echo "Final Fix Complete!"
