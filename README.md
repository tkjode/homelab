# HomeLab

This repository is primarily responsible for orchestrating activities on my Dell T630 tower as a virtualization platform, presently running Proxmox at the baremetal layer.

Underneath `/base`, there are folders pertaining to particular automation topics, all ideally designed with the goal of being operated on by GitHub Actions.

## Requirements

- A GitHub Actions runner localized inside the target environment (eg. my home network)
- Proxmox API Key + Secret
- Sufficient CPU+Memory on the target compute node to run all the intended workloads

## Journal

See [Journal.md](Journal.md) for progress reports as they happen.

## Things to figure out

- Kube bootstrap cloud-init machines
  - [ ] Make master nodes and worker nodes from cloud-init bases 
  - [ ] Certificate generation (TF generated x509s maybe?) for cluster api+etcd certs
  - [ ] Seeding hosts file with known static nodes for joining (we have no DHCP in clusternet so should be easy enough)
  - [ ] Capture kubeconfig on init kubes
- ~~Talos Cluster~~
  - [x] Booting & configuring OpenWRT reliably to route traffic
    - Actually made an ubuntu router VM using cloud-init that works well.
  - [x] NGINX forwarding from the local network... NAT or DualHomed?
    - Dropping NGINX for HAProxy
  - [x] Reliably configure nodes with talosctl after TF spins them up
    - Not going to use Talos anymore.
- [x] SSH Sign Commits and Tags
- [x] ~~Seeding/Updating ISO images into Proxmox Storage~~  Yeah dude we can do ISOs and IMGs and GZIP decompression and everything now.
- [x] Making CloudInit VM templates
- [x] ~~Generating K8S clusters into SDNs and creating a firewall+gateway+reverse proxy for accessing them~~ We can do bridges for now.
