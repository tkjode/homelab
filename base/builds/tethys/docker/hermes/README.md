# Hermes Docker Compose

A lightweight Docker Compose setup for the Hermes project.

## Overview

This repository contains the Docker Compose configuration to build and run the Hermes service stack in a local or development environment.

## Requirements

- Docker
- Docker Compose

## Usage

Start the stack:

```bash
docker compose up -d
```

Stop the stack:

```bash
docker compose down
```

View logs:

```bash
docker compose logs -f
```

Restart a service:

```bash
docker compose restart <service-name>
```

## Customization

Edit `docker-compose.yml` to adjust service definitions, environment variables, ports, and volume mounts.

## Notes

- Keep service configuration minimal and declarative.
- Use the compose file in this directory for local testing and development.
- Ensure Docker is running before starting the stack.
