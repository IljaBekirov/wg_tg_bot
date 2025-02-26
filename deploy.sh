#!/bin/bash
set -e

echo "Pulling latest changes from GitHub..."
git pull origin master

echo "Building new Docker image..."
docker-compose build --no-cache bot

echo "Restarting services..."
docker-compose up -d --force-recreate bot

echo "Cleaning up unused images..."
docker image prune -f

echo "Deployment complete!"
