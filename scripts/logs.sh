#!/bin/bash
# View logs

SERVICE=${1:-graphrag-backend}

echo "Viewing logs for $SERVICE..."
docker compose logs -f $SERVICE
