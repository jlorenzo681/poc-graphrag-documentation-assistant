#!/bin/bash
# Cleanup script for RAG Chatbot
# Removes containers (keeps images and volumes by default)
# Use flags: --images to remove images, --volumes to remove volumes, --all for everything

set -e

echo "======================================"
echo "RAG Chatbot - Cleanup"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse flags
REMOVE_IMAGES=false
REMOVE_VOLUMES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --images)
            REMOVE_IMAGES=true
            shift
            ;;
        --volumes)
            REMOVE_VOLUMES=true
            shift
            ;;
        --all)
            REMOVE_IMAGES=true
            REMOVE_VOLUMES=true
            shift
            ;;
        *)
            echo -e "${YELLOW}Unknown option: $1${NC}"
            echo "Usage: $0 [--images] [--volumes] [--all]"
            echo "  --images   Remove images too"
            echo "  --volumes  Remove volumes too"
            echo "  --all      Remove everything (images + volumes)"
            exit 1
            ;;
    esac
done

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

# Stop and remove containers using compose if available
echo -e "\n${YELLOW}Stopping and removing containers...${NC}"
if command -v docker-compose &> /dev/null; then
    docker-compose down 2>/dev/null || true
    echo -e "${GREEN}✓ Containers stopped via docker-compose${NC}"
elif docker compose version &> /dev/null; then
    docker compose down 2>/dev/null || true
    echo -e "${GREEN}✓ Containers stopped via docker compose${NC}"
else
    # Manual removal
    for container in graphrag-frontend graphrag-backend graphrag-worker graphrag-beat graphrag-redis graphrag-neo4j; do
        if docker ps -a | grep -q $container; then
            docker stop $container 2>/dev/null || true
            docker rm $container 2>/dev/null || true
            echo -e "${GREEN}✓ $container container removed${NC}"
        fi
    done
fi

# Remove images if flag set
if [ "$REMOVE_IMAGES" = true ]; then
    echo -e "\n${YELLOW}Removing images...${NC}"

    for image in graphrag-frontend graphrag-backend graphrag-worker; do
        if docker image inspect $image:latest >/dev/null 2>&1; then
            docker rmi $image:latest 2>/dev/null || true
            echo -e "${GREEN}✓ $image image removed${NC}"
        fi
    done
else
    echo -e "\n${YELLOW}⚠ Images kept (use --images flag to remove)${NC}"
fi

# Remove volumes if flag set
if [ "$REMOVE_VOLUMES" = true ]; then
    echo -e "\n${YELLOW}Removing volumes...${NC}"

    for volume in graphrag-redis-data graphrag-neo4j-data; do
        if docker volume inspect $volume >/dev/null 2>&1; then
            docker volume rm $volume 2>/dev/null || true
            echo -e "${GREEN}✓ $volume removed${NC}"
        fi
    done
else
    echo -e "\n${YELLOW}⚠ Volumes kept (use --volumes flag to remove)${NC}"
fi

# Remove networks if they exist and have no containers
echo -e "\n${YELLOW}Cleaning up networks...${NC}"
for network in graphrag-network; do
    if docker network inspect $network >/dev/null 2>&1; then
        docker network rm $network 2>/dev/null || true
        echo -e "${GREEN}✓ Network $network removed (if empty)${NC}"
    fi
done

# Summary
echo -e "\n${GREEN}======================================"
echo "✓ Cleanup complete!"
echo "======================================${NC}"
echo ""
echo "Remaining resources:"
echo ""
echo "Containers:"
docker ps -a | grep -E 'CONTAINER|graphrag-' || echo "  None"
echo ""
echo "Images:"
docker images | grep -E 'REPOSITORY|graphrag-' || echo "  None"
echo ""
echo "Volumes:"
docker volume ls | grep -E 'DRIVER|graphrag-' || echo "  None"
echo ""
