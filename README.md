# HomeLab

This repository is primarily responsible for orchestrating activities on my Dell T630 tower as a virtualization platform, presently running Proxmox at the baremetal layer.

Underneath `/base`, there are folders pertaining to particular automation topics, all ideally designed with the goal of being operated on by GitHub Actions.

## Requirements

- A GitHub Actions runner localized inside the target environment (eg. my home network)
- Proxmox API Key + Secret
- Sufficient CPU+Memory on the target compute node to run all the intended workloads
- A hosted zone in AWS and a Route53 enabled user/role to do DNS-01 challenges for LetsEncrypt/certbot. 

## Journal

See [Journal.md](Journal.md) for progress reports as they happen.

## Things to figure out

#### TODO/WIP

- [ ] Worker nodes are being built before the API is up - need to get some sort of blocker in that waits for Cluster API showing active on HAProxy  
- [ ] Start using locals for complex variable expressions (eg. all the cidrhosts and masks) - make them simple vars like "gateway-ip-address" and "gateway-full-cidr" or something
- [x] Create persistent storage for LetsEncrypt so it doesn't get rate limited on rebuild
- [x] Make Gateway do some basic IPAM for the cluster.  There are a lot of DNS queries firing out to the internet needlessly.

#### Done

- [x] Once the cluster is built and stable, Kick off "Day 2 Ops" ?
  - [x] ArgoCD + app of apps boot up helm chart
- [x] DNS+Cert Integration - cluster trust fixes /w more DNS+IP SANs on the API Server
  - [x] Route53 integration - ~~from within cluster?~~ Cluster has a CA and Cert-Manager for internal, external TLS trust is handled by certbot on haproxy gw. 
- [x] HAProxy Ingress Controller (~~mostly worked out~~ ~~TLS is killing me~~ TLS has been pwned)
  - [x] Gateway API + Envoy looks like the next iteration on the Ingress paradigm for kubernetes, do that!
- Kube bootstrap cloud-init machines
  - [x] Make master nodes and worker nodes from cloud-init bases
  - [x] Certificate generation (TF generated x509s maybe?) for cluster api+etcd certs
  - [x] Seeding hosts file with known static nodes for joining (we have no DHCP in clusternet so should be easy enough)
  - [x] ~~Capture kubeconfig on init kubes~~ too annoying
- ~~Talos Cluster~~
  - [x] Booting & configuring OpenWRT reliably to route traffic
    - Actually made an ubuntu router VM using cloud-init that works well.
  - [x] NGINX forwarding from the local network... NAT or DualHomed?
    - Dropping ~~NGINX~~ for *HAProxy*
  - [x] Reliably configure nodes with `talosctl` after TF spins them up
    - Not going to use Talos anymore.
- [x] SSH Sign Commits and Tags
- [x] ~~Seeding/Updating ISO images into Proxmox Storage~~  Yeah dude we can do ISOs and IMGs and GZIP decompression and everything now.
- [x] Making CloudInit VM templates
- [x] ~~Generating K8S clusters into SDNs and creating a firewall+gateway+reverse proxy for accessing them~~ We can do bridges for now.

## ArgoCD Cluster Bootstrap

- `BIOS`
  - [x] Gateway API
  - [x] Ingress Controller
  - [x] External Secrets Operator
- `COMMAND.COM`
  - [x] Cert Manager
  - [x] And more...