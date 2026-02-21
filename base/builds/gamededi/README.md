# GameDedi

## Dedicated Docker-Compose VM for standing up dedicated game servers

### Features

- Uses a persistent volume to save game data, mounted by default under /app
- docker volumes must bind mount folders under /app subfolders to not lose data on VM rebuild

### Caveats for now

- if the VM is rebuilt, the docker-compose.yml under /app/* won't be added to system start up automatically, rebuilds require manual kickoff of docker apps
- There's no auto-NAT/port-forwarding rules happening on he HomeNetwork - ensure game port forwards are done manually to 10.0.0.9:_tcp|_udp ports

### TODO

- [ ] Pattern out how to enable docker-compose up's via a systemctl service

## Build Log

|       Date | Comments |
|      :---: | :------- |
| 2026-02-21 | Initial build attempt with untested terraform code. |
| 2026-02-21 | Mixup with Github Workflow actions - attempting build under new branch |