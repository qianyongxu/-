# HK Project Deployment Guide

## 1. Prerequisites
- **Server**: Linux (Ubuntu/CentOS) with Node.js (v16+) and MySQL installed.
- **Nginx**: For reverse proxy and serving static files.
- **PM2**: Process manager for Node.js (`npm install -g pm2`).

## 2. Backend Deployment (hk_backend)

1. **Transfer Code**:
   Upload the `hk_backend` directory to your server (e.g., `/var/www/hk_backend`).
   ```bash
   scp -r hk_backend user@49.233.207.97:/var/www/
   ```

2. **Install Dependencies**:
   ```bash
   cd /var/www/hk_backend
   npm install --production
   ```

3. **Configure Environment**:
   - Rename `.env.example` (if any) or create `.env`.
   - Update database credentials and other keys:
     ```env
     PORT=3000
     DB_HOST=localhost
     DB_USER=your_db_user
     DB_PASS=your_db_password
     DB_NAME=hk_db
     DB_DIALECT=mysql
     
     WX_APP_ID=wx7d9cb886ea434628
     WX_APP_SECRET=39bc087b1bbce68b42cc9361c6852f8a
     
     COS_SECRET_ID=AKIDHUTCesNa3FvCDzcnunUy7LI3Y7RWvAgv
     COS_SECRET_KEY=YOUR_COS_KEY
     COS_BUCKET=hk-1301306766
     COS_REGION=ap-guangzhou
     ```

4. **Initialize Database**:
   - Ensure MySQL is running and `hk_db` database is created.
   - Run seed script to populate initial data (Software & Tags):
     ```bash
     node scripts/seedData.js
     ```

5. **Start Application**:
   ```bash
   pm2 start index.js --name "hk_backend"
   ```

## 3. Frontend Deployment (hk_admin)

1. **Build Project**:
   Locally, in `hk_admin` directory:
   ```bash
   npm run build
   ```
   This creates a `dist` directory.

2. **Transfer Build**:
   Upload the `dist` folder to your server.
   ```bash
   scp -r dist user@49.233.207.97:/var/www/hk_admin
   ```

3. **Configure Nginx**:
   Create a new Nginx config file (e.g., `/etc/nginx/sites-available/hk_admin`):
   ```nginx
   server {
       listen 80;
       server_name 49.233.207.97;

       # Frontend
       location / {
           root /var/www/hk_admin;
           index index.html;
           try_files $uri $uri/ /index.html;
       }

       # Backend API Proxy
       location /api {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

4. **Restart Nginx**:
   ```bash
   sudo ln -s /etc/nginx/sites-available/hk_admin /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

## 4. App Configuration

1. Update the API Base URL in your Flutter App code (`hk_app`) to point to `http://49.233.207.97/api`.
2. Build and run the app on your device.
