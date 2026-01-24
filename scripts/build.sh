#!/bin/bash
# Build script for GraphRAG Documentation Assistant
# Builds Docker images without starting containers

set -e

# Enable BuildKit for better caching and performance
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

echo "Building GraphRAG images with BuildKit (parallel mode)..."

# Build images in parallel for faster builds
if command -v docker-compose &> /dev/null; then
    docker-compose build --parallel "$@"
elif docker compose version &> /dev/null; then
    docker compose build --parallel "$@"
else
    echo "Error: Docker Compose not found"
    exit 1
fi

echo "✓ Build complete"
