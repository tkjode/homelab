# Ollama on Tethys

## Overview

This directory contains the Docker Compose configuration for running Ollama on the Tethys server.

## Prerequisites

- Docker and Docker Compose installed on the Tethys server
- Ollama installed on the Tethys server

## Setup

### 1. Pull Ollama Image

```bash
docker pull ollama/ollama
```

### 2. Start Ollama

```bash
docker-compose up -d
```

### 3. Access Ollama

```bash
# Start the Ollama service
docker-compose up -d

# Access the Ollama API
curl http://localhost:11434/api/tags
```

## Configuration

Edit `docker-compose.yaml` to customize:
- Port mappings
- Environment variables
- Resource limits

## Cleanup

```bash
docker-compose down
```

## Troubleshooting

- Check logs: `docker-compose logs -f`
- Restart service: `docker-compose restart`
- View Ollama status: `docker ps | grep ollama`