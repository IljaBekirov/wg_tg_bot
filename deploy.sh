#!/bin/bash
set -e

echo "Pulling latest changes from GitHub..."
git pull origin master

echo "Stopping running containers..."
docker-compose down

echo "Building new Docker image with no cache..."
docker-compose build --no-cache bot

echo "Starting services with forced recreation..."
docker-compose up -d --force-recreate

echo "Cleaning up unused images..."
docker image prune -f

echo "Deployment complete!"
