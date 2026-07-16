# vLLM Docker Compose

This directory contains a Docker Compose setup for running vLLM.

## Overview

The `docker-compose.yaml` file defines the service configuration used to launch the vLLM container.

It typically includes:
- service definition for the vLLM server
- image or build configuration
- port mappings for API access
- volume mounts for model storage and configuration files
- environment variables required for runtime

## Prerequisites

- Docker installed
- Docker Compose available
- GPU drivers and NVIDIA Container Toolkit installed if the service requires GPU access

## Running

From this directory:

```bash
docker compose up -d
```

To stop the stack:

```bash
docker compose down
```

## Notes

Refer to `docker-compose.yaml` for the exact service name, image, exposed ports, mounted volumes, and environment variables.

If the compose file mounts a local model directory, make sure the model files are available in the mapped host path.

## Inspecting the configuration

Use the following command to view the resolved configuration:

```bash
docker compose config
```

This README is intended to provide a quick reference for the vLLM compose setup in this folder.