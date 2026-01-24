#!/bin/bash
# Stop RAG Chatbot services

echo "Stopping RAG Chatbot services..."
docker compose down
echo "✓ Services stopped"
