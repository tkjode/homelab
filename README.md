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

- Talos Cluster
  - [ ] Booting & configuring OpenWRT reliably to route traffic
  - [ ] NGINX forwarding from the local network... NAT or DualHomed?
  - [ ] Reliably configure nodes with talosctl after TF spins them up

- [x] ~~Seeding/Updating ISO images into Proxmox Storage~~  Yeah dude we can do ISOs and IMGs and GZIP decompression and everything now.
- [ ] Making CloudInit VM templates
- [x] ~~Generating K8S clusters into SDNs and creating a firewall+gateway+reverse proxy for accessing them~~ We can do bridges for now.
