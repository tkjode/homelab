# Regulus

## Home Lab Kubernetes Cluster

### Design

This will be a basic Kubernetes cluster using:

- A single Proxmox Host
- Ubuntu Cloud Server virtual machines
- Kubernetes 1.34.1 or newer

## Considerations / Factors in Maintenance

Most of this project is concerned with build & basic day 2 configuration.  There may be another project designed to handle the ongoing maintenance for the nodes.  My personal preference would be to manage all of that from within Kubernetes itself using operators with very special privileges, much like how OpenShift handles its' node maintenance.

## Bill of Materials

- Ubuntu Cloud Server ISO
- A separate network for the Kubernetes Cluster
- A dual-purpose Ingress + Bastion host that bridges both networks
  - (stretch) AWS Entries for Route53 DNS Pointer
- An ISCSI Target with some fast SSD mounted on to use as download temp space, caching and persistent storage in Kubernetes
- 3 Master VMs
- 6+ Worker VMs (variable)


## Applicable Pipelines

- ~~A new `workflow` containing all `Regulus` tasks: [Regulus Workflow](.github/workflows/regulus.yaml)~~
  - A homelab common terraform runner workflow that happens to hit the `regulus` build.
- This will not be using the old talos actions.yml module system, that was fun but not neccessary for this build.

## Outputs

- ~~__Secret:__ kubeadmin credentials / kubeconfig.json~~
- Nothing, just build it.

## Changelog

- 2026-09-18: Trying to get to Kubernetes 1.37 but the switch to a common tf workflow has broken a lot of variables.
  - Would be nice to switch to Environments and just hard-set the TF_VAR_xxx_xxx values right into GitHub :thinking: