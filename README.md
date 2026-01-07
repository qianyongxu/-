# HK Project Setup Guide

## 1. Project Structure
- `hk_backend`: Node.js Backend (Express + Sequelize)
- `hk_admin`: React Frontend (Admin Panel)

## 2. Local Development

### Backend
1. Go to `hk_backend` folder.
2. Install dependencies: `npm install`
3. Start server: `node index.js`
   - Runs on: `http://localhost:3000`
   - Database: Local `database.sqlite` (configured in `.env`)

### Admin Frontend
1. Go to `hk_admin` folder.
2. Install dependencies: `npm install`
3. Start dev server: `npm run dev`
   - Access at: `http://localhost:5173`

## 3. Server Deployment (49.233.207.97)

### Prerequisites
- Node.js & MySQL installed on the server.
- Nginx for serving frontend and reverse proxy.

### Backend Deployment
1. Upload `hk_backend` to server (e.g., `/var/www/hk_backend`).
2. Run `npm install --production`.
3. Update `.env` file:
   - Uncomment MySQL config.
   - Comment out SQLite config.
   - Ensure DB credentials are correct.
4. Start with PM2: `pm2 start index.js --name hk_backend`

### Frontend Deployment
1. Run `npm run build` in `hk_admin` locally.
2. Upload `dist` folder to server (e.g., `/var/www/hk_admin`).
3. Configure Nginx to serve static files from `dist` and proxy `/api` to `localhost:3000`.

## 4. Configuration
- **WeChat**: Configured in `hk_backend/.env`.
- **Tencent COS**: Configured in `hk_backend/.env`.
  - Note: Please double check the `COS_SECRET_KEY` in `.env`.

## 5. API Endpoints
- `GET /api/materials`: List materials
- `POST /api/materials`: Create material
- `POST /api/auth/login`: WeChat Login
- `POST /api/common/upload`: Upload file to COS
