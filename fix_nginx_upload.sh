#!/bin/bash

echo "Updating Nginx Config for Upload Size..."

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
    
    # Increase upload size limit
    client_max_body_size 100M;

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
        
        # Increase timeout for uploads
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
    }

    # Static Files (Legal Docs)
    location / {
        root /var/www/hk_backend/public;
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Restart Nginx
nginx -t && systemctl restart nginx
echo "Nginx Updated with 100M upload limit."
