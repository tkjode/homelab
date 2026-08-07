# Whisper GPU Voice Recognition

A Docker Compose setup for running Whisper models with GPU acceleration.

## Overview

This configuration hosts Whisper models for voice recognition using NVIDIA GPUs.

## Prerequisites

- Docker and Docker Compose installed
- NVIDIA GPU (CUDA 11.8 or higher recommended)
- Python 3.9+

## Quick Start

> The runner on Tethys will git archive and deploy this content to `/app/docker/< folder >`, ensure production execution is from there, not a checked out repo.


```bash
# Navigate to the directory
cd ./base/builds/tethys/docker/whisper

# Start the containers
docker-compose up -d

# View logs
docker-compose logs -f
```

## Models

Available models:

| Model | Parameters |
|-------|------------|
| `whisper-large-v3-turbo` | 11.3B |
| `whisper-large-v3` | 9.7B |
| `whisper-turbo` | 2.5B |

## Configuration

Edit `docker-compose.yaml` to customize:

- GPU allocation
- Model paths
- Port mappings

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose                          │
├─────────────────────────────────────────────────────────────┤
│  whisper-container (GPU)                                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Whisper Model (GPU Accelerated)                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

- **GPU Not Detected**: Ensure NVIDIA drivers and CUDA are installed
- **OOM Error**: Reduce model size or increase memory limits
- **Port Conflict**: Check for existing services on the specified port
