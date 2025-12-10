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

- [ ] Once the cluster is built and stable, Kick off "Day 2 Ops" ?
  - [ ] ArgoCD + app of apps boot up helm chart
- [ ] DNS+Cert Integration - cluster trust fixes /w more DNS+IP SANs on the API Server
  - [ ] Route53 integration - from within cluster?
- [ ] HAProxy Ingress Controller (~~mostly worked out~~TLS is killing me)
  - [ ] Gateway API + Envoy looks like the next iteration on the Ingress paradigm for kubernetes, do that!
- Kube bootstrap cloud-init machines
  - [x] Make master nodes and worker nodes from cloud-init bases
  - [x] Certificate generation (TF generated x509s maybe?) for cluster api+etcd certs
  - [x] Seeding hosts file with known static nodes for joining (we have no DHCP in clusternet so should be easy enough)
  - [x] ~~Capture kubeconfig on init kubes~~ too annoying
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

## ArgoCD Cluster Bootstrap

- `BIOS`
  - [ ] Gateway API
  - [ ] Ingress Controller
  - [ ] External Secrets Operator
- `COMMAND.COM`
  - [ ] Cert Manager
  - [ ] And more...