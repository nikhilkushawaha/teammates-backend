#!/bin/bash
# Setup Guide for Local Docker Testing
# Run this after cloning the repository

set -e

echo "🚀 Teammates Backend - Docker Setup Guide"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed."
    echo "Please install Docker from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo "✅ Docker is installed"
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  docker-compose not found as separate command"
    echo "   (Will try 'docker compose' instead)"
fi

echo ""
echo "📋 What this script does:"
echo "  1. Creates .env file from .env.example"
echo "  2. Builds Docker images"
echo "  3. Starts services (app + MongoDB)"
echo "  4. Displays access URLs"
echo ""

# Check if .env exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists"
    read -p "Do you want to recreate it from .env.example? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp .env.example .env
        echo "✅ .env recreated"
    fi
else
    cp .env.example .env
    echo "✅ .env created from .env.example"
fi

echo ""
echo "🔨 Building Docker images..."
docker-compose build

echo ""
echo "▶️  Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 3

echo ""
echo "✅ Services started!"
echo ""

# Try to get container status
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "🌐 Access URLs:"
echo "  API:                http://localhost:5000"
echo "  MongoDB Express:    http://localhost:8081"
echo "    Username: admin"
echo "    Password: admin"
echo ""

echo "📝 Useful commands:"
echo "  View logs:          docker-compose logs -f app"
echo "  View MongoDB logs:  docker-compose logs -f mongo"
echo "  Stop services:      docker-compose down"
echo "  Remove volume:      docker-compose down -v"
echo "  Rebuild image:      docker-compose build --no-cache"
echo ""

echo "🧪 Test API endpoint:"
echo "  curl http://localhost:5000/api"
echo ""

echo "📚 For more information, see:"
echo "  - README_DOCKER_SETUP.md (Getting started)"
echo "  - DEPLOYMENT_GUIDE.md (Production deployment)"
echo "  - DOCKER_QUICK_REFERENCE.md (Quick commands)"
echo ""

echo "✨ Setup complete! You can now develop locally with Docker."
echo ""
