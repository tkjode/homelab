# Workstream

Homelab is a monorepo that primarily controls build & automation tasks in my homelab.

## Compute

- Dell PowerEdge T660 - 80c / 256GB Memory
  - Virtualization using Proxmox
- Gigabyte Brix i7-4500U - 4c / 16GB Memory

## Stuff for the Homelab

### Kubernetes Cluster

Needs a Proxmox bridge network, a router, NGINX with Certbot, some Route53 magic for DNS resolution.

### New Flexo

New name TBD but eventually need to retire the Gigabyte Brix, and plug the DAS directly to the Dell Tower.

### Minecraft Server

Ansible automation to setup and deploy a simple Ubuntu VM.