#!/bin/bash
# Build RAG Chatbot container image

set -e

echo "Building RAG Chatbot container image..."

docker build --no-cache -t poc-graphrag-documentation-assistant:latest -f Containerfile .

echo "✓ Build complete!"
echo ""
echo "Image details:"
docker images | grep poc-graphrag-documentation-assistant || true
