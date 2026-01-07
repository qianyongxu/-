#!/bin/bash

# 1. Upload Certs
echo "Moving Certs..."
mkdir -p /etc/nginx/certs
mv /var/www/hk.xbjy123.com_bundle.crt /etc/nginx/certs/
mv /var/www/hk.xbjy123.com.key /etc/nginx/certs/

# 2. Fix Frontend Directory Structure for Nginx 'root' directive
# We want /var/www/hk_admin/crm to contain the files, so we can use root /var/www/hk_admin
echo "Reorganizing Frontend Files..."
mkdir -p /var/www/hk_admin/crm
# Move files from root of hk_admin to hk_admin/crm (avoiding infinite loop)
# Assume files are currently in /var/www/hk_admin
cd /var/www/hk_admin
# Move everything except 'crm' folder into 'crm' folder
find . -maxdepth 1 -not -name 'crm' -not -name '.' -exec mv {} crm/ \;

# 3. Nginx Config
echo "Configuring Nginx..."
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
    # Using root is safer than alias for try_files
    location /crm {
        root /var/www/hk_admin;
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

echo "SSL & CRM Fix Complete!"
