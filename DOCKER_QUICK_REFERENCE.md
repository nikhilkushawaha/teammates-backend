# Teammates Backend - Docker & Deployment Quick Reference

## 📦 Files Created

1. **Dockerfile** - Multi-stage Docker build optimized for production
2. **docker-compose.yml** - Local development setup with MongoDB
3. **DEPLOYMENT_GUIDE.md** - Comprehensive deployment guide
4. **.env.example** - Environment variables template
5. **.dockerignore** - Docker build optimization
6. **deploy.sh** - Interactive deployment helper script

## 🚀 Quick Start

### Option 1: Local Testing with Docker Compose

```bash
# Test locally with MongoDB
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop services
docker-compose down
```

**Access:**
- API: http://localhost:5000
- MongoDB Express: http://localhost:8081 (admin/admin)

### Option 2: Build Docker Image Locally

```bash
# Build
docker build -t teammates-backend:latest .

# Run (requires .env file)
docker run -p 5000:5000 --env-file .env teammates-backend:latest

# View logs
docker logs -f <container-id>
```

### Option 3: Quick Deploy Script

```bash
bash deploy.sh
```

## 📋 Deployment Checklist

### Before Deployment:

- [ ] All code committed to Git
- [ ] `.env` file created with all variables
- [ ] MongoDB connection string ready (Atlas or self-hosted)
- [ ] Google OAuth credentials obtained
- [ ] Domain name configured (or use DigitalOcean URL)

### Environment Variables Needed:

```
NODE_ENV=production
PORT=5000
BASE_PATH=/api
MONGO_URI=mongodb+srv://...
SESSION_SECRET=<random-secret>
SESSION_EXPIRES_IN=1d
GOOGLE_CLIENT_ID=<your-id>
GOOGLE_CLIENT_SECRET=<your-secret>
GOOGLE_CALLBACK_URL=https://your-domain.com/api/auth/google/callback
FRONTEND_ORIGIN=https://your-frontend.com
FRONTEND_GOOGLE_CALLBACK_URL=https://your-frontend.com/auth/google/callback
```

## 🌐 Deployment Methods

### Method A: DigitalOcean App Platform (Easiest)

**Pros:** Auto-scaling, automatic deployments, minimal setup
**Cons:** Higher cost (~$12+/month)

1. Push code to GitHub
2. Create App in DigitalOcean Console
3. Connect to GitHub repository
4. Add environment variables
5. Deploy (automatic on push)

### Method B: DigitalOcean Droplet (Most Control)

**Pros:** Full control, cheaper ($6/month), can host MongoDB
**Cons:** Manual scaling, requires server management

1. Create Droplet
2. Install Docker
3. Push image to Docker Registry
4. Configure environment
5. Run Docker container
6. Setup Nginx for reverse proxy
7. Add SSL with Let's Encrypt

## 💾 Database Setup

### Option 1: MongoDB Atlas (Recommended)

```
Website: https://www.mongodb.com/cloud/atlas
Setup: 5 minutes
Cost: Free tier available
Backups: Automatic
```

Connection string:
```
mongodb+srv://username:password@cluster.mongodb.net/teammates?retryWrites=true&w=majority
```

### Option 2: Self-hosted MongoDB (On Droplet)

```bash
docker run -d \
  --name mongodb \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=<password> \
  -v mongodb_data:/data/db \
  -p 27017:27017 \
  mongo:7.0
```

## 🔒 Security Setup

### Google OAuth

1. Go to Google Cloud Console
2. Create new project
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs:
   - `https://your-domain.com/api/auth/google/callback`
   - `https://your-domain.com/auth/google/callback`

## 📊 Monitoring

### View Logs

**DigitalOcean App Platform:**
```bash
doctl apps logs <app-id> --follow
```

**Docker Droplet:**
```bash
docker logs -f teammates-backend
```

### Health Check

API is healthy if:
```bash
curl https://your-domain.com/api
# Should respond with API routes/information
```

## 🔄 Updates & Maintenance

### Updating Your Application

**App Platform:** Push to GitHub → Auto-deploys

**Droplet:**
```bash
docker pull registry.digitalocean.com/your-registry/teammates-backend:latest
docker stop teammates-backend
docker rm teammates-backend
docker run -d ... (with your environment variables)
```

### Backup Database

**MongoDB Atlas:** Automatic backups included

**Self-hosted:** Use `mongodump` command

## 💰 Cost Breakdown

| Service | Cost | Notes |
|---------|------|-------|
| DigitalOcean Droplet | $6/month | Minimum 2GB RAM |
| MongoDB Atlas | Free | Free tier available |
| Domain | $12/year | ~$1/month |
| SSL | Free | Let's Encrypt |
| **Total** | **~$7/month** | Very affordable |

## 🔧 Troubleshooting

### Container Won't Start
```bash
docker logs teammates-backend
docker inspect teammates-backend
```

### Port Already in Use
```bash
sudo lsof -i :5000
sudo kill -9 <PID>
```

### MongoDB Connection Failed
```bash
# Test connection
docker exec mongodb mongosh "mongodb+srv://user:pass@cluster.mongodb.net"
```

### CORS Issues
Check `FRONTEND_ORIGIN` matches your frontend URL exactly

## 📚 Useful Commands

```bash
# List all containers
docker ps

# View logs
docker logs -f teammates-backend

# Execute command in container
docker exec teammates-backend npm run seed

# Copy file from container
docker cp teammates-backend:/app/dist ./

# Check stats
docker stats teammates-backend

# Restart container
docker restart teammates-backend

# Remove container
docker rm teammates-backend

# View environment variables
docker inspect teammates-backend | grep -A 20 "Env"
```

## 📖 Resources

- [DigitalOcean App Platform Docs](https://docs.digitalocean.com/products/app-platform/)
- [DigitalOcean Droplet Setup](https://docs.digitalocean.com/tutorials/recommended-droplet-setup/)
- [Docker Documentation](https://docs.docker.com/)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- [Let's Encrypt](https://letsencrypt.org/)

## 📞 Getting Help

- Check `DEPLOYMENT_GUIDE.md` for detailed steps
- Run `bash deploy.sh` for interactive help
- Check Docker logs: `docker logs teammates-backend`
- Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`

---

**Version:** 1.0  
**Last Updated:** 2024  
**Status:** Ready for production
