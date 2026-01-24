#!/bin/bash
# Build RAG Chatbot images
# Does NOT start containers

set -e

echo "Building RAG Chatbot images..."

# Build images only
# --parallel might be useful but defaults are usually fine
if command -v docker-compose &> /dev/null; then
    docker-compose build
elif docker compose version &> /dev/null; then
    docker compose build
else
    echo "Error: Docker Compose not found"
    exit 1
fi

echo "✓ Images built successfully!"
