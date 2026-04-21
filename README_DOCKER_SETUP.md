# 📦 Docker & DigitalOcean Deployment - Complete Setup Summary

## ✅ What Has Been Created

I've created a complete Docker & deployment setup for your Teammates Backend project. Here's everything:

### 1. **Dockerfile** 
   - Multi-stage build for optimal image size
   - Production-ready with health checks
   - Uses Alpine Linux for efficiency
   - Handles signal management properly

### 2. **docker-compose.yml**
   - Local development environment
   - Includes MongoDB service
   - Includes Mongo Express for easy database management
   - Proper networking and health checks

### 3. **Documentation**
   - **DEPLOYMENT_GUIDE.md** - 200+ lines comprehensive guide
   - **DOCKER_QUICK_REFERENCE.md** - Quick reference for common tasks
   - **.env.example** - Template for environment variables
   - **nginx.conf.template** - Production Nginx configuration

### 4. **Deployment Scripts**
   - **deploy.sh** - Interactive deployment helper

### 5. **Configuration Files**
   - **.dockerignore** - Optimizes Docker build

## 🚀 Next Steps (In Order)

### Step 1: Test Locally (5-10 minutes)
```bash
cd /path/to/teammates-backend

# Copy environment template
cp .env.example .env

# Update .env with your values (optional for local testing)

# Start services
docker-compose up -d

# Check services
docker-compose ps

# View logs
docker-compose logs -f app

# Test API
curl http://localhost:5000/api

# Stop when done
docker-compose down
```

### Step 2: Set Up DigitalOcean Account (if you don't have one)
- Sign up at https://www.digitalocean.com
- Add payment method
- Create an account

### Step 3: Choose Deployment Method

#### **RECOMMENDED: App Platform (Easiest)**

1. Create GitHub repository and push your code
   ```bash
   git init
   git add .
   git commit -m "Initial commit with Docker setup"
   git remote add origin https://github.com/your-username/teammates-backend.git
   git push -u origin main
   ```

2. Go to https://cloud.digitalocean.com
   - Click "Create" → "App"
   - Select "GitHub"
   - Authorize and select your repository
   - DigitalOcean will auto-detect Dockerfile
   - Set service port to 5000

3. Add Environment Variables:
   ```
   NODE_ENV: production
   PORT: 5000
   BASE_PATH: /api
   MONGO_URI: [your MongoDB connection string]
   SESSION_SECRET: [generate a random secret]
   GOOGLE_CLIENT_ID: [from Google Cloud]
   GOOGLE_CLIENT_SECRET: [from Google Cloud]
   GOOGLE_CALLBACK_URL: https://[your-app-domain]/api/auth/google/callback
   FRONTEND_ORIGIN: https://[your-frontend-domain]
   FRONTEND_GOOGLE_CALLBACK_URL: https://[your-frontend-domain]/auth/google/callback
   ```

4. Click "Deploy" and wait ~5-10 minutes

#### **ALTERNATIVE: Droplet + Docker (More Control, Cheaper)**

Follow the detailed steps in **DEPLOYMENT_GUIDE.md** starting at "Step 2: Create DigitalOcean Resources - Option B"

### Step 4: Set Up MongoDB (Choose One)

**Option A: MongoDB Atlas (Recommended for beginners)**
1. Go to https://www.mongodb.com/cloud/atlas
2. Create free account
3. Create free cluster
4. Create database user
5. Get connection string
6. Use in MONGO_URI

**Option B: Self-hosted in Docker (Cheaper long-term)**
- Included in docker-compose.yml for local testing
- For production, deploy in separate Docker container on Droplet

### Step 5: Set Up Google OAuth

1. Go to https://console.cloud.google.com
2. Create new project
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add your domain URLs to authorized redirects
6. Copy credentials to environment variables

### Step 6: Deploy and Test
- Push your code
- Check deployment status in DigitalOcean console
- Test your API endpoints
- Monitor logs

## 📝 Environment Variables Required

