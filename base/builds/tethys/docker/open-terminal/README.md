# Open Terminal (Docker Compose)

A Docker Compose deployment for [Open Terminal](https://github.com/open-webui/open-terminal), an open-source terminal interface designed to work alongside [Open WebUI](https://openwebui.com/).

## About Open Terminal

**Open Terminal** is a modern, lightweight terminal interface built specifically as a companion to Open WebUI. It provides:

- A **browser-based terminal experience** that integrates directly with Open WebUI
- Seamless integration with Open WebAI's AI assistant features
- A clean, minimal interface for interacting with AI models via the command line
- No additional software installation required on the host system — everything runs in a container

## Purpose & Use Case

Open Terminal is included as part of the Open WebUI ecosystem to provide users with:

1. **Direct Terminal Access**: Run shell commands directly from the browser without needing an external terminal emulator (like VS Code's remote SSH or Hyper).
2. **AI-Assisted Development**: Pair the terminal with Open WebUI's AI chat interface for command-line assistance, code generation, and debugging workflows.
3. **Lightweight Deployment**: As a Docker Compose service, it runs alongside your main Open WebUI stack without requiring complex host-side configurations.

### Why Use It With Open WebUI?

- **Complementary Experience**: While Open WebUI provides the AI chat interface (web-based), Open Terminal gives you a shell environment that can be accessed through the same infrastructure.
- **Shared Context**: Both services can share the same Docker Compose network, making it easy to access shared volumes, environments, or other services from within the terminal.
- **Simplicity**: No need for SSH key management, remote server setups, or separate terminal emulator software — just `docker compose up` and you're in a shell.

## Quick Start

### Prerequisites

- Docker Engine 20.10+ with Docker Compose plugin installed
- Docker Compose v2.x (preferred)

### Run with Docker Compose

```bash
docker compose up -d
```

This will:

1. Pull the latest Open Terminal image from `ghcr.io/open-webui/open-terminal`
2. Start a container named `open-terminal` exposing port `8000`
3. The terminal becomes accessible via your browser at `http://localhost:8000`

### Accessing the Terminal

Once running, navigate to `http://localhost:8000` in your browser. You'll be presented with a terminal interface where you can execute commands interactively.

## Configuration

Edit [`docker-compose.yaml`](./docker-compose.yaml) to customize:

| Option | Default | Description |
|--------|---------|-------------|
| `image` | `ghcr.io/open-webui/open-terminal:latest` | The Open Terminal image tag |
| `container_name` | `open-terminal` | Container name |
| `ports.0` | `"8000:8000"` | Host port mapping |
| `restart` | `unless-stopped` | Restart policy |

### Example: Custom Port Binding

```yaml
services:
  open-terminal:
    image: ghcr.io/open-webui/open-terminal:latest
    container_name: open-terminal
    ports:
      - "127.0.0.1:8000:8000"  # Bind to localhost only
```

### Example: Using a Specific Image Tag

```yaml
services:
  open-terminal:
    image: ghcr.io/open-webui/open-terminal:v0.1.0
```

## Architecture

```
┌─────────────────────────────┐
│   Host (Your Machine)        │
├─────────────────────────────┤
│                             │
│   ┌──────────────────┐      │
│   │  Browser         │◄─────┼── http://localhost:8000
│   │  (Browser)       │     │
│   └──────────────────┘      │
│           │                  │
│           ▼                  │
│   ┌──────────────────┐      │
│   │  Docker Network  │      │
│   └──────────────────┘      │
│           │                  │
│           ▼                  │
│   ┌──────────────────┐      │
│   │ open-terminal    │◄─────┼── Image: ghcr.io/open-webui/open-terminal
│   │  Container       │      │     Port: 8000 → 8000
│   │  (Port 8000)     │      │
│   └──────────────────┘      │
│                             │
└─────────────────────────────┘
```

## Common Commands

```bash
# Start the container in detached mode
docker compose up -d

# Stop and remove all containers
docker compose down

# View logs
docker compose logs -f open-terminal

# Rebuild with new image tag
docker compose pull && docker compose up -d

# Restart the service
docker compose restart open-terminal
```

## Stopping the Service

When you're done:

```bash
docker compose down
```

> **Note:** This will remove all containers and volumes unless you modify `docker-compose.yaml` to use named volumes.

## Troubleshooting

### Container won't start

Check if Docker is running:

```bash
docker info
```

Try pulling the latest image explicitly:

```bash
docker compose pull open-terminal && docker compose up -d
```

### Port already in use

If port `8000` is already bound, either free it or change the port mapping in [`docker-compose.yaml`](./docker-compose.yaml):

```yaml
ports:
  - "127.0.0.1:8001:8000"
```

### Access from other hosts

To access Open Terminal from another machine on your network, expose the port without binding to localhost only (remove `127.0.0.1:` prefix):

```yaml
ports:
  - "8000:8000"
```

## License

Open Terminal is open-source software released under the [Apache-2.0](https://github.com/open-webui/open-terminal/blob/main/LICENSE) license. See the upstream project for full licensing details.

## Contributing

This Docker Compose deployment is part of the Open WebUI ecosystem. For contributions, bugs, and feature requests related to Open Terminal itself, please refer to the [upstream repository](https://github.com/open-webui/open-terminal).

For issues specific to this Docker Compose deployment (e.g., configuration problems), open an issue in this repository.

## Links

- **Open WebUI**: https://openwebui.com/
- **Open Terminal (Upstream)**: https://github.com/open-webui/open-terminal
- **Changelog**: [CHANGELOG.md](./CHANGELOG.md)
- **Docker Compose Config**: [`docker-compose.yaml`](./docker-compose.yaml)