# Ollama Docker Container

## Overview

This container provides a local environment for running Ollama, an open-source LLM framework.

## Prerequisites

- Docker and Docker Compose installed
- Ollama installed on the host machine

## Setup

### 1. Pull Ollama

```bash
docker pull ollama/ollama:latest
```

### 2. Run the Container

```bash
docker-compose up -d
```

### 3. Pull Models

After the container is running, pull the desired models using the following methods:

#### Method 1: Using `docker exec`

```bash
# Connect to the container
docker exec -it ollama ollama pull llama3

# Pull multiple models
docker exec -it ollama ollama pull llama3.1 mistral:7b
```

#### Method 2: Using `docker ps`

```bash
# List running containers
docker ps

# Pull models from the running container
docker exec ollama ollama pull llama3
```

### 4. Pull Models from Hugging Face

To pull models from Hugging Face, create an `.env` file with your HF token:

```bash
# Create .env file
touch .env
```

```bash
# Add HF_TOKEN environment variable
nano .env
```

```env
HF_TOKEN=<your_huggingface_token>
```

Then pull models from Hugging Face:

```bash
docker exec -it ollama ollama pull llama3 --hf-token <your_huggingface_token>
```

## Accessing the Container

### Using `docker exec`

```bash
# Enter the container
docker exec -it ollama bash

# Inside the container, you can run:
ollama pull llama3
```

### Using `docker ps`

```bash
# List containers
docker ps

# Access the container
docker exec ollama bash
```

## Troubleshooting

- **Pulling models fails**: Check your HF token in `.env`
- **Container won't start**: Ensure Docker is running
- **No models available**: Pull models from Hugging Face using the token

## Cleanup

```bash
docker-compose down
```

## Notes

- Models are stored in the container's local storage
- For persistent storage, consider using a volume mount
- The container is optimized for local development and testing