```bash
# Node Environment
NODE_ENV=production
PORT=5000
BASE_PATH=/api

# Database
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/teammates

# Session
SESSION_SECRET=generate-a-strong-random-secret-here
SESSION_EXPIRES_IN=1d

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_CALLBACK_URL=https://your-domain.com/api/auth/google/callback

# Frontend Configuration
FRONTEND_ORIGIN=https://your-frontend-domain.com
FRONTEND_GOOGLE_CALLBACK_URL=https://your-frontend-domain.com/auth/google/callback
```

## 💰 Cost Comparison

### App Platform Method
- Cost: $12+ per month
- Upside: Auto-scaling, automatic deployments, minimal management
- Downside: More expensive

### Droplet Method
- Cost: $6/month (Droplet) + Free (MongoDB Atlas)
- Upside: Full control, cheaper, can self-host MongoDB
- Downside: Manual scaling, server management required

## 📚 File Reference

| File | Purpose |
|------|---------|
| `Dockerfile` | Container specification |
| `docker-compose.yml` | Local development setup |
| `.dockerignore` | Build optimization |
| `.env.example` | Environment template |
| `DEPLOYMENT_GUIDE.md` | Full deployment instructions |
| `DOCKER_QUICK_REFERENCE.md` | Quick commands reference |
| `deploy.sh` | Interactive helper script |
| `nginx.conf.template` | Production Nginx config |

## ✨ Key Features of Your Setup

✅ **Multi-stage Docker build** - Optimized image size (~200MB vs 500MB+)
✅ **Health checks** - Automatic container monitoring
✅ **Environment configuration** - Secure secret management
✅ **Development setup** - docker-compose with MongoDB included
✅ **Production ready** - Proper signal handling, logging, restarts
✅ **Well documented** - Multiple guides for different needs
✅ **Security best practices** - HTTPS, environment variables, SSL

## 🔍 Common Commands After Deployment

### Check Status
```bash
# App Platform
doctl apps list
doctl apps get <app-id>

# Droplet
docker ps
docker logs teammates-backend
```

### Update Application
```bash
# App Platform: Just push to GitHub

# Droplet:
docker pull registry.digitalocean.com/your-registry/teammates-backend:latest
docker stop teammates-backend
docker rm teammates-backend
docker run -d ... [see DEPLOYMENT_GUIDE.md]
```

### View Logs
```bash
# App Platform
doctl apps logs <app-id> --follow

# Droplet
docker logs -f teammates-backend
```

## ⚠️ Important Reminders

1. **Never commit `.env`** - it's in `.gitignore`
2. **Change all secrets** - SESSION_SECRET, MONGO password, etc.
3. **Use HTTPS** - Not optional for production
4. **Backup database** - Set up automated backups
5. **Monitor logs** - Check for errors regularly
6. **Update dependencies** - Keep Node.js and packages updated

## 🆘 Troubleshooting

### Container won't start locally
```bash
docker-compose logs app
# Check for error messages and fix configuration
```

### Port 5000 already in use
```bash
# On Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# On Mac/Linux
lsof -i :5000
kill -9 <PID>
```

### Can't connect to MongoDB
```bash
# Check MongoDB is running
docker-compose ps mongo

# Test connection string
# Verify MONGO_URI in .env
```

### API endpoints return 404
```bash
# Make sure BASE_PATH matches your frontend requests
# Default: /api
# Check FRONTEND_ORIGIN matches your frontend exactly
```

## 📖 Detailed Guides Location

- **Full Instructions**: Open `DEPLOYMENT_GUIDE.md`
- **Quick Reference**: Open `DOCKER_QUICK_REFERENCE.md`
- **Nginx Setup**: See `nginx.conf.template`

## 🎉 You're Now Ready!

Your application is fully containerized and ready for deployment. Start with the local test, then choose your deployment method and follow the corresponding guide.

**Need help?** Check the appropriate markdown file in your project root:
- General questions → `DOCKER_QUICK_REFERENCE.md`
- Deployment steps → `DEPLOYMENT_GUIDE.md`
- Nginx/Server config → `nginx.conf.template`

Happy deploying! 🚀
