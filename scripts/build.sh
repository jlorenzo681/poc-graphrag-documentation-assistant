#!/bin/bash
# Build and Start RAG Chatbot services
# Optimized for speed and completeness

set -e

echo "Building and starting RAG Chatbot services..."

# Build and start services in detached mode
# First, remove any existing containers to avoid name conflicts
docker compose down --remove-orphans || true
docker rm -f assistant backend worker redis neo4j 2>/dev/null || true

# --build ensures images are rebuilt if needed (Docker acts smart about layer caching)
# -d runs in background
docker compose up --build -d

echo "✓ Services built and started!"
echo ""
echo "Service status:"
docker compose ps
