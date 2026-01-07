#!/bin/bash

# 1. Cleanup old configs to avoid conflicts
echo "Cleaning up old Nginx configs..."
mv /etc/nginx/conf.d/hk.xbjy123.com.conf /etc/nginx/conf.d/hk.xbjy123.com.conf.bak_$(date +%s) 2>/dev/null
mv /etc/nginx/conf.d/huiku_cms.conf /etc/nginx/conf.d/huiku_cms.conf.bak_$(date +%s) 2>/dev/null

# 2. Upload Certs (Already done in previous step, but ensuring path)
mkdir -p /etc/nginx/certs
# Only move if they exist in /var/www (uploaded via scp)
if [ -f /var/www/hk.xbjy123.com_bundle.crt ]; then
    mv /var/www/hk.xbjy123.com_bundle.crt /etc/nginx/certs/
fi
if [ -f /var/www/hk.xbjy123.com.key ]; then
    mv /var/www/hk.xbjy123.com.key /etc/nginx/certs/
fi

# 3. Ensure Frontend Directory Structure
echo "Ensuring Frontend Files..."
mkdir -p /var/www/hk_admin/crm
# Check if files are in /var/www/hk_admin root (not in crm)
if [ -f /var/www/hk_admin/index.html ]; then
    cd /var/www/hk_admin
    # Move everything except 'crm' folder into 'crm' folder
    find . -maxdepth 1 -not -name 'crm' -not -name '.' -exec mv {} crm/ \;
fi

# 4. Write Nginx Config to conf.d
echo "Configuring Nginx..."
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

    # Admin Panel (CRM)
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

# 5. Restart Nginx
echo "Restarting Nginx..."
nginx -t && systemctl restart nginx

echo "Deployment Fixed!"
