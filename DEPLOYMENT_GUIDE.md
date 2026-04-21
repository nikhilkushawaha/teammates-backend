# DigitalOcean Deployment Guide for Teammates Backend

This guide will help you deploy your Node.js/Express backend application to DigitalOcean.

## Prerequisites

- DigitalOcean account
- Docker installed locally
- Git repository with your code
- Domain name (optional but recommended)

## Step 1: Prepare Your Application

1. **Create `.env.example` file** (already done)
   - This helps team members understand required environment variables

2. **Ensure you have a `.gitignore`** file with:
   ```
   node_modules
   dist
   .env
   .DS_Store
   ```

3. **Test Docker build locally**:
   ```bash
   docker build -t teammates-backend:latest .
   docker run -p 5000:5000 --env-file .env teammates-backend:latest
   ```

## Step 2: Create DigitalOcean Resources

### Option A: Using DigitalOcean App Platform (Recommended - Easiest)

1. **Push code to GitHub**
   ```bash
   git push origin main
   ```

2. **Connect DigitalOcean App Platform to GitHub**
   - Go to [DigitalOcean Console](https://cloud.digitalocean.com)
   - Click "Create" → "App"
   - Select "GitHub" and authorize
   - Select your repository
   - DigitalOcean will auto-detect your Dockerfile

3. **Configure the App**
   - Service name: `teammates-backend`
   - Port: `5000`
   - HTTP routes: `/`

4. **Add Environment Variables**
   - In the App Platform settings, add all variables from `.env.example`:
     - `NODE_ENV`: `production`
     - `PORT`: `5000`
     - `MONGO_URI`: (your MongoDB connection string)
     - `SESSION_SECRET`: (generate a strong secret)
     - `GOOGLE_CLIENT_ID`: (from Google OAuth)
     - `GOOGLE_CLIENT_SECRET`: (from Google OAuth)
     - `GOOGLE_CALLBACK_URL`: (your deployed domain URL)
     - `FRONTEND_ORIGIN`: (your frontend URL)
     - `FRONTEND_GOOGLE_CALLBACK_URL`: (your frontend OAuth callback)

5. **Deploy**
   - Click "Create App"
   - DigitalOcean will build and deploy automatically
   - Your app URL will be provided

### Option B: Using Docker Container Registry + Droplet (More Control)

#### Step B.1: Set Up Docker Registry

1. **Create a Container Registry in DigitalOcean**
   - Console → "Manage" → "Container Registry"
   - Create new registry (e.g., `teammates`)
   - Note the registry name

2. **Log in to DigitalOcean Registry locally**
   ```bash
   doctl registry login
   ```

3. **Build and Push Docker Image**
   ```bash
   # Build image
   docker build -t teammates-backend:latest .

   # Tag image for registry
   docker tag teammates-backend:latest registry.digitalocean.com/teammates/teammates-backend:latest

   # Push to registry
   docker push registry.digitalocean.com/teammates/teammates-backend:latest
   ```

#### Step B.2: Create a Droplet

1. **Create Basic Droplet**
   - Size: `$6/month` (2 GB RAM, 1 vCPU) minimum
   - Region: Choose closest to your users
   - OS: Ubuntu 22.04 LTS
   - Add SSH key for access
   - Optional: Enable backups

2. **SSH into Droplet**
   ```bash
   ssh root@your-droplet-ip
   ```

3. **Install Docker**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y

   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh

   # Add Docker user
   sudo usermod -aG docker $USER
   newgrp docker
   ```

4. **Configure MongoDB (if not using MongoDB Atlas)**
   
   Option 1: Use MongoDB Atlas (Recommended)
   - Create free cluster at [mongodb.com](https://www.mongodb.com/cloud/atlas)
   - Create database user and get connection string
   - Whitelist DigitalOcean Droplet IP

   Option 2: Self-hosted MongoDB in Docker
   ```bash
   docker run -d \
     --name mongodb \
     -e MONGO_INITDB_ROOT_USERNAME=admin \
     -e MONGO_INITDB_ROOT_PASSWORD=strong-password \
     -v mongodb_data:/data/db \
     -p 27017:27017 \
     mongo:7.0

   # Connection string: mongodb://admin:strong-password@localhost:27017/teammates?authSource=admin
   ```

5. **Create `.env` file on Droplet**
   ```bash
   nano /home/user/.env
   ```
   
   Add all environment variables:
   ```
   NODE_ENV=production
   PORT=5000
   BASE_PATH=/api
   MONGO_URI=mongodb+srv://user:password@cluster.mongodb.net/teammates?retryWrites=true&w=majority
   SESSION_SECRET=generate-a-random-strong-secret
   SESSION_EXPIRES_IN=1d
   GOOGLE_CLIENT_ID=your-id
   GOOGLE_CLIENT_SECRET=your-secret
   GOOGLE_CALLBACK_URL=https://your-domain.com/api/auth/google/callback
   FRONTEND_ORIGIN=https://your-frontend-domain.com
   FRONTEND_GOOGLE_CALLBACK_URL=https://your-frontend-domain.com/auth/google/callback
   ```

6. **Run Docker Container**
   ```bash
   # Create persistent volume for logs
   docker volume create app-logs

   # Run container
   docker run -d \
     --name teammates-backend \
     -p 5000:5000 \
     --env-file /home/user/.env \
     -v app-logs:/var/log \
     --restart unless-stopped \
     registry.digitalocean.com/teammates/teammates-backend:latest
   ```

7. **Set Up Reverse Proxy with Nginx**
   ```bash
   sudo apt install nginx -y

   # Create Nginx config
   sudo nano /etc/nginx/sites-available/teammates

   # Add configuration
   ```
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:5000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

   ```bash
   # Enable site
   sudo ln -s /etc/nginx/sites-available/teammates /etc/nginx/sites-enabled/

   # Test configuration
   sudo nginx -t

   # Restart Nginx
   sudo systemctl restart nginx
   ```

8. **Set Up SSL with Let's Encrypt**
   ```bash
   sudo apt install certbot python3-certbot-nginx -y

   sudo certbot --nginx -d your-domain.com

   # Certbot will auto-renew periodically
   ```

9. **Check Container Status**
   ```bash
   docker ps
   docker logs teammates-backend
   ```

## Step 3: Configure Your Application

### MongoDB Setup
1. **MongoDB Atlas (Free Tier):**
   - Create account at [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
   - Create free cluster
   - Create database user
   - Whitelist your Droplet IP (0.0.0.0/0 for development)
   - Get connection string

### Google OAuth Setup
1. **Go to [Google Cloud Console](https://console.cloud.google.com)**
2. **Create OAuth 2.0 Credentials:**
   - Create new project
   - Enable Google+ API
   - Create OAuth consent screen
   - Create OAuth 2.0 Client ID (Web application)
   - Add authorized redirect URIs:
     - `https://your-domain.com/api/auth/google/callback`
     - `https://your-domain.com/auth/google/callback`

## Step 4: Monitoring and Maintenance

### View Logs (App Platform)
```bash
doctl apps logs <app-id> --follow
```

### View Logs (Droplet)
```bash
docker logs -f teammates-backend
```

### Update Application

When you push code updates to GitHub:

**App Platform:** Automatically rebuilds and deploys

**Droplet:**
```bash
# Pull latest image
docker pull registry.digitalocean.com/teammates/teammates-backend:latest

# Stop old container
docker stop teammates-backend
docker rm teammates-backend

# Run new container
docker run -d \
  --name teammates-backend \
  -p 5000:5000 \
  --env-file /home/user/.env \
  -v app-logs:/var/log \
  --restart unless-stopped \
  registry.digitalocean.com/teammates/teammates-backend:latest
```

### Backup Database
```bash
# MongoDB Atlas automatic backups (included)

# Or manual backup
docker exec mongodb mongodump --archive=/data/mongodb-backup.archive
docker cp mongodb:/data/mongodb-backup.archive ./backup-$(date +%Y%m%d).archive
```

## Troubleshooting

### Container not starting
```bash
# Check logs
docker logs teammates-backend

# Check if port is in use
sudo lsof -i :5000

# Check environment variables
docker inspect teammates-backend
```

### Connection issues
```bash
# Test MongoDB connection
docker run -it mongo:7.0 mongosh "mongodb+srv://user:password@cluster.mongodb.net"

# Check Nginx
sudo systemctl status nginx
sudo nginx -t
```

### High CPU/Memory usage
```bash
# Check container stats
docker stats teammates-backend

# Increase Droplet size or optimize code
```

## Cost Estimation (Droplet Method)

- Basic Droplet ($6/month): ~$6
- MongoDB Atlas (free tier): $0
- Backups (optional, $1/month): ~$1
- Domain (optional): ~$12/year
- **Total: ~$7-8/month**

## Best Practices

✅ **Enable monitoring** - Set up alerts for deployment failures
✅ **Use environment variables** - Never hardcode secrets
✅ **Regular backups** - Enable automated MongoDB backups
✅ **SSL/HTTPS** - Always use HTTPS in production
✅ **Rate limiting** - Consider adding rate limiting middleware
✅ **Logging** - Implement centralized logging
✅ **Update regularly** - Keep Node.js and dependencies updated

## Security Checklist

- [ ] `.env` file added to `.gitignore`
- [ ] All secrets in environment variables
- [ ] HTTPS enabled
- [ ] CORS properly configured for your domain
- [ ] MongoDB credentials strong and rotated
- [ ] Session secret is random and strong
- [ ] Firewall rules configured
- [ ] Regular backups enabled

---

For more help, visit [DigitalOcean Documentation](https://docs.digitalocean.com/)
