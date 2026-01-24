#!/bin/bash
# Deployment script for RAG Chatbot using Docker

set -e

echo "======================================"
echo "RAG Chatbot - Docker Deployment"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create .env file with your API keys:"
    echo "  cp .env.example .env"
    exit 1
fi

# Source environment variables
export $(cat .env | grep -v '^#' | xargs)

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Please install Docker Desktop: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

echo -e "${GREEN}✓ Docker is installed${NC}"

# Compose file location
COMPOSE_FILE="docker-compose.yml"

# Check for compose tool
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose -f $COMPOSE_FILE"
    echo -e "${GREEN}✓ Using docker-compose${NC}"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose -f $COMPOSE_FILE"
    echo -e "${GREEN}✓ Using docker compose plugin${NC}"
else
    echo -e "${RED}Error: No compose tool found${NC}"
    echo "Please install Docker Desktop properly."
    exit 1
fi

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p data/documents data/vector_stores logs



# Stop existing containers via compose
echo -e "\n${YELLOW}Stopping existing containers...${NC}"
$COMPOSE_CMD down 2>/dev/null || true

# Start all services using compose
echo -e "\n${GREEN}Starting services (no build)...${NC}"
# --no-build ensures we use existing images
$COMPOSE_CMD up -d --no-build

# Wait for application to start
echo -e "\n${YELLOW}Waiting for application to start...${NC}"
sleep 10

# Check if containers are running
if docker ps | grep -q graphrag-frontend; then
    echo -e "\n${GREEN}======================================"
    echo "✓ Deployment successful!"
    echo "======================================${NC}"
    echo ""
    echo "Services running:"
    echo "  - Frontend: http://localhost:8501"
    echo "  - Backend:  http://localhost:8000"
    echo "  - Neo4j:    http://localhost:7474"
    echo ""
    echo "Useful commands:"
    echo "  View logs:           docker logs -f graphrag-frontend"
    echo "  Stop all:            $COMPOSE_CMD down"
    echo "  Restart all:         $COMPOSE_CMD restart"
    echo "  Container status:    $COMPOSE_CMD ps"
    echo ""

else
    echo -e "\n${RED}======================================"
    echo "✗ Deployment failed!"
    echo "======================================${NC}"
    echo "Check logs with:"
    echo "  docker logs graphrag-frontend"
    echo "  docker logs graphrag-backend"
    exit 1
fi
