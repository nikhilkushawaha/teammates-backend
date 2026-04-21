#!/bin/bash

# Teammates Backend - Quick Deployment Script
# This script helps you deploy to DigitalOcean Droplet via Docker

set -e

echo "🚀 Teammates Backend - DigitalOcean Deployment Helper"
echo "========================================================="
echo ""

# Check if doctl is installed
if ! command -v doctl &> /dev/null; then
    echo "❌ doctl CLI is not installed."
    echo "Install it from: https://docs.digitalocean.com/reference/doctl/how-to/install/"
    exit 1
fi

echo "✅ doctl CLI found"
echo ""

# Menu
echo "Select deployment method:"
echo "1) Build and push to Docker Registry"
echo "2) Display Docker run command"
echo "3) Display docker-compose command"
echo "4) Setup instructions for droplet"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📦 Building and pushing Docker image..."
        echo ""
        
        read -p "Enter your DigitalOcean Registry name (e.g., teams): " registry_name
        
        # Build image
        echo "🔨 Building Docker image..."
        docker build -t teammates-backend:latest .
        
        # Tag image
        docker tag teammates-backend:latest registry.digitalocean.com/${registry_name}/teammates-backend:latest
        
        # Log in to registry
        echo "🔐 Logging into DigitalOcean Registry..."
        doctl registry login
        
        # Push image
        echo "📤 Pushing image to registry..."
        docker push registry.digitalocean.com/${registry_name}/teammates-backend:latest
        
        echo ""
        echo "✅ Image pushed successfully!"
        echo "🎯 Registry URL: registry.digitalocean.com/${registry_name}/teammates-backend:latest"
        ;;
        
    2)
        echo ""
        echo "🐳 Docker run command:"
        echo ""
        cat << 'EOF'
docker run -d \
  --name teammates-backend \
  -p 5000:5000 \
  --env-file .env \
  -v app-logs:/var/log \
  --restart unless-stopped \
  registry.digitalocean.com/your-registry/teammates-backend:latest
EOF
        echo ""
        echo "📝 Steps:"
        echo "1) SSH into your Droplet"
        echo "2) Create .env file with your environment variables"
        echo "3) Run the command above"
        ;;
        
    3)
        echo ""
        echo "🐳 Docker Compose command:"
        echo ""
        echo "For local development/testing:"
        echo "  docker-compose up -d"
        echo ""
        echo "View logs:"
        echo "  docker-compose logs -f app"
        echo ""
        echo "Stop services:"
        echo "  docker-compose down"
        echo ""
        echo "This will start both your app and MongoDB!"
        ;;
        
    4)
        echo ""
        echo "📋 Setup Instructions for DigitalOcean Droplet:"
        echo ""
        cat << 'EOF'
=== STEP 1: SSH into your Droplet ===
ssh root@your-droplet-ip

=== STEP 2: Install Docker ===
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

=== STEP 3: Login to Docker Registry ===
docker login registry.digitalocean.com

=== STEP 4: Create environment file ===
nano .env

(Add all required environment variables)

=== STEP 5: Create and run container ===
docker run -d \
  --name teammates-backend \
  -p 5000:5000 \
  --env-file .env \
  --restart unless-stopped \
  registry.digitalocean.com/your-registry/teammates-backend:latest

=== STEP 6: Setup Nginx (reverse proxy) ===
sudo apt install nginx -y

=== STEP 7: Configure SSL ===
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com

=== STEP 8: Check status ===
docker ps
docker logs teammates-backend

=== For updates ===
docker pull registry.digitalocean.com/your-registry/teammates-backend:latest
docker stop teammates-backend
docker rm teammates-backend
docker run -d ... (repeat run command above)
EOF
        ;;
        
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "📚 For detailed instructions, see: DEPLOYMENT_GUIDE.md"
echo ""
