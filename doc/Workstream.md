# Workstream

Homelab is a monorepo that primarily controls build & automation tasks in my homelab.

## Compute

- Dell PowerEdge T660 - 80c / 256GB Memory
  - Virtualization using Proxmox
- Gigabyte Brix i7-4500U - 4c / 16GB Memory

## Stuff for the Homelab

- Talos Kubernetes Cluster
  - Eventually replacing all containers presently running on the Gigabyte Brix
  - Primary Hosting platform for all container workloads going forward
  - SDN Setup:
    - Worker nodes should not be eating up IP addresses on my home network
- Github Runner
  - Runs as a VM on the PowerEdge
    - Skifree = The VM that lives on the home network for managing Proxmox
    - ??? = The VM that will live inside the SDN network for deploying Talos - Skifree will deploy this
- Minecraft VM
  - Runs as a VM on the PowerEdge
- PFSense Firewall
  - Runs as a VM that bridges the Talos Cluster to the home network
  - Gateway mode for egress, K8s API(8443)+443(Services) ingress
  - Talos will be difficult to kickstart if Terraform is running outside of this SDN
- Ansible
  - Might be useful where GitHub Actions + TF can't work together nicely (eg. Talos deployer workbook)