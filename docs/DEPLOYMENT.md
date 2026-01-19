# Deployment Guide

This guide covers deploying the RAG Chatbot using Docker containerization.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Methods](#deployment-methods)
  - [Method 1: Using Scripts (Recommended)](#method-1-using-scripts-recommended)
  - [Method 2: Using Makefile](#method-2-using-makefile)
  - [Method 3: Manual Docker Compose](#method-3-manual-docker-compose)
- [Configuration](#configuration)
- [Production Considerations](#production-considerations)
- [Monitoring and Logs](#monitoring-and-logs)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required

- **Docker Desktop** (latest version)
- **LM Studio** (installed on host machine)
- **Python** 3.10+ (for local development)

### Optional

- **make** (for Makefile commands)

### Installation Check

```bash
# Verify Docker installation
docker --version

# Verify Python installation
python3 --version
```

## Quick Start

The fastest way to deploy:

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd poc-poc-graphrag-documentation-assistant-wiki

# 2. Set up environment variables
cp .env.example .env

# 3. Deploy with one command
make deploy
```

The application will be available at `http://localhost:8501`

## Deployment Methods

### Method 1: Using Scripts (Recommended)

The deployment scripts provide automated setup and error checking.

```bash
# Deploy the application
./scripts/deploy.sh

# View logs
./scripts/logs.sh

# Stop the application
./scripts/stop.sh

# Rebuild the image
./scripts/build.sh
```

**Features:**
- Automatic dependency checking
- Environment validation
- Health check verification

### Method 2: Using Makefile

Simple commands for common operations:

```bash
# Build container image
make build

# Deploy application
make deploy

# View logs
make logs

# Stop application
make stop

# Restart application
make restart

# Open shell in container
make shell

# Clean up everything
make clean
```

### Method 3: Manual Docker Compose

For manual control using `docker-compose`:

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Configuration

### Environment Variables

Create a `.env` file with your configuration:

```bash
# LM Studio URL (default is host.docker.internal for Mac/Windows)
LLM_BASE_URL=http://host.docker.internal:1234/v1
```

### Port Configuration

Default port is `8501`. To change:

**In docker-compose.yml:**
```yaml
ports:
  - "8080:8501"
```

### Volume Mounts

The application uses three persistent volumes:

- `./data/documents` - Uploaded documents
- `./data/vector_stores` - FAISS indices
- `./logs` - Application logs

## Monitoring and Logs

### View Container Logs

```bash
# Real-time logs
docker logs -f webapp

# Last 100 lines
docker logs --tail 100 webapp
```

### Health Check

The container includes a health check:

```bash
# Check health status
docker inspect webapp | grep -A 10 Health

# Manual health check
curl http://localhost:8501/_stcore/health
```

### Application Logs

Application logs are stored in `./logs/` directory:

```bash
# View application logs
tail -f logs/*.log
```

## Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker logs webapp
```

**Common issues:**
- **LM Studio unreachable**: Ensure LM Studio server is running and `LLM_BASE_URL` is correct.
- **Port already in use**: Free up port 8501 or change mapping.

### Connection Refused to LM Studio

- Use `http://host.docker.internal:1234/v1` in `.env` if using Docker Desktop on Mac/Windows.
- Use `http://172.17.0.1:1234/v1` for Linux usually.
- **Crucial**: Enable CORS in LM Studio server settings.

### Image Build Fails

**Clear build cache:**
```bash
docker system prune -a
docker build -t poc-graphrag-documentation-assistant-webapp -f Containerfile .
docker run -p 8501:8501 poc-graphrag-documentation-assistant-webapp
```

## Support

For issues or questions:

1. Check [README.md](../README.md) for general documentation
2. Review [SETUP.md](SETUP.md) for installation help
3. Check logs: `docker logs webapp`
4. Open an issue on GitHub
