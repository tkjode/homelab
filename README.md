# HomeLab

This repository is primarily responsible for orchestrating activities on my Dell T630 tower as a virtualization platform, presently running Proxmox at the baremetal layer.

Underneath `/base`, there are folders pertaining to particular automation topics, all ideally designed with the goal of being operated on by GitHub Actions.

## Requirements

- A GitHub Actions runner localized inside the target environment (eg. my home network)
- Proxmox API Key + Secret
- Sufficient CPU+Memory on the target compute node to run all the intended workloads

## Things to figure out

- Seeding/Updating ISO images into Proxmox Storage
- Making CloudInit VM templates
- Generating K8S clusters into SDNs and creating a firewall+gateway+reverse proxy for accessing them
