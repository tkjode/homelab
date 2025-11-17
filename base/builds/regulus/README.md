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
- 3 Master VMs
- 6+ Worker VMs (variable)


## Applicable Pipelines

- A new `workflow` containing all `Regulus` tasks: [Regulus Workflow](.github/workflows/regulus.yaml)
- This will not be using the old talos actions.yml module system, that was fun but not neccessary for this build.

## Outputs

- __Secret:__ kubeadmin credentials / kubeconfig.